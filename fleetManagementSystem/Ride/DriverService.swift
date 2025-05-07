//
//  DriverService.swift
//  fleetManagementSystem
//
//  Created by user@61 on 06/05/25.
//


import Combine
import FirebaseFirestore

class DriverService: ObservableObject {
  @Published var driver: FleetDriver?
  private var listener: ListenerRegistration?
  private let db = Firestore.firestore()

  init(driverId: String) {
    listener = db.collection("fleetDrivers")
      .whereField("id", isEqualTo: driverId)   
      .limit(to: 1)
      .addSnapshotListener { snap, error in
        guard let doc = snap?.documents.first,
              let data = doc.data() as? [String: Any]
        else { return }

        // Pull each field, converting from String → Int/Double as needed:
        guard
          let name     = data["name"]          as? String,
          let age      = data["age"]           as? Int,
          let licNo    = data["licenseNo"]     as? String,
          let contact  = data["contactNo"]     as? String,
          let exp      = data["experience"]    as? Int,
          let licType  = (data["licenseType"]  as? String).flatMap(LicenseType.init(rawValue:)),
          let totalT   = data["totalTrips"]    as? String,
          let totalTimeStr = data["totalTime"]     as? String,
          let totalDistanceStr = data["totalDistance"] as? String,
          let totalTripsInt     = Int(totalT),
          let totalTimeDouble   = Double(totalTimeStr),
          let totalDistanceDouble = Double(totalDistanceStr)
        else {
          print("🔴 DriverService.decode failed:", data)
          return
        }

        let d = FleetDriver(
          id:            driverId,
          name:          name,
          age:           age,
          licenseNo:     licNo,
          contactNo:     contact,
          experience:    exp,
          licenseType:   licType,
          totalTrips:    totalTripsInt,
          totalTime:     totalTimeDouble,
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
