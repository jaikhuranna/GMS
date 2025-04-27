//
//  FirebaseModules.swift
//  fleetManagementSystem
//
//  Created by Steve on 24/04/25.
//



import Firebase
import FirebaseFirestore
import FirebaseStorage

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
    
    
    static func fetchPastTrips(for vehicleNo: String, completion: @escaping ([PastTrip]) -> Void) {
        let db = Firestore.firestore()
        db.collection("pastTrips")
            .whereField("vehicleNo", isEqualTo: vehicleNo)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching past trips: \(error)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let trips = documents.compactMap { doc -> PastTrip? in
                    let data = doc.data()
                    guard let driverName = data["driverName"] as? String,
                          let vehicleNo = data["vehicleNo"] as? String,
                          let tripDetail = data["tripDetail"] as? String,
                          let driverImage = data["driverImage"] as? String,
                          let date = data["date"] as? String else {
                        return nil
                    }
                    return PastTrip(
                        driverName: driverName,
                        vehicleNo: vehicleNo,
                        tripDetail: tripDetail,
                        driverImage: driverImage,
                        date: date
                    )
                }
                
                completion(trips)
            }
    }
    
    static func fetchPastMaintenances(for vehicleNo: String, completion: @escaping ([PastMaintenance]) -> Void) {
        let db = Firestore.firestore()
        db.collection("pastMaintenances")
            .whereField("vehicleNo", isEqualTo: vehicleNo)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching past maintenances: \(error)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let maintenances = documents.compactMap { doc -> PastMaintenance? in
                    let data = doc.data()
                    guard let note = data["note"] as? String,
                          let observerName = data["observerName"] as? String,
                          let dateOfMaintenance = data["dateOfMaintenance"] as? String,
                          let vehicleNo = data["vehicleNo"] as? String else {
                        return nil
                    }
                    return PastMaintenance(
                        note: note,
                        observerName: observerName,
                        dateOfMaintenance: dateOfMaintenance,
                        vehicleNo: vehicleNo
                    )
                }
                
                completion(maintenances)
            }
    }
    
    
    func addFleetVehicle(_ vehicle: FleetVehicle) async throws {
        let vehicleRef = Firestore.firestore().collection("vehicles").document()

        var data: [String: Any] = [
            "vehicleNo": vehicle.vehicleNo,
            "modelName": vehicle.modelName,
            "engineNo": vehicle.engineNo,
            "licenseRenewalDate": Timestamp(date: vehicle.licenseRenewalDate),
            "distanceTravelled": vehicle.distanceTravelled,
            "averageMileage": vehicle.averageMileage,
            "vehicleType": vehicle.vehicleType.rawValue,
            "vehicleCategory": vehicle.vehicleCategory.rawValue,
            "id": vehicleRef.documentID
        ]

        do {
            if let photo = vehicle.vehiclePhoto, let imageData = photo.jpegData(compressionQuality: 0.8) {
                let photoURL = try await uploadImage(imageData, path: "vehicles/\(vehicleRef.documentID)_photo.jpg")
                data["vehiclePhotoURL"] = photoURL
            }
            
            if let insurance = vehicle.insuranceProofImage, let imageData = insurance.jpegData(compressionQuality: 0.8) {
                let insuranceURL = try await uploadImage(imageData, path: "vehicles/\(vehicleRef.documentID)_insurance.jpg")
                data["insuranceProofURL"] = insuranceURL
            }
        } catch {
            print("Failed to upload images: \(error.localizedDescription)")
            throw error // you can decide if you want to rethrow or show alert
        }

        try await vehicleRef.setData(data)
    }
    private func uploadImage(_ imageData: Data, path: String) async throws -> String {
        guard !imageData.isEmpty else {
            throw NSError(domain: "UploadImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image data is empty."])
        }
        
        let storageRef = Storage.storage().reference().child(path)
        let _ = try await storageRef.putDataAsync(imageData, metadata: nil)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }


    
}
//    // MARK: - Fetch Past Trips for Vehicle
//        func fetchPastTrips(forVehicleId vehicleId: String, completion: @escaping (Result<[PastTrip], Error>) -> Void) {
//            db.collection("pastTrips")
//              .whereField("vehicleId", isEqualTo: vehicleId)
//              .getDocuments { (querySnapshot, error) in
//                  if let error = error {
//                      print("Error fetching past trips for \(vehicleId): \(error.localizedDescription)") // Added vehicleId to print
//                      completion(.failure(error))
//                  } else {
//                      var fetchedTrips: [PastTrip] = []
//                      for document in querySnapshot!.documents {
//                          do {
//                              // Use document.data(as:) for Codable structs
//                              let trip = try document.data(as: PastTrip.self)
//                              fetchedTrips.append(trip)
//                          } catch {
//                              print("Error decoding past trip document \(document.documentID): \(error.localizedDescription)")
//                          }
//                      }
//                      print("Fetched \(fetchedTrips.count) past trips for vehicleId: \(vehicleId)")
//                      completion(.success(fetchedTrips))
//                  }
//              }
//        }

