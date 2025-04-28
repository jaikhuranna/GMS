import SwiftUI
import MapKit
import FirebaseFirestore

struct RouteLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct ScheduleTripView: View {

    let vehicle: Vehicle
    @Environment(\.presentationMode) private var presentation

    @State private var journeyDate = Date()
    @State private var showingDatePicker = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.2958, longitude: 76.6394),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    @State private var routeLocations: [RouteLocation] = []

    @State private var availableDrivers: [FleetDriver] = []
    @State private var selectedDriverId: String?

    @StateObject private var startSearchService = LocationSearchService()
    @StateObject private var endSearchService = LocationSearchService()

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // DATE Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.headline)
                            .foregroundColor(Color(hex: "396BAF"))

                        Button(action: {
                            showingDatePicker.toggle()
                        }) {
                            HStack {
                                Text("Date of Journey")
                                    .foregroundColor(.gray)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(journeyDate, style: .date)
                                        .foregroundColor(Color(hex: "396BAF"))
                                    Text(journeyDate, style: .time)
                                        .foregroundColor(Color(hex: "396BAF"))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "396BAF"), lineWidth: 1)
                            )
                        }

                        if showingDatePicker {
                            DatePicker("", selection: $journeyDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()
                                .onChange(of: journeyDate) { _ in showingDatePicker = false }
                        }
                    }
                    .padding(.horizontal)

                    // MAP VIEW
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Map View")
                            .font(.headline)
                            .foregroundColor(Color(hex: "396BAF"))

                        Group {
                            if routeLocations.count == 2 {
                                RouteMapView(
                                    startCoordinate: routeLocations[0].coordinate,
                                    endCoordinate: routeLocations[1].coordinate,
                                    region: $region
                                )
                            } else {
                                Map(coordinateRegion: $region)
                            }
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)


                    // LOCATION DETAILS
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location Details")
                            .font(.headline)
                            .foregroundColor(Color(hex: "396BAF"))

                        VStack(spacing: 16) {
                            // Start Location Search
                            VStack(alignment: .leading) {
                                TextField("Start Point", text: $startSearchService.queryFragment)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "396BAF"), lineWidth: 1)
                                    )

                                ForEach(startSearchService.searchResults, id: \.self) { result in
                                    Button(action: {
                                        startSearchService.queryFragment = result.title
                                        startPoint = result.title
                                        startSearchService.selectLocation(completion: result) { coordinate in
                                            if let coord = coordinate {
                                                updateStartLocation(coord)
                                            }
                                        }
                                        startSearchService.searchResults = []
                                    }) {
                                        Text(result.title)
                                            .foregroundColor(.primary)
                                            .padding(.vertical, 4)
                                    }
                                }
                            }

                            // End Location Search
                            VStack(alignment: .leading) {
                                TextField("End Point", text: $endSearchService.queryFragment)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "396BAF"), lineWidth: 1)
                                    )

                                ForEach(endSearchService.searchResults, id: \.self) { result in
                                    Button(action: {
                                        endSearchService.queryFragment = result.title
                                        endPoint = result.title
                                        endSearchService.selectLocation(completion: result) { coordinate in
                                            if let coord = coordinate {
                                                updateEndLocation(coord)
                                            }
                                        }
                                        endSearchService.searchResults = []
                                    }) {
                                        Text(result.title)
                                            .foregroundColor(.primary)
                                            .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // AVAILABLE DRIVERS
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Drivers")
                            .font(.headline)
                            .foregroundColor(Color(hex: "396BAF"))

                        if availableDrivers.isEmpty {
                            Text("Loading…")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(availableDrivers) { drv in
                                HStack(spacing: 12) {
                                    Image("person") // Replace with real image or system
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Name : \(drv.name)")
                                            .foregroundColor(Color(hex: "396BAF"))
                                        Text("Experience : \(drv.experience) yrs")
                                            .foregroundColor(Color(hex: "396BAF"))
                                        Text("License Type : \(drv.licenseType.rawValue)")
                                            .foregroundColor(Color(hex: "396BAF"))
                                    }
                                    Spacer()

                                    if drv.id.uuidString == selectedDriverId {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .background(Color(hex: "EAF0FB"))
                                .cornerRadius(16)
                                .onTapGesture {
                                    selectedDriverId = drv.id.uuidString
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // DONE BUTTON
                    Button(action: {
                        scheduleTrip()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "396BAF"))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .disabled(selectedDriverId == nil)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Schedule Trip")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchIdleDrivers()
            }
        }
    }

    private func updateRoute() {
        let start = CLLocationCoordinate2D(latitude: 12.2958, longitude: 76.6394)
        let end = CLLocationCoordinate2D(latitude: 12.3058, longitude: 76.6494)

        routeLocations = [
            RouteLocation(name: startPoint, coordinate: start),
            RouteLocation(name: endPoint, coordinate: end)
        ]

        let center = CLLocationCoordinate2D(
            latitude: (start.latitude + end.latitude) / 2,
            longitude: (start.longitude + end.longitude) / 2
        )
        region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }

    private func updateStartLocation(_ coordinate: CLLocationCoordinate2D) {
        if routeLocations.count > 0 {
            routeLocations[0] = RouteLocation(name: startPoint, coordinate: coordinate)
        } else {
            routeLocations.append(RouteLocation(name: startPoint, coordinate: coordinate))
        }
        updateRegionIfPossible()
    }

    private func updateEndLocation(_ coordinate: CLLocationCoordinate2D) {
        if routeLocations.count > 1 {
            routeLocations[1] = RouteLocation(name: endPoint, coordinate: coordinate)
        } else if routeLocations.count == 1 {
            routeLocations.append(RouteLocation(name: endPoint, coordinate: coordinate))
        } else {
            routeLocations.append(RouteLocation(name: startPoint, coordinate: coordinate))
            routeLocations.append(RouteLocation(name: endPoint, coordinate: coordinate))
        }
        updateRegionIfPossible()
    }

    private func updateRegionIfPossible() {
        guard routeLocations.count == 2 else { return }
        let lat = (routeLocations[0].coordinate.latitude + routeLocations[1].coordinate.latitude) / 2
        let lon = (routeLocations[0].coordinate.longitude + routeLocations[1].coordinate.longitude) / 2
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                     span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }

    private func fetchIdleDrivers() {
        db.collection("fleetDrivers").getDocuments { snap, _ in
            let all = snap?.documents.compactMap {
                try? $0.data(as: FleetDriver.self)
            } ?? []

            db.collection("bookingRequests")
                .whereField("status", isEqualTo: "inProgress")
                .getDocuments { tsnap, _ in
                    let busy = Set(tsnap?.documents.compactMap {
                        $0["driverId"] as? String
                    } ?? [])
                    availableDrivers = all.filter {
                        !busy.contains($0.id.uuidString)
                    }
                }
        }
    }

    private func scheduleTrip() {
        guard let driverId = selectedDriverId else { return }
        let docRef = db.collection("bookingRequests").document()

        let data: [String: Any] = [
            "driverId": driverId,
            "driverName": availableDrivers.first { $0.id.uuidString == driverId }?.name ?? "",
            "vehicleId": vehicle.id,
            "vehicleNo": vehicle.vehicleNo,
            "pickupName": startPoint,
            "dropoffName": endPoint,
            "distanceKm": 0,
            "status": "pending",
            "createdAt": Timestamp(date: journeyDate)
        ]

        docRef.setData(data) { err in
            if let e = err {
                print("❌ Scheduling failed:", e)
            } else {
                presentation.wrappedValue.dismiss()
            }
        }
    }
}
