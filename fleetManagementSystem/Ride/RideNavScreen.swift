import SwiftUI
import MapKit
import CoreLocation

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct RouteOption: Identifiable {
    let id = UUID()
    let duration: TimeInterval
    let distance: CLLocationDistance
    var durationText: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes) min"
    }
    var distanceText: String {
        let km = distance / 1000
        return String(format: "%.1f km", km)
    }
    var eta: Date
    var etaText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: eta) + " ETA"
    }
    var polyline: MKPolyline
    var isSelected: Bool = false
}

class NavigationViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion()
    @Published var startLocation: Location
    @Published var destinationLocation: Location
    @Published var routes: [RouteOption] = []
    @Published var selectedRouteIndex: Int? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let locationManager = CLLocationManager()

    init(start: String, destination: String) {
        // Default positions for Mysore
        let mysoreCoordinate = CLLocationCoordinate2D(latitude: 12.2958, longitude: 76.6394)
        self.startLocation = Location(name: start, coordinate: mysoreCoordinate)

        // Approximate Mysore Airport coordinates
        let mysoreAirportCoordinate = CLLocationCoordinate2D(latitude: 12.2307, longitude: 76.6487)
        self.destinationLocation = Location(name: destination, coordinate: mysoreAirportCoordinate)

        // Set initial region to show Mysore
        self.region = MKCoordinateRegion(
            center: mysoreCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        setupLocationManager()
        geocodeLocations()
    }

    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    private func geocodeLocations() {
        geocodeLocation(name: startLocation.name) { [weak self] coordinate in
            guard let self = self else { return }
            if let coordinate = coordinate {
                self.startLocation = Location(name: self.startLocation.name, coordinate: coordinate)
                self.updateRegion()
                self.fetchRoutes()
            }
        }

        geocodeLocation(name: destinationLocation.name) { [weak self] coordinate in
            guard let self = self else { return }
            if let coordinate = coordinate {
                self.destinationLocation = Location(name: self.destinationLocation.name, coordinate: coordinate)
                self.updateRegion()
                self.fetchRoutes()
            }
        }
    }

    private func geocodeLocation(name: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let location = placemarks?.first?.location?.coordinate {
                completion(location)
            } else {
                completion(nil)
            }
        }
    }

    private func updateRegion() {
        // Create a region that encompasses both start and destination
        let points = [startLocation.coordinate, destinationLocation.coordinate]
        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLon = Double.greatestFiniteMagnitude
        var maxLon = -Double.greatestFiniteMagnitude

        for point in points {
            minLat = min(minLat, point.latitude)
            maxLat = max(maxLat, point.latitude)
            minLon = min(minLon, point.longitude)
            maxLon = max(maxLon, point.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )

        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: center, span: span)
        }
    }

    func fetchRoutes() {
        self.isLoading = true
        self.errorMessage = nil

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation.coordinate))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Error calculating routes: \(error.localizedDescription)"
                    return
                }

                guard let routes = response?.routes else {
                    self.errorMessage = "No routes found"
                    return
                }

                let now = Date()
                var routeOptions: [RouteOption] = []

                for (index, route) in routes.prefix(3).enumerated() {
                    let eta = now.addingTimeInterval(route.expectedTravelTime)
                    let routeOption = RouteOption(
                        duration: route.expectedTravelTime,
                        distance: route.distance,
                        eta: eta,
                        polyline: route.polyline,
                        isSelected: index == 0
                    )
                    routeOptions.append(routeOption)
                }

                self.routes = routeOptions.sorted(by: { $0.duration < $1.duration })
                self.selectedRouteIndex = 0
            }
        }
    }

    func selectRoute(at index: Int) {
        guard index < routes.count else { return }
        self.selectedRouteIndex = index
    }

    func openInAppleMaps() {
        let s = startLocation.coordinate
        let d = destinationLocation.coordinate
        let urlString = "maps://?saddr=\(s.latitude),\(s.longitude)&daddr=\(d.latitude),\(d.longitude)&dirflg=d"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

struct NavigationMapView: View {
    @StateObject private var viewModel: NavigationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(from startLocation: String, to destinationLocation: String) {
        _viewModel = StateObject(wrappedValue: NavigationViewModel(
            start: startLocation,
            destination: destinationLocation
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            MapWithOverlays(
                region: $viewModel.region,
                startLocation: viewModel.startLocation,
                destinationLocation: viewModel.destinationLocation,
                routes: viewModel.routes,
                selectedRouteIndex: viewModel.selectedRouteIndex
            )
            .edgesIgnoringSafeArea(.all)

            // Navigation UI overlay
            VStack(spacing: 0) {
                // Top buttons
                ZStack {
                    VStack {
                        HStack {
                            // Back button
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            }

                            Spacer()

                            // SOS Button
                            Button(action: {}) {
                                Text("SOS")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(14)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                        }
                        .padding()

                        Spacer()
                    }

                    // Route time indicators
                    if !viewModel.routes.isEmpty && viewModel.selectedRouteIndex != nil {
                        RouteTimeBadges(routes: viewModel.routes)
                    }
                }

                // Map controls
                VStack(spacing:0) {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "map")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                            }

                            Button(action: {}) {
                                Image(systemName: "location.north.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding(.trailing)
                    }
                }

                Spacer()
            }

            // Bottom sheet with directions
            VStack(spacing: 0) {
                // Header bar
                Spacer()
                ZStack(alignment: .top) {
                    Color.blue
                        .clipShape(RoundedCornerShape(radius: 28, corners: [.topLeft, .topRight]))
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Directions")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            Text("to \(viewModel.destinationLocation.name)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.15))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 18)
                }
                .frame(height: 110)
                
                // Route options card
                if viewModel.isLoading {
                    ProgressView("Calculating routes...")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(28, corners: [.topLeft, .topRight])
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(28, corners: [.topLeft, .topRight])
                } else if viewModel.routes.isEmpty {
                    Text("No routes available")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(28, corners: [.topLeft, .topRight])
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.routes.enumerated()), id: \.element.id) { index, route in
                            RouteOptionView(
                                duration: route.durationText,
                                eta: route.etaText,
                                distance: route.distanceText,
                                isSelected: viewModel.selectedRouteIndex == index,
                                action: {
                                    viewModel.selectRoute(at: index)
                                },
                                navigateAction: {
                                    viewModel.openInAppleMaps()
                                }
                            )
                            if index < viewModel.routes.count - 1 {
                                Divider()
                                    .padding(.leading, 24)
                                    .padding(.trailing, 24)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(28, corners: [.topLeft, .topRight])
                    .padding(.top, -28)
                    .padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .edgesIgnoringSafeArea(.bottom)

            // Home indicator
            Rectangle()
                .frame(width: 134, height: 5)
                .cornerRadius(2.5)
                .foregroundColor(.black)
                .padding(.vertical, 8)
                .background(Color.white)
        }
        .navigationBarHidden(true)
    }
}


struct MapWithOverlays: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let startLocation: Location
    let destinationLocation: Location
    let routes: [RouteOption]
    let selectedRouteIndex: Int?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.region = region
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.region = region

        // Remove all overlays and annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)

        // Add start and destination annotations
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = startLocation.coordinate
        startAnnotation.title = startLocation.name

        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationLocation.coordinate
        destinationAnnotation.title = destinationLocation.name

        mapView.addAnnotations([startAnnotation, destinationAnnotation])

        // Add route overlays
        for (index, route) in routes.enumerated() {
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            if index == selectedRouteIndex {
                // Ensure the selected route is visible
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 300, right: 100), animated: true)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapWithOverlays

        init(_ parent: MapWithOverlays) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)

                // Find which route this polyline belongs to
                if let index = parent.routes.firstIndex(where: { $0.polyline === polyline }) {
                    if index == parent.selectedRouteIndex {
                        renderer.strokeColor =  UIColor(red: 57/255, green: 107/255, blue: 175/255, alpha: 1.0) // Hex #396BAF
                        renderer.lineWidth = 5
                    } else {
                        renderer.strokeColor = UIColor(red: 57/255, green: 107/255, blue: 175/255, alpha: 0.5) // Hex #396BAF with transparency
                        renderer.lineWidth = 3
                    }
                } else {
                    renderer.strokeColor = UIColor.gray
                    renderer.lineWidth = 3
                }

                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "LocationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            // Customize based on start or destination
            if annotation.coordinate.latitude == parent.startLocation.coordinate.latitude &&
                annotation.coordinate.longitude == parent.startLocation.coordinate.longitude {
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .blue
            } else {
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .red
            }

            return annotationView
        }
    }
}

struct RouteTimeBadges: View {
    let routes: [RouteOption]

    var body: some View {
        GeometryReader { geometry in
            // This is a simplified approach - in a real app you'd calculate positions
            // based on the actual route polyline points
            ZStack {
                // Route 1 badge (fastest)
                if routes.count > 0 {
                    VStack {
                        Spacer().frame(height: geometry.size.height * 0.6)
                        HStack {
                            Text("\(routes[0].durationText)\nFastest")
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.center)
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            Spacer()
                        }
                        .padding(.leading, 60)
                        Spacer()
                    }
                }

                // Route 2 badge
                if routes.count > 1 {
                    VStack {
                        Spacer().frame(height: geometry.size.height * 0.15)
                        HStack {
                            Spacer().frame(width: geometry.size.width * 0.65)
                            Text(routes[1].durationText)
                                .font(.system(size: 14, weight: .medium))
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(10)
                            Spacer()
                        }
                        Spacer()
                    }
                }

                // Route 3 badge
                if routes.count > 2 {
                    VStack {
                        Spacer().frame(height: geometry.size.height * 0.3)
                        HStack {
                            Text(routes[2].durationText)
                                .font(.system(size: 14, weight: .medium))
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(10)
                            Spacer()
                        }
                        .padding(.leading, geometry.size.width * 0.2)
                        Spacer()
                    }
                }
            }
        }
    }
}


import SwiftUI

struct RouteOptionView: View {
    let duration: String
    let eta: String
    let distance: String
    let isSelected: Bool
    let action: () -> Void
    let navigateAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(duration)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                HStack(spacing: 8) {
                    Text(eta)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.gray)
                    Text("•")
                        .foregroundColor(.gray)
                    Text(distance)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 18)
            .padding(.leading, 24)
            .onTapGesture(perform: action)
            Spacer()
            NavigationLink(
                destination: MoveToDirections(), // Navigate to MoveToDirections when button is clicked
                label: {
                    Text("GO")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 44)
                        .background(Color.green)
                        .cornerRadius(12)
                }
            )
            .padding(.trailing, 24)
        }
        .background(Color.white)
    }
}


// Extension to apply corner radius to specific corners
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCornerShape(radius: radius, corners: corners))
//    }
//}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

