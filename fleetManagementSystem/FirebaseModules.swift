//
//  FirebaseModules.swift
//  fleetManagementSystem
//
//  Created by Steve on 24/04/25.
//



import Firebase
import FirebaseFirestore

class FirebaseModules {
    static let shared = FirebaseModules()
    private let db = Firestore.firestore()
    
    
    //MARK: - Firebase - Fetch Drivers
    // Function to fetch driver data from Firestore
    func fetchDrivers(completion: @escaping ([Driver]) -> Void) {
        db.collection("fleetDrivers").getDocuments(source: .default) { snapshot, error in
            var drivers: [Driver] = []
            if let error = error {
                print("Error getting drivers: \(error.localizedDescription)")
                completion(drivers)
                return
            }

            for document in snapshot!.documents {
                let data = document.data()
                if let name = data["name"] as? String,
                   let age = data["age"] as? Int,
                   let experience = data["experience"] as? Int,
                   let contactNo = data["contactNo"] as? String,
                   let id = data["id"] as? String,
                   let licenseNo = data["licenseNo"] as? String,
                   let licenseType = data["licenseType"] as? String {
                    let driver = Driver(
                        id: id,
                        driverName: name,
                        driverImage: data["driverImage"] as? String ?? "",
                        driverExperience: experience,
                        driverAge: age,
                        driverContactNo: contactNo,
                        driverLicenseNo: licenseNo,
                        driverLicenseType: licenseType
                    )
                    drivers.append(driver)
                }
            }
            completion(drivers)
        }

    }
    
    
    //MARK: - Firebase - Fetch Vehicle List
    func fetchAllVehicles(completion: @escaping ([Vehicle]) -> Void) {
            let db = Firestore.firestore()
            db.collection("vehicles").getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching vehicles: \(error)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }

                let vehicles = documents.compactMap { doc -> Vehicle? in
                    let data = doc.data()
                    guard
                        let vehicleNo = data["vehicleNo"] as? String,
                        let distanceTravelled = data["distanceTravelled"] as? Int,
                        let vehicleCategory = data["vehicleCategory"] as? String,
                        let vehicleType = data["vehicleType"] as? String,
                        let modelName = data["modelName"] as? String,
                        let averageMileage = data["averageMileage"] as? Double,
                        let engineNo = data["engineNo"] as? String,
                        let licenseRenewalTimestamp = data["licenseRenewalDate"] as? Timestamp
                    else {
                        return nil
                    }

                    return Vehicle(
                        id: doc.documentID,
                        vehicleNo: vehicleNo,
                        distanceTravelled: distanceTravelled,
                        vehicleCategory: vehicleCategory,
                        vehicleType: vehicleType,
                        modelName: modelName,
                        averageMileage: averageMileage,
                        engineNo: engineNo,
                        licenseRenewalDate: licenseRenewalTimestamp.dateValue(),
                        carImage: vehicleType
                    )
                }

                completion(vehicles)
            }
        }
}
