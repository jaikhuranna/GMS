// ScheduleTripView.swift

import SwiftUI
import MapKit
import FirebaseFirestore


// MARK: – Models

/// A simple wrapper for a point on the route
struct RouteLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

// MARK: – Main View

struct ScheduleTripView: View {
    let vehicle: Vehicle
    @Environment(\.presentationMode) private var presentation

    // Date picker
    @State private var journeyDate = Date()
    @State private var showingDatePicker = false

    // Map region
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.2958, longitude: 76.6394),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    // User-entered start/end
    @State private var startPoint = ""
    @State private var endPoint   = ""

    // Once user taps a search result, we stash the coordinates here
    @State private var routeLocations: [RouteLocation] = []

    // Driver picker
    @State private var availableDrivers: [FleetDriver] = []
    @State private var selectedDriverId: String?

    // Our search-on-type helpers (defined elsewhere)
    @StateObject private var startSearchService = LocationSearchService()
    @StateObject private var endSearchService   = LocationSearchService()

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 1) Date
                    DateSection(
                        journeyDate: $journeyDate,
                        showingDatePicker: $showingDatePicker
                    )

                    // 2) Map preview
                    MapSection(
                        region: $region,
                        routeLocations: routeLocations
                    )

                    // 3) Search + pick start/end
                    LocationSection(
                        startPoint: $startPoint,
                        endPoint: $endPoint,
                        startSearchService: startSearchService,
                        endSearchService: endSearchService,
                        onSelectStart: updateStartLocation,
                        onSelectEnd:   updateEndLocation
                    )

                    // 4) Driver picker
                    DriversSection(
                        drivers: availableDrivers,
                        selectedDriverId: $selectedDriverId
                    )

                    // 5) Done button
                    DoneButton(
                        isDisabled: selectedDriverId == nil
                                    || routeLocations.count < 2
                                    || journeyDate < Calendar.current.startOfDay(for: Date()),
                        action: scheduleTrip
                    )
                }
                .padding(.vertical)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Schedule Trip")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: fetchIdleDrivers)
        }
    }

    // MARK: – Location & Region Updates

    private func updateStartLocation(_ coordinate: CLLocationCoordinate2D) {
        let loc = RouteLocation(name: startPoint, coordinate: coordinate)
        if routeLocations.isEmpty {
            routeLocations.append(loc)
        } else {
            routeLocations[0] = loc
        }
        adjustRegionIfNeeded()
    }

    private func updateEndLocation(_ coordinate: CLLocationCoordinate2D) {
        let loc = RouteLocation(name: endPoint, coordinate: coordinate)
        if routeLocations.count >= 2 {
            routeLocations[1] = loc
        } else {
            routeLocations.append(loc)
        }
        adjustRegionIfNeeded()
    }

    private func adjustRegionIfNeeded() {
        guard routeLocations.count == 2 else { return }
        let a = routeLocations[0].coordinate
        let b = routeLocations[1].coordinate
        let center = CLLocationCoordinate2D(
            latitude:  (a.latitude + b.latitude) / 2,
            longitude: (a.longitude + b.longitude) / 2
        )
        region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.1,
                                   longitudeDelta: 0.1)
        )
    }

    // MARK: – Firestore

    private func fetchIdleDrivers() {
        // 1) load all drivers
        db.collection("fleetDrivers").getDocuments { snap, error in
            guard let docs = snap?.documents, error == nil else {
                print("🚨 fleetDrivers error:", error?.localizedDescription ?? "")
                return
            }
            var allDrivers: [FleetDriver] = []
            for doc in docs {
                if let driver = try? doc.data(as: FleetDriver.self) {
                    allDrivers.append(driver)
                } else {
                    let data = doc.data()
                    print("[DEBUG] Raw driver data fallback:", data)
                    // Manual fallback parsing
                    if let id = data["id"] as? String,
                       let name = data["name"] as? String,
                       let licenseTypeStr = data["licenseType"] as? String,
                       let licenseType = LicenseType(rawValue: licenseTypeStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()),
                       let experience = data["experience"] as? Int,
                       let licenseNo = data["licenseNo"] as? String,
                       let contactNo = data["contactNo"] as? String {
                        let age = data["age"] as? Int ?? 0
                        let totalTrips = data["totalTrips"] as? Int ?? 0
                        let totalTime = data["totalTime"] as? Double ?? 0
                        let totalDistance = data["totalDistance"] as? Double ?? 0
                        let driver = FleetDriver(
                            id: id,
                            name: name,
                            age: age,
                            licenseNo: licenseNo,
                            contactNo: contactNo,
                            experience: experience,
                            licenseType: licenseType,
                            totalTrips: totalTrips,
                            totalTime: totalTime,
                            totalDistance: totalDistance
                        )
                        allDrivers.append(driver)
                    } else {
                        print("[ERROR] Could not parse driver: ", data)
                    }
                }
            }

            // 2) load all in-progress bookings
            db.collection("bookingRequests")
                .whereField("status", isEqualTo: "inProgress")
                .getDocuments { tsnap, terror in
                    guard let tdocs = tsnap?.documents, terror == nil else {
                        print("🚨 bookingRequests error:", terror?.localizedDescription ?? "")
                        return
                    }
                    let busyIDs = Set(
                        tdocs.compactMap { $0.data()["driverId"] as? String }
                    )

                    // 3) filter out busy ones and filter by license type (robust)
                    let vehicleCat = vehicle.vehicleCategory.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                    let free = allDrivers.filter { driver in
                        let licType = driver.licenseType.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                        let isFree = !busyIDs.contains(driver.id) && licType == vehicleCat
                        print("Driver: \(driver.name), License: \(licType), VehicleCat: \(vehicleCat), isFree: \(isFree)")
                        return isFree
                    }
                    DispatchQueue.main.async {
                        self.availableDrivers = free
                    }
                }
        }
    }

    private func scheduleTrip() {
        guard
            let driverId = selectedDriverId,
            routeLocations.count == 2
        else { return }

        let pickup  = routeLocations[0]
        let dropoff = routeLocations[1]

        let data: [String: Any] = [
            "driverId":        driverId,
            "driverName":      availableDrivers.first(where: { $0.id == driverId })?.name ?? "",
            "vehicleId":       vehicle.id,
            "vehicleNo":       vehicle.vehicleNo,
            "pickupName":      pickup.name,
            "pickupAddress":   pickup.name,
            "pickupLatitude":  pickup.coordinate.latitude,
            "pickupLongitude": pickup.coordinate.longitude,
            "dropoffName":     dropoff.name,
            "dropoffAddress":  dropoff.name,
            "dropoffLatitude": dropoff.coordinate.latitude,
            "dropoffLongitude":dropoff.coordinate.longitude,
            "distanceKm":      0,
            "status":          "pending",
            "createdAt":       Timestamp(date: journeyDate)
        ]

        db.collection("bookingRequests")
            .document()
            .setData(data) { error in
                if let err = error {
                    print("❌ Scheduling failed:", err.localizedDescription)
                } else {
                    presentation.wrappedValue.dismiss()
                }
            }
    }
}

// MARK: – Subviews

private struct DateSection: View {
    @Binding var journeyDate: Date
    @Binding var showingDatePicker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.headline)
                .foregroundColor(Color(hex: "396BAF"))

            Button { showingDatePicker.toggle() } label: {
                HStack {
                    Text("Date of Journey")
                        .foregroundColor(.gray)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(journeyDate, style: .date)
                        Text(journeyDate, style: .time)
                    }
                    .foregroundColor(Color(hex: "396BAF"))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "396BAF"), lineWidth: 1)
                )
            }

            if showingDatePicker {
                DatePicker(
                    "",
                    selection: $journeyDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .onChange(of: journeyDate) { _ in
                    showingDatePicker = false
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct MapSection: View {
    @Binding var region: MKCoordinateRegion
    let routeLocations: [RouteLocation]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Map View")
                .font(.headline)
                .foregroundColor(Color(hex: "396BAF"))

            Group {
                if routeLocations.count == 2 {
                    RouteMapView(
                        startCoordinate: routeLocations[0].coordinate,
                        endCoordinate:   routeLocations[1].coordinate,
                        region:          $region
                    )
                } else {
                    Map(coordinateRegion: $region)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
}

private struct LocationSection: View {
    @Binding var startPoint: String
    @Binding var endPoint:   String
    @ObservedObject var startSearchService: LocationSearchService
    @ObservedObject var endSearchService:   LocationSearchService

    let onSelectStart: (CLLocationCoordinate2D) -> Void
    let onSelectEnd:   (CLLocationCoordinate2D) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location Details")
                .font(.headline)
                .foregroundColor(Color(hex: "396BAF"))

            // Start
            VStack(alignment: .leading) {
                TextField("Start Point", text: $startSearchService.queryFragment)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "396BAF"), lineWidth: 1)
                    )

                ForEach(startSearchService.searchResults, id: \.self) { result in
                    Button {
                        startSearchService.queryFragment = result.title
                        startPoint = result.title
                        startSearchService.selectLocation(
                            completion: result
                        ) { coord in
                            if let c = coord { onSelectStart(c) }
                        }
                        startSearchService.searchResults = []
                    } label: {
                        Text(result.title)
                            .padding(.vertical, 4)
                    }
                }
            }

            // End
            VStack(alignment: .leading) {
                TextField("End Point", text: $endSearchService.queryFragment)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "396BAF"), lineWidth: 1)
                    )

                ForEach(endSearchService.searchResults, id: \.self) { result in
                    Button {
                        endSearchService.queryFragment = result.title
                        endPoint = result.title
                        endSearchService.selectLocation(
                            completion: result
                        ) { coord in
                            if let c = coord { onSelectEnd(c) }
                        }
                        endSearchService.searchResults = []
                    } label: {
                        Text(result.title)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct DriversSection: View {
    let drivers: [FleetDriver]
    @Binding var selectedDriverId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Available Drivers")
                .font(.headline)
                .foregroundColor(Color(hex: "396BAF"))

            if drivers.isEmpty {
                Text("No drivers available for this vehicle type.")
                    .foregroundColor(.red)
            } else {
                ForEach(drivers) { drv in
                    HStack(spacing: 12) {
                        Image("person")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name: \(drv.name)")
                            Text("Experience: \(drv.experience) yrs")
                            Text("License: \(drv.licenseType.rawValue)")
                        }
                        .foregroundColor(Color(hex: "396BAF"))

                        Spacer()

                        if drv.id == selectedDriverId {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(hex: "EAF0FB"))
                    .cornerRadius(16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDriverId = drv.id
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct DoneButton: View {
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Done")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled
                                ? Color.gray.opacity(0.5)
                                : Color(hex: "396BAF"))
                .foregroundColor(.white)
                .cornerRadius(16)
        }
        .disabled(isDisabled)
        .padding(.horizontal)
    }
}
