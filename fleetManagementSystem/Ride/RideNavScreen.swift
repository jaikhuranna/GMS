import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

// MARK: - Models

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct RouteOption: Identifiable {
    let id = UUID()
    let duration: TimeInterval
    let distance: CLLocationDistance
    let eta: Date
    let polyline: MKPolyline
    var isSelected: Bool = false

    var durationText: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
    var subText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let etaString = formatter.string(from: eta)
        let km = String(format: "%.0f km", distance/1000)
        return "\(etaString) ETA • \(km)"
    }
    var etaText: String {
      let fmt = DateFormatter()
      fmt.dateFormat = "h:mm a"
      return fmt.string(from: eta)
    }
}

// MARK: - ViewModel

class NavigationViewModel: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion()
    @Published var startLocation: Location?
    @Published var destinationLocation: Location?
    @Published var routes: [RouteOption] = []
    @Published var selectedRouteIndex: Int? = nil
    @Published var isLoading = false
    @Published var isLoadingBookingRequest = true
    @Published var errorMessage: String? = nil
    @Published var isNavigating = false
    @Published var hasArrived = false
    
   
    let driverId: String
    let authViewModel: AuthViewModel

   

    // Real-time navigation state
    @Published var currentStepText: String = ""
    @Published var distanceToNextStep: CLLocationDistance = 0
    @Published var timeToNextStep: TimeInterval = 0
    @Published var isOffRoute: Bool = false
    private var offRouteNotified = false

    
    @Published var distanceCovered: CLLocationDistance = 0
    
    var distanceToNextStepText: String {
        if distanceToNextStep >= 1000 {
            let km = distanceToNextStep / 1000
            return String(format: "%.1f km", km)
        } else {
            return String(format: "%dm", Int(distanceToNextStep))
        }
    }
    var timeToNextStepText: String {
 
        guard timeToNextStep.isFinite && timeToNextStep >= 0 else {
            return "0m"
        }
        let mins = Int(timeToNextStep / 60)
        return "\(mins)m"
    }


    private let db = Firestore.firestore()
    private var locationManager = CLLocationManager()
    private var currentDirections: MKDirections?
    private var currentMKRoutes: [MKRoute] = []
    
    var navigationSteps: [MKRoute.Step] = []
    private var currentStepIndex = 0
    private var userLocation: CLLocation?
    private var fullRoutePolyline: MKPolyline?

    let bookingRequestID: String
    let vehicleNumber: String
    

    init( driverId: String,bookingRequestID: String, vehicleNumber: String, viewModel: AuthViewModel) {
        self.driverId         = driverId
        self.bookingRequestID = bookingRequestID
        self.vehicleNumber = vehicleNumber
        self.authViewModel = viewModel
        
        super.init()
        setupLocationManager()
        fetchBookingRequest()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func fetchBookingRequest() {
        db.collection("bookingRequests").document(bookingRequestID)
          .getDocument { [weak self] snap, err in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingBookingRequest = false
                if let err = err {
                    self.errorMessage = err.localizedDescription
                    return
                }
                guard
                    let d = snap?.data(),
                    let lat1 = d["pickupLatitude"] as? Double,
                    let lon1 = d["pickupLongitude"] as? Double,
                    let name1 = d["pickupName"] as? String,
                    let lat2 = d["dropoffLatitude"] as? Double,
                    let lon2 = d["dropoffLongitude"] as? Double,
                    let name2 = d["dropoffName"] as? String
                else {
                    self.errorMessage = "Bad trip data"
                    return
                }
                self.startLocation = Location(name: name1,
                                              coordinate: CLLocationCoordinate2D(latitude: lat1, longitude: lon1))
                self.destinationLocation = Location(name: name2,
                                                   coordinate: CLLocationCoordinate2D(latitude: lat2, longitude: lon2))
                self.updateRegion()
                self.fetchRoutes()
            }
        }
    }

    private func updateRegion() {
        guard let s = startLocation?.coordinate,
              let e = destinationLocation?.coordinate else { return }
        let lats = [s.latitude, e.latitude]
        let lons = [s.longitude, e.longitude]
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (lats.min()! + lats.max()!) / 2,
                longitude: (lons.min()! + lons.max()!) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: (lats.max()! - lats.min()!) * 1.4,
                longitudeDelta: (lons.max()! - lons.min()!) * 1.4
            )
        )
    }

    func fetchRoutes() {
        guard let start = startLocation, let end = destinationLocation else { return }
        isLoading = true; errorMessage = nil
        currentDirections?.cancel()
        let req = MKDirections.Request()
        req.source = MKMapItem(placemark: MKPlacemark(coordinate: start.coordinate))
        req.destination = MKMapItem(placemark: MKPlacemark(coordinate: end.coordinate))
        req.transportType = .automobile
        req.requestsAlternateRoutes = true

        let directions = MKDirections(request: req)
        currentDirections = directions
        directions.calculate { [weak self] resp, err in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                if let err = err {
                    self.errorMessage = err.localizedDescription
                    return
                }
                guard let mkRoutes = resp?.routes, !mkRoutes.isEmpty else {
                    self.errorMessage = "No routes found"
                    return
                }
                self.currentMKRoutes = mkRoutes
                let now = Date()
                self.routes = mkRoutes.prefix(3).map { rt in
                    RouteOption(
                        duration: rt.expectedTravelTime,
                        distance: rt.distance,
                        eta: now.addingTimeInterval(rt.expectedTravelTime),
                        polyline: rt.polyline
                    )
                }
                for i in self.routes.indices {
                    self.routes[i].isSelected = (i == 0)
                }
                self.selectedRouteIndex = 0
            }
        }
    }

    func selectRoute(at i: Int) {
        guard i < routes.count else { return }
        for idx in routes.indices {
            routes[idx].isSelected = (idx == i)
        }
        selectedRouteIndex = i
    }

//    func startNavigation() {
//        guard let idx = selectedRouteIndex else { return }
//        let route = currentMKRoutes[idx]
//        // store full route for off-route detection
//        fullRoutePolyline = route.polyline
//
//        navigationSteps = route.steps
//        currentStepIndex = 0
//        isNavigating = true
//        hasArrived = false
//        isOffRoute = false
//        locationManager.startUpdatingLocation()
//    }

    
    func startNavigation() {
        guard let idx = selectedRouteIndex else { return }
        let route = currentMKRoutes[idx]

        // ➊ store full route
        fullRoutePolyline = route.polyline
        navigationSteps    = route.steps
        currentStepIndex   = 0
        isNavigating       = true
        hasArrived         = false
        isOffRoute         = false

        // ➋ initialize the very first step from last-known‐location
        if let firstStep = navigationSteps.first,
           let loc = locationManager.location {
            currentStepText = firstStep.instructions

            // distance to end of that step
            let coords = firstStep.polyline.coordinates
            if let end = coords.last {
                let endLoc = CLLocation(latitude: end.latitude, longitude: end.longitude)
                distanceToNextStep = loc.distance(from: endLoc)
            }

            // pro-rate the step's time
            let stepFullTime = (firstStep.distance / route.distance) * route.expectedTravelTime
            let fraction     = distanceToNextStep / firstStep.distance
            timeToNextStep   = stepFullTime * fraction
        }

        locationManager.startUpdatingLocation()
    }

    /// Public: re-run navigation from current GPS position
    func reroute() {
        guard let currentLoc = userLocation?.coordinate else { return }
        recalculateRoute(from: currentLoc)
    }

    /// Internal: calculate a fresh route from `from` to dropoff
    private func recalculateRoute(from: CLLocationCoordinate2D) {
        guard let dest = destinationLocation else { return }
        currentDirections?.cancel()
        let req = MKDirections.Request()
        req.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        req.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest.coordinate))
        req.transportType = .automobile
        req.requestsAlternateRoutes = false

        let directions = MKDirections(request: req)
        currentDirections = directions
        directions.calculate { [weak self] resp, err in
            DispatchQueue.main.async {
                guard let self = self, let route = resp?.routes.first else { return }
                self.fullRoutePolyline = route.polyline
                self.currentMKRoutes = [route]
                self.navigationSteps = route.steps
                self.currentStepIndex = 0
                self.isOffRoute = false
                self.isNavigating = true
                self.hasArrived = false
                self.locationManager.startUpdatingLocation()
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension NavigationViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
        
        guard isNavigating, let loc = locs.last else { return }
        userLocation = loc
        
        // 1️⃣ Off‐route detection
        //            if let poly = fullRoutePolyline {
        //                let offDist = poly.closestDistance(to: loc.coordinate)
        //                if offDist > 50 {      // 50 m threshold
        //                    isOffRoute = true
        //                    manager.stopUpdatingLocation()
        //                    return
        //                }
        //            }
        if let poly = fullRoutePolyline {
            let offDist = poly.closestDistance(to: loc.coordinate)
            if offDist > 50 {      // 50 m threshold
                isOffRoute = true
                manager.stopUpdatingLocation()
                
                if !offRouteNotified {
                    offRouteNotified = true
                    sendOffRouteAlert(driverLocation: loc)
                }
                return
            }
        }
        // 2️⃣ Are we done with all steps?
        guard currentStepIndex < navigationSteps.count else {
            manager.stopUpdatingLocation()
            isNavigating = false
            hasArrived = true
            return
        }
        
        // 3️⃣ Compute distance to end of current step
        let step = navigationSteps[currentStepIndex]
        let coords = step.polyline.coordinates
        guard let endCoord = coords.last else { return }
        let endLoc = CLLocation(latitude: endCoord.latitude, longitude: endCoord.longitude)
        let dist = loc.distance(from: endLoc)
        distanceToNextStep = dist
        
        // 4️⃣ Compute time remaining for this step
        if dist > 0,
           let sel = selectedRouteIndex,
           currentMKRoutes.indices.contains(sel)
        {
            let route = currentMKRoutes[sel]
            let fraction     = dist / step.distance
            let stepFullTime = (step.distance / route.distance) * route.expectedTravelTime
            timeToNextStep   = stepFullTime * fraction
        } else {
            timeToNextStep = 0
        }
        
        
        let completed = navigationSteps
            .prefix(currentStepIndex)
            .reduce(0) { $0 + $1.distance }
        
        let doneOnThisStep = max(
            0,
            step.distance - distanceToNextStep
        )
        
        distanceCovered = completed + doneOnThisStep
        
        
        // 6️⃣ Update the UI text
        currentStepText = step.instructions
        
        // 7️⃣ Advance when we're within ~20 m of the maneuver point
        if dist < 20 {
            currentStepIndex += 1
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    private func sendOffRouteAlert(driverLocation loc: CLLocation) {
        // Apple Maps URL to show driver's location
        let mapsURL = "http://maps.apple.com/?ll=\(loc.coordinate.latitude),\(loc.coordinate.longitude)&q=Driver%20Location"
        
        let notifData: [String: Any] = [
            "title": "Off-Route Alert",
            "body":  "Driver \(driverId) (vehicle \(vehicleNumber)) has left the assigned route.",
            "tripId": bookingRequestID,
            "driverId": driverId,
            "vehicleNumber": vehicleNumber,
            "location": GeoPoint(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude
            ),
            "mapsUrl": mapsURL,
            "recipients": ["fleet_manager"],   // only fleet managers see this
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("notifications")
            .addDocument(data: notifData) { error in
                if let error = error {
                    print("❌ Failed to send off-route alert:", error)
                } else {
                    print("✅ Off-route alert sent to fleet manager")
                }
            }
    }
}

// MARK: - MKPolyline helper

extension MKPolyline {
    /// Returns the minimum distance from `point` to any vertex on the polyline
    func closestDistance(to point: CLLocationCoordinate2D) -> CLLocationDistance {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                             count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        let loc = CLLocation(latitude: point.latitude, longitude: point.longitude)
        return coords
            .map { CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: loc) }
            .min() ?? .greatestFiniteMagnitude
    }
    /// Convenience to pull all coordinates
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                             count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

// MARK: - Off-Route Sheet

struct OffRouteSheet: View {
    @Binding var isPresented: Bool
    let onViewRoute: () -> Void
    let onContactManager: () -> Void

    @State private var countdown = 30
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { /* block taps */ }

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(spacing: 28) {
                    Capsule()
                        .frame(width: 48, height: 6)
                        .foregroundColor(Color.gray.opacity(0.18))
                        .padding(.top, 18)
                        .padding(.bottom, 8)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.yellow)
                        .padding(.bottom, 2)

                    Text("You're off the route")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 2)

                    Text("Your current location is outside the defined geofence boundary. Please return to the assigned route to avoid delays or violations.")
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)

                    VStack(spacing: 14) {
                        Button(action: {
                            isPresented = false
                            onViewRoute()
                        }) {
                            Text("View Route")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 57/255, green: 107/255, blue: 175/255))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        Button(action: {
                            onContactManager()
                        }) {
                            Text("Contact Manager (\(countdown)s)")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .background(Color.white)
                .cornerRadius(28)
                .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 8)
                .frame(maxWidth: 420)
                Spacer(minLength: 0)
            }
            .onReceive(timer) { _ in
                if countdown > 0 { countdown -= 1 }
            }
        }
    }
}


struct NavigationMapView: View {
    
    
    @StateObject private var vm: NavigationViewModel
    @State private var showArrived       = false
    @State private var showPostTrip      = false
    @State private var showTripCompleted = false
    let driverId: String
    @State private var navigateToSOS = false
    @Environment(\.presentationMode) private var presentationMode


    @ObservedObject var viewModel: AuthViewModel

    init(driverId: String, bookingRequestID: String, vehicleNumber: String, viewModel: AuthViewModel) {
        self.driverId = driverId
        self.viewModel = viewModel // Initialize the viewModel property
        
        _vm = StateObject(
            wrappedValue: NavigationViewModel(
                driverId: driverId,
                bookingRequestID: bookingRequestID,
                vehicleNumber: vehicleNumber,
                viewModel: viewModel
            )
        )
    }

    var body: some View {
        ZStack {
            // 1) Full‑screen map
            MapWithNavigation(vm: vm)
                .ignoresSafeArea()

            // 2) Header + TBT banner
            VStack(spacing: 0) {
                header
                if vm.isNavigating {
                    turnByTurnBanner
                } else {
                    statsBanner
                }

                Spacer()
            }

            // 3) Summary overlay
            if vm.isNavigating && !vm.hasArrived {
                summaryOverlay
            }

            // 4) Bottom sheet container
            bottomSheet

            // 5) Off‑route overlay
            if vm.isOffRoute {
                OffRouteSheet(
                    isPresented: $vm.isOffRoute,
                    onViewRoute: vm.reroute,
                    onContactManager: { /*…*/ }
                )
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: vm.isOffRoute)
            }
        }
        // 6) Post‑trip inspection full‑screen cover
        .fullScreenCover(
            isPresented: $showPostTrip,
            onDismiss: {
                withAnimation { showTripCompleted = true }
            }
        ) {
            NavigationView {
                InspectionbeforeRide(
                    bookingRequestID: vm.bookingRequestID,
                    vehicleNumber:   vm.vehicleNumber,
                    phase:           .post,
                    driverId: driverId, viewModel: viewModel
                  
               
                )
                .navigationBarHidden(true)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: – Components

    private var header: some View {
        HStack(alignment: .top) {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
            }
            Text("Proceed to \(vm.destinationLocation?.name ?? "")")
                .foregroundColor(.white)
                .font(.title2).bold()
                .lineLimit(2)
                .padding(.leading, 8)
            Spacer()
            NavigationLink(
              destination: EmergencyHelpView(),
              isActive: $navigateToSOS
            ) { EmptyView() }
            Button { navigateToSOS = true } label: {
                Text("SOS")
                    .font(.subheadline).bold()
                    .padding(8)
                    .background(Color.red)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.white)
                .padding(.leading, 8)
        }
        .padding()
        .background(Color(red: 57/255, green: 107/255, blue: 175/255))
    }
    private var statsBanner: some View {
         // figure out which route is selected, if any
         let idx   = vm.selectedRouteIndex ?? 0
         let total = (vm.routes.indices.contains(idx) ? vm.routes[idx].distance : 0)
         let rem   = max(0, total - vm.distanceCovered)

         return HStack {
             Button { /* share action */ } label: {
                 Image(systemName: "square.and.arrow.up")
             }
             Spacer()

             Text(String(format: "%.1f km", vm.distanceCovered / 1000))
             Text("•")
             Text(String(format: "%.1f km", rem / 1000))
         }
         .padding()
         .background(Color.black.opacity(0.8))
         .foregroundColor(.white)
     }

     // MARK: – Once you've tapped "GO" and location updates are flowing
     private var turnByTurnBanner: some View {
         HStack {
             Image(systemName: currentManeuverIcon)
             Text(vm.currentStepText)
                 .lineLimit(1)
             Spacer()
             Text(vm.distanceToNextStepText)
             Text("•")
             Text(vm.timeToNextStepText)
         }
         .padding()
         .background(Color.black.opacity(0.8))
         .foregroundColor(.white)
     }

     // Simple heuristic to choose an arrow icon
     private var currentManeuverIcon: String {
         let t = vm.currentStepText.lowercased()
         if t.contains("left")  { return "arrow.turn.up.left"  }
         if t.contains("right") { return "arrow.turn.up.right" }
         if t.contains("straight") || t.contains("continue") {
             return "arrow.up"
         }
         return "arrow.up"
     }
 

    private var summaryOverlay: some View {
        let sel   = vm.selectedRouteIndex ?? 0
        let route = vm.routes[sel]
        return VStack { Spacer() }
            .frame(maxWidth: .infinity)
            .overlay(
                NavigationSummaryView(
                    eta:      route.etaText,
                    duration: route.durationText,
                    distance: String(format: "%.0f", vm.distanceCovered/1000),
                    onExpand: { withAnimation { showArrived = true } }
                ),
                alignment: .bottom
            )
    }

    private var bottomSheet: some View {
        VStack {
            Spacer()

            // A) Inline ArrivalSheet when chevron tapped
            if showArrived {
                ArrivalSheet(name: vm.destinationLocation?.name ?? "") {
                    withAnimation { showArrived = false }
                    showPostTrip = true
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showArrived)

            // B) Arrival triggered by the VM
            } else if vm.hasArrived {
                ArrivalSheet(name: vm.destinationLocation?.name ?? "") {
                    presentationMode.wrappedValue.dismiss()
                    showPostTrip = true
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: vm.hasArrived)

            // C) Route selection before navigation
            } else if !vm.isNavigating {
                RouteSelectionSheet(vm: vm, viewModel: viewModel, onGo: vm.startNavigation)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: vm.isNavigating)

            // D) Finally, the inline Trip Completed card
            }else if showTripCompleted {
                TripCompletedCard(
                    bookingRequestID: vm.bookingRequestID,
                    onHideOverlay: {
                           withAnimation { showTripCompleted = false }
                         },
                    viewModel: AuthViewModel()
                )
                .background(Color.white)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .padding(.horizontal)
                .padding(.bottom,
                    UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                )
            }
            }
            .zIndex(1)
          }
}


struct NavigationSummaryView: View {
    let eta: String
    let duration: String
    let distance: String
    let onExpand: () -> Void

    var body: some View {
        HStack {
            // ETA
            VStack(alignment: .leading) {
                Text(eta)
                  .font(.headline)
                  .foregroundColor(.primary)
                Text("arrival")
                  .font(.subheadline)
                  .foregroundColor(.gray)
            }

            Spacer()

            // Duration
            VStack {
                Text(duration)
                  .font(.headline)
                  .foregroundColor(.primary)
                Text("hrs")
                  .font(.subheadline)
                  .foregroundColor(.gray)
            }

            Spacer()

            // Distance
            VStack {
                Text(distance)
                  .font(.headline)
                  .foregroundColor(.primary)
                Text("km")
                  .font(.subheadline)
                  .foregroundColor(.gray)
            }

            Spacer()

            // Chevron button only
            Button(action: onExpand) {
                Image(systemName: "chevron.up")
                  .font(.headline)
                  .foregroundColor(.primary)
            }
            .padding(.trailing, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(radius: 5)
    }
}




    // ... rest of your RouteSelectionSheet, ArrivalSheet, MapWithNavigation, etc., unchanged ...
    
    
//    struct MapWithNavigation: UIViewRepresentable {
//        @ObservedObject var vm: NavigationViewModel
//        
//        func makeUIView(context: Context) -> MKMapView {
//            let mv = MKMapView()
//            mv.delegate = context.coordinator
//            mv.showsUserLocation = true
//            mv.userTrackingMode = .followWithHeading
//            mv.setRegion(vm.region, animated: false)
//            return mv
//        }
//        
//        func updateUIView(_ mapView: MKMapView, context: Context) {
//            mapView.removeAnnotations(mapView.annotations)
//            mapView.removeOverlays(mapView.overlays)
//            if let start = vm.startLocation {
//                let ann = MKPointAnnotation()
//                ann.coordinate = start.coordinate
//                ann.title = start.name
//                mapView.addAnnotation(ann)
//            }
//            if let dest = vm.destinationLocation {
//                let ann = MKPointAnnotation()
//                ann.coordinate = dest.coordinate
//                ann.title = dest.name
//                mapView.addAnnotation(ann)
//            }
//            if let idx = vm.selectedRouteIndex {
//                let poly = vm.routes[idx].polyline
//                mapView.addOverlay(poly)
//                mapView.setVisibleMapRect(poly.boundingMapRect,
//                                          edgePadding: UIEdgeInsets(top:100, left:50, bottom:300, right:50),
//                                          animated: true)
//            }
//        }
//        
//        func makeCoordinator() -> Coordinator { Coordinator(self) }
//        class Coordinator: NSObject, MKMapViewDelegate {
//            var parent: MapWithNavigation
//            init(_ p: MapWithNavigation) { parent = p }
//            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//                guard let poly = overlay as? MKPolyline else { return MKOverlayRenderer() }
//                let r = MKPolylineRenderer(polyline: poly)
//                r.strokeColor = UIColor.systemBlue
//                r.lineWidth = 5
//                return r
//            }
//        }
//    }
//


struct MapWithNavigation: UIViewRepresentable {
    @ObservedObject var vm: NavigationViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mv = MKMapView()
        mv.delegate = context.coordinator
        mv.showsUserLocation = true
        mv.userTrackingMode = .followWithHeading
        mv.setRegion(vm.region, animated: false)
        return mv
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // 1) Annotations
        if let start = vm.startLocation {
            let ann = MKPointAnnotation()
            ann.coordinate = start.coordinate
            ann.title = start.name
            mapView.addAnnotation(ann)
        }
        if let dest = vm.destinationLocation {
            let ann = MKPointAnnotation()
            ann.coordinate = dest.coordinate
            ann.title = dest.name
            mapView.addAnnotation(ann)
        }

        // 2) Add *all* route polylines
        for route in vm.routes {
            mapView.addOverlay(route.polyline)
        }

        // 3) Zoom to the **selected** route
        if let sel = vm.selectedRouteIndex {
            let poly = vm.routes[sel].polyline
            mapView.setVisibleMapRect(
                poly.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 100, left: 50, bottom: 300, right: 50),
                animated: true
            )
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapWithNavigation
        init(_ p: MapWithNavigation) { parent = p }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let poly = overlay as? MKPolyline else { return MKOverlayRenderer() }
            let rend = MKPolylineRenderer(polyline: poly)
            
            // Find which route this polyline belongs to
            if let idx = parent.vm.routes.firstIndex(where: { $0.polyline === poly }) {
                if idx == parent.vm.selectedRouteIndex {
                    // Selected route: bold, opaque
                    rend.strokeColor = UIColor(red: 57/255, green: 107/255, blue: 175/255, alpha: 1)
                    rend.lineWidth   = 5
                } else {
                    // Alternate: lighter, thinner
                    rend.strokeColor = UIColor(red: 57/255, green: 107/255, blue: 175/255, alpha: 0.3)
                    rend.lineWidth   = 3
                }
            } else {
                // Fallback style
                rend.strokeColor = UIColor(red: 57/255, green: 107/255, blue: 175/255, alpha: 1)
                rend.lineWidth   = 5
            }

            return rend
        }
    }
}

    struct RouteSelectionSheet: View {
        @ObservedObject var vm: NavigationViewModel
        @ObservedObject var viewModel: AuthViewModel
        let onGo: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                // header
                ZStack(alignment: .top) {
                    Color(red: 57/255, green: 107/255, blue: 175/255)
                        .clipShape(RoundedCornerShape(radius: 28, corners: [.topLeft, .topRight]))
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Directions")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Text("to \(vm.destinationLocation?.name ?? "")")
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 100)
                
                // loading spinner
                if vm.isLoading {
                    ProgressView("Calculating…")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                }
                // list of route options
                else {
                    VStack(spacing: 0) {
                        ForEach(Array(vm.routes.enumerated()), id: \.offset) { offset, route in
                            RouteOptionView(
                                duration:       route.durationText,
                                eta:            route.etaText,
                                distance:       String(format: "%.0f km", route.distance/1000),
                                isSelected:     route.isSelected,
                                action:         { vm.selectRoute(at: offset) },
                                navigateAction: onGo, viewModel: viewModel
                            )
                            .padding(.horizontal)
                            
                            if offset < vm.routes.count - 1 {
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                    .background(Color.white)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }




struct ArrivalSheet: View {
    let name: String
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)

            Text("Arrived")
                .font(.title2).bold()

            Text("On your left: \(name)")
                .font(.subheadline)
                .foregroundColor(Color(red: 57/255, green: 107/255, blue: 175/255))

            HStack {
                Text("Rate your route")
                    .font(.subheadline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "hand.thumbsup.fill")
                        .foregroundColor(Color(red: 57/255, green: 107/255, blue: 175/255))
                }
                Button(action: {}) {
                    Image(systemName: "hand.thumbsdown.fill")
                        .foregroundColor(Color(red: 57/255, green: 107/255, blue: 175/255))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)

            Button(action: onEnd
                // handle end navigation
            ) {
                Text("End Navigation")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(24)
        .shadow(radius: 6)
        .padding(.horizontal)
    }
}




// MARK: - Helpers

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}

// MARK: - Badge & Option Views

struct RouteTimeBadges: View {
    let routes: [RouteOption]
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if routes.count > 0 {
                    VStack {
                        Spacer().frame(height: geo.size.height * 0.6)
                        HStack {
                            Text("\(routes[0].durationText)\nFastest")
                                .font(.system(size:14, weight:.medium))
                                .multilineTextAlignment(.center)
                                .padding(8)
                                .background(Color(red: 57/255, green: 107/255, blue: 175/255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            Spacer()
                        }
                        .padding(.leading, 60)
                        Spacer()
                    }
                }
                if routes.count > 1 {
                    VStack {
                        Spacer().frame(height: geo.size.height * 0.15)
                        HStack {
                            Spacer().frame(width: geo.size.width * 0.65)
                            Text(routes[1].durationText)
                                .font(.system(size:14, weight:.medium))
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(10)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                if routes.count > 2 {
                    VStack {
                        Spacer().frame(height: geo.size.height * 0.3)
                        HStack {
                            Text(routes[2].durationText)
                                .font(.system(size:14, weight:.medium))
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(10)
                            Spacer()
                        }
                        .padding(.leading, geo.size.width * 0.2)
                        Spacer()
                    }
                }
            }
        }
    }
}



// MARK: - RouteOptionView

struct RouteOptionView: View {
    let duration: String         // e.g. "8h 03m"
    let eta: String              // e.g. "2:44 PM"
    let distance: String         // e.g. "493 km"
    let isSelected: Bool         // highlight if this row is chosen
    let action: () -> Void       // called when row tapped
    let navigateAction: () -> Void  // called when "GO" tapped
    
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        HStack(spacing: 0) {
            // Left info
            VStack(alignment: .leading, spacing: 6) {
                Text(duration)
                    .font(.system(size: 24, weight: .bold))
                HStack(spacing: 8) {
                    Text(eta)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    Text("•")
                        .foregroundColor(.gray)
                    Text(distance)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 18)
            .padding(.leading, 24)
            .onTapGesture(perform: action)
            
            Spacer()
            
            // GO button
            Button(action: navigateAction) {
                Text("GO")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 44)
                    .background(Color(red: 57/255, green: 107/255, blue: 175/255))
                    .cornerRadius(12)
            }
            .padding(.trailing, 24)
        }
        // subtle selected highlight
        .background(isSelected ? Color(red: 57/255, green: 107/255, blue: 175/255).opacity(0.1) : Color.white)
    }
    

    
}
// MARK: - Corner Shape Extension

//struct RoundedCornerShape: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: corners,
//            cornerRadii: CGSize(width: radius, height: radius)
//        )
//        return Path(path.cgPath)
//    }
//}

// Optional View extension for cornerRadius on specific corners:
// extension View {
//   func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//     clipShape(RoundedCornerShape(radius: radius, corners: corners))
//   }
// }

// Preview
//struct NavigationMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationMapView(bookingRequestID: "5bmAikik3dNUsniUNyLB", vehicleNumber:   "MH31LK7788")
//    }
//}


struct DetailNavSheet: View {
    @ObservedObject var vm: NavigationViewModel

    var body: some View {
        VStack {
            Capsule()
              .frame(width: 40, height: 6)
              .foregroundColor(.gray.opacity(0.5))
              .padding(.top)
            Text("Route Details")
              .font(.title2).bold().padding(.bottom)
            ScrollView {
                ForEach(0 ..< vm.navigationSteps.count, id: \.self) { i in
                          let step = vm.navigationSteps[i]
                          VStack(alignment: .leading, spacing: 4) {
                            Text(step.instructions)
                            Text(String(format: "%.0f m", step.distance))
                              .font(.footnote)
                              .foregroundColor(.gray)
                          }
                    .padding(.horizontal)
                    Divider()
                }
            }
        }
    }
}
