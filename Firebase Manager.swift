//
//  Firebase Manager.swift
//  fleetManagementSystem
//
//  Created by user@61 on 24/04/25.
//


import Foundation
import FirebaseFirestore

//class VehicleDBService {
//    private let db = Firestore.firestore()
//    private let collectionName = "vehicles"
//
//    func uploadVehicle(_ vehicle: FleetVehicle, completion: @escaping (Result<Void, Error>) -> Void) {
//        let data = vehicle.toDictionary()
//        db.collection(collectionName).document(vehicle.id.uuidString).setData(data) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//
//    func uploadSampleFleet(_ fleet: [FleetVehicle]) {
//        for vehicle in fleet {
//            uploadVehicle(vehicle) { result in
//                switch result {
//                case .success():
//                    print("Uploaded: \(vehicle.vehicleNo)")
//                case .failure(let error):
//                    print("Failed: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}


//class FleetDriverDBService {
//    private let db = Firestore.firestore()
//    private let collectionName = "fleetDrivers"
//
//    // Upload a single FleetDriver
//    func uploadFleetDriver(_ fleetDriver: FleetDriver, completion: @escaping (Result<Void, Error>) -> Void) {
//        let data = fleetDriver.toDictionary()
//        db.collection(collectionName).document(fleetDriver.id.uuidString).setData(data) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//
//    // Upload a list of sample FleetDrivers
//    func uploadSampleFleetDrivers(_ fleetDrivers: [FleetDriver]) {
//        for fleetDriver in fleetDrivers {
//            uploadFleetDriver(fleetDriver) { result in
//                switch result {
//                case .success:
//                    print("Uploaded: \(fleetDriver.name)")
//                case .failure(let error):
//                    print("Failed: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
