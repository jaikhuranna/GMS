// This file contains only logic and does not require dark mode UI changes.
//
//  GeofenceManager.swift
//  fleetManagementSystem
//
//  Created by user@61 on 02/05/25.
//


// GeofenceManager.swift

import Foundation
import CoreLocation
import Combine
import FirebaseFirestore

final class GeofenceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = GeofenceManager()

    // MARK: Published state for SwiftUI
    @Published var didEnterRegion = false
    @Published var didExitRegion = false

    // MARK: Internal identifiers
    private(set) var bookingRequestID: String?
    private(set) var vehicleNumber: String?

    private let locationManager = CLLocationManager()

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    /// Call this to (re)start geofence monitoring for a given booking + vehicle.
    func startMonitoringBoundaries(bookingID: String, vehicleNumber: String) {
        self.bookingRequestID = bookingID
        self.vehicleNumber   = vehicleNumber
        didEnterRegion       = false
        didExitRegion        = false

        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("⚠️ Geofencing not supported on this device")
            return
        }

        // 1) Stop any old regions
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }

        // 2) Fetch new boundaries from Firestore
        Firestore.firestore()
            .collection("boundaries")
            .whereField("bookingID", isEqualTo: bookingID)
            .getDocuments { [weak self] snap, err in
                guard let self = self, let docs = snap?.documents else { return }
                for doc in docs {
                    guard
                        let lat    = doc["latitude"]  as? CLLocationDegrees,
                        let lon    = doc["longitude"] as? CLLocationDegrees,
                        let radius = doc["radius"]    as? CLLocationDistance
                    else { continue }

                    let circle = CLCircularRegion(
                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        radius: radius,
                        identifier: doc.documentID
                    )
                    circle.notifyOnEntry = true
                    circle.notifyOnExit  = true
                    self.locationManager.startMonitoring(for: circle)
                }
            }
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        DispatchQueue.main.async { self.didEnterRegion = true }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        DispatchQueue.main.async { self.didExitRegion = true }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Geofence error: \(error.localizedDescription)")
    }
}
