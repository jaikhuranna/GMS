//
//  FirebaseManger.swift
//  fleetManagementSystem
//
//  Created by Steve on 25/04/25.
//

//
//  Firebase Manager.swift
//  fleetManagementSystem
//
//  Created by user@61 on 24/04/25.
//


import Foundation
import Firebase
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()

    private let vehiclesCollection = "vehicles"
    private let driversCollection = "fleetDrivers"

    private init() {}

    // MARK: - Upload Single Vehicle
    func uploadVehicle(_ vehicle: FleetVehicle, completion: @escaping (Result<Void, Error>) -> Void) {
        let data = vehicle.toDictionary()
        db.collection(vehiclesCollection).document(vehicle.id.uuidString).setData(data) { error in
            error == nil ? completion(.success(())) : completion(.failure(error!))
        }
    }

    // MARK: - Upload Sample Fleet
    func uploadSampleFleet(_ fleet: [FleetVehicle]) {
        for vehicle in fleet {
            uploadVehicle(vehicle) { result in
                switch result {
                case .success:
                    print("Uploaded vehicle: \(vehicle.vehicleNo)")
                case .failure(let error):
                    print("Vehicle upload failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Upload Single Driver
    func uploadFleetDriver(_ driver: FleetDriver, completion: @escaping (Result<Void, Error>) -> Void) {
        let data = driver.toDictionary()
        db.collection(driversCollection).document(driver.id.uuidString).setData(data) { error in
            error == nil ? completion(.success(())) : completion(.failure(error!))
        }
    }

    // MARK: - Upload Sample Drivers
    func uploadSampleFleetDrivers(_ drivers: [FleetDriver]) {
        for driver in drivers {
            uploadFleetDriver(driver) { result in
                switch result {
                case .success:
                    print("Uploaded driver: \(driver.name)")
                case .failure(let error):
                    print("Driver upload failed: \(error.localizedDescription)")
                }
            }
        }
    }

//    // MARK: - Fetch Drivers
//    func fetchDrivers(completion: @escaping ([Driver]) -> Void) {
//        db.collection(driversCollection).getDocuments { snapshot, error in
//            guard error == nil, let documents = snapshot?.documents else {
//                print("Error getting drivers: \(error?.localizedDescription ?? "Unknown error")")
//                completion([])
//                return
//            }
//
//            let drivers: [Driver] = documents.compactMap { doc in
//                let data = doc.data()
//                guard let name = data["name"] as? String,
//                      let age = data["age"] as? Int,
//                      let experience = data["experience"] as? Int,
//                      let contactNo = data["contactNo"] as? String,
//                      let id = data["id"] as? String,
//                      let licenseNo = data["licenseNo"] as? String,
//                      let licenseType = data["licenseType"] as? String
//                else { return nil }
//
//                return Driver(
//                    id: id,
//                    driverName: name,
//                    driverImage: data["driverImage"] as? String ?? "",
//                    driverExperience: experience,
//                    driverAge: age,
//                    driverContactNo: contactNo,
//                    driverLicenseNo: licenseNo,
//                    driverLicenseType: licenseType
//                )
//            }
//
//            completion(drivers)
//        }
//    }
//
//    // MARK: - Fetch Vehicles
//    func fetchAllVehicles(completion: @escaping ([Vehicle]) -> Void) {
//        db.collection(vehiclesCollection).getDocuments { snapshot, error in
//            guard error == nil, let documents = snapshot?.documents else {
//                print("Error fetching vehicles: \(error?.localizedDescription ?? "Unknown error")")
//                completion([])
//                return
//            }
//
//            let vehicles: [Vehicle] = documents.compactMap { doc in
//                let data = doc.data()
//                guard let vehicleNo = data["vehicleNo"] as? String,
//                      let distanceTravelled = data["distanceTravelled"] as? Int,
//                      let vehicleCategory = data["vehicleCategory"] as? String,
//                      let vehicleType = data["vehicleType"] as? String,
//                      let modelName = data["modelName"] as? String,
//                      let averageMileage = data["averageMileage"] as? Double,
//                      let engineNo = data["engineNo"] as? String,
//                      let licenseRenewalTimestamp = data["licenseRenewalDate"] as? Timestamp
//                else { return nil }
//
//                return Vehicle(
//                    id: doc.documentID,
//                    vehicleNo: vehicleNo,
//                    distanceTravelled: distanceTravelled,
//                    vehicleCategory: vehicleCategory,
//                    vehicleType: vehicleType,
//                    modelName: modelName,
//                    averageMileage: averageMileage,
//                    engineNo: engineNo,
//                    licenseRenewalDate: licenseRenewalTimestamp.dateValue(),
//                    carImage: vehicleType
//                )
//            }
//
//            completion(vehicles)
//        }
//    }
}
