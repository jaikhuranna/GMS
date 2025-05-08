//
//  OffRouteMapView.swift
//  fleetManagementSystem
//
//  Created by Steve on 08/05/25.
//


import SwiftUI
import FirebaseFirestore
import CoreLocation
import MapKit

struct OffRouteMapView: View {
    @Environment(\.dismiss) private var dismiss
    let alert: NotificationItem

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )
    @State private var routeCoords = [CLLocationCoordinate2D]()
    private let geofenceRadius: CLLocationDistance = 2_000

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                // 1️⃣ Planned route
                if routeCoords.count == 2 {
                    MapPolyline(coordinates: routeCoords)
                        .stroke(.blue, lineWidth: 3)
                }

                // 2️⃣ Geofence circle
                if let center = routeCenter {
                    MapCircle(center: vehicleLocation, radius: geofenceRadius)
                      .foregroundStyle(Color.orange.opacity(0.2))
                      .mapOverlayLevel(level: .aboveLabels)
                    MapCircle(center: vehicleLocation, radius: geofenceRadius)
                      .stroke(Color.orange, lineWidth: 2)
                }

                // 3️⃣ Vehicle location
                Marker("Vehicle", coordinate: vehicleLocation)
                    .tint(.red)

            }
            .onAppear {
                loadRouteFromFirestore()
                setupRegion()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button("Back") { dismiss() })
            .navigationTitle("Off-Route Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func setupRegion() {
        let center = routeCenter ?? vehicleLocation
        cameraPosition = .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta:  0.04,
                                                       longitudeDelta: 0.04)
            )
        )
    }

    // MARK: – Helpers

    private var vehicleLocation: CLLocationCoordinate2D {
        guard case let .offRoute(_, _, loc, _, _, _) = alert else { return .init() }
        return loc
    }

    private var routeCenter: CLLocationCoordinate2D? {
        guard routeCoords.count == 2 else { return nil }
        let a = routeCoords[0], b = routeCoords[1]
        return CLLocationCoordinate2D(
            latitude: (a.latitude + b.latitude) / 2,
            longitude: (a.longitude + b.longitude) / 2
        )
    }

    private func loadRouteFromFirestore() {
        guard case let .offRoute(_, _, _, _, _, tripId) = alert else { return }
        Firestore.firestore()
            .collection("bookingRequests")
            .document(tripId)
            .getDocument { snap, _ in
                guard
                    let d    = snap?.data(),
                    let pLat = d["pickupLatitude"]  as? CLLocationDegrees,
                    let pLng = d["pickupLongitude"] as? CLLocationDegrees,
                    let dLat = d["dropoffLatitude"] as? CLLocationDegrees,
                    let dLng = d["dropoffLongitude"] as? CLLocationDegrees
                else { return }
                DispatchQueue.main.async {
                    routeCoords = [
                        CLLocationCoordinate2D(latitude: pLat, longitude: pLng),
                        CLLocationCoordinate2D(latitude: dLat, longitude: dLng)
                    ]
                }
            }
    }
}