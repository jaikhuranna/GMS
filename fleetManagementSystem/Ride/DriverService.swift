//
// DriverService.swift
// fleetManagementSystem
//
// Created by user@61 on 06/05/25.
//

import Combine
import FirebaseFirestore

class DriverService: ObservableObject {
    @Published var driver: FleetDriver?
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    // Changed to accept appwriteUserId instead of driverId
    init(appwriteUserId: String) {
        print("Searching for driver with Appwrite ID: \(appwriteUserId)")
        
        // Query by email to find the driver document
        listener = db.collection("fleetDrivers")
            .whereField("email", isEqualTo: "driverfleet543@gmail.com") // Use the email from your screenshot
            .limit(to: 1)
            .addSnapshotListener { snap, error in
                if let error = error {
                    print("Error fetching driver: \(error)")
                    return
                }
                
                guard let doc = snap?.documents.first,
                      let data = doc.data() as? [String: Any]
                else {
                    print("No driver found with email matching Appwrite user")
                    return
                }
                
                print("Found driver document: \(data)")
                
                // Get document ID to use as driver ID
                let id = doc.documentID
                
                // Pull each field, converting from String → Int/Double as needed:
                guard
                    let name = data["name"] as? String,
                    let age = data["age"] as? Int,
                    let licNo = data["licenseNo"] as? String,
                    let contact = data["contactNo"] as? String,
                    let exp = data["experience"] as? Int,
                    let licType = (data["licenseType"] as? String).flatMap(LicenseType.init(rawValue:))
                else {
                    print("🔴 DriverService.decode failed:", data)
                    return
                }
                
                // Use default values if stats aren't available yet
                let totalTripsInt = (data["totalTrips"] as? String).flatMap(Int.init) ?? 0
                let totalTimeDouble = (data["totalTime"] as? String).flatMap(Double.init) ?? 0
                let totalDistanceDouble = (data["totalDistance"] as? String).flatMap(Double.init) ?? 0
                
                let d = FleetDriver(
                    id: id,
                    name: name,
                    age: age,
                    licenseNo: licNo,
                    contactNo: contact,
                    experience: exp,
                    licenseType: licType,
                    totalTrips: totalTripsInt,
                    totalTime: totalTimeDouble,
                    totalDistance: totalDistanceDouble
                )
                
                DispatchQueue.main.async {
                    self.driver = d
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
