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
                    let driverImage = data["driverImage"] as? String ?? ""
                    print("Driver image URL for \(name): \(driverImage)")
                    let driver = Driver(
                        id: id,
                        driverName: name,
                        driverImage: driverImage,
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
    
    //MARK: - Firebase - Update Driver
    func updateDriver(
            _ driver: Driver,
            profileImage: UIImage?,
            licenseImage: UIImage?,
            completion: @escaping (Error?) -> Void
        ) {
            let driverRef = db.collection("fleetDrivers").document(driver.id)

            Task {
                do {
                    var data: [String: Any] = [
                        "name":        driver.driverName,
                        "age":         driver.driverAge,
                        "experience":  driver.driverExperience,
                        "contactNo":   driver.driverContactNo,
                        "licenseNo":   driver.driverLicenseNo,
                        "licenseType": driver.driverLicenseType
                    ]

                    // If user picked a new profile image, upload it
                    if let img = profileImage,
                       let imgData = img.jpegData(compressionQuality: 0.8) {
                        let url = try await uploadImage(imgData,
                            path: "drivers/\(driver.id)_profile.jpg"
                        )
                        data["driverImage"] = url
                    }

                    // If user picked a new license image, upload it
                    if let lic = licenseImage,
                       let licData = lic.jpegData(compressionQuality: 0.8) {
                        let url = try await uploadImage(licData,
                            path: "drivers/\(driver.id)_license.jpg"
                        )
                        data["licenseProofImage"] = url
                    }

                    // Merge update into Firestore
                    try await driverRef.updateData(data)
                    DispatchQueue.main.async { completion(nil) }
                }
                catch {
                    DispatchQueue.main.async { completion(error) }
                }
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
    
    //MARK: - Firebase - Fetch Past Trips for vehicle
//    static func fetchPastTrips(for vehicleNo: String, completion: @escaping ([PastTrip]) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("pastTrips")
//            .whereField("vehicleNo", isEqualTo: vehicleNo)
//            .getDocuments { (snapshot, error) in
//                if let error = error {
//                    print("Error fetching past trips: \(error)")
//                    completion([])
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    completion([])
//                    return
//                }
//                
//                let trips = documents.compactMap { doc -> PastTrip? in
//                    let data = doc.data()
//                    guard let driverName = data["driverName"] as? String,
//                          let vehicleNo = data["vehicleNo"] as? String,
//                          let tripDetail = data["tripDetail"] as? String,
//                          let driverImage = data["driverImage"] as? String,
//                          let date = data["date"] as? String else {
//                        return nil
//                    }
//                    return PastTrip(
//                        driverName: driverName,
//                        vehicleNo: vehicleNo,
//                        tripDetail: tripDetail,
//                        driverImage: driverImage,
//                        date: date
//                    )
//                }
//                
//                completion(trips)
//            }
//    }
    
    
    static func fetchPastTrips(for vehicleNo: String, completion: @escaping ([PastTrip]) -> Void) {
        let db = Firestore.firestore()
        db.collection("pastTrips")
            .whereField("vehicleNo", isEqualTo: vehicleNo)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching past trips: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let trips = documents.compactMap { doc -> PastTrip? in
                    let data = doc.data()
                    
                    guard
                        let driverName = data["driverName"] as? String,
                        let tripDetail = data["tripDetail"] as? String,
                        let timestamp = data["date"] as? Timestamp,
                        let cost = data["cost"] as? Double,
                        let mileage = data["mileage"] as? String,
                        let distanceKm = data["distanceKm"] as? Double,
                        let durationMinutes = data["durationMinutes"] as? Int
                    else {
                        return nil
                    }
                    
                    return PastTrip(
                        id: doc.documentID,
                        driverName: driverName,
                        tripDetail: tripDetail,
                        date: timestamp.dateValue(),
                        cost: cost,
                        mileage: mileage,
                        distanceKm: distanceKm,
                        durationMinutes: durationMinutes
                    )
                }
                
                completion(trips)
            }
    }
    
    // MARK: - Firebase - Fetch Past Trips for Driver
//    func fetchPastTrips(forDriver driverName: String, completion: @escaping ([PastTrip]) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("pastTrips")
//            .whereField("driverName", isEqualTo: driverName)
//            .getDocuments { (snapshot, error) in
//                if let error = error {
//                    print("Error fetching past trips for driver: \(error)")
//                    completion([])
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    completion([])
//                    return
//                }
//                
//                let trips = documents.compactMap { doc -> PastTrip? in
//                    let data = doc.data()
//                    guard let driverName = data["driverName"] as? String,
//                          let vehicleNo = data["vehicleNo"] as? String,
//                          let tripDetail = data["tripDetail"] as? String,
//                          let driverImage = data["driverImage"] as? String,
//                          let date = data["date"] as? String else {
//                        return nil
//                    }
//                    print("Trip image URL for \(driverName): \(driverImage)")
//                    return PastTrip(
//                        driverName: driverName,
//                        vehicleNo: vehicleNo,
//                        tripDetail: tripDetail,
//                        driverImage: driverImage,
//                        date: date
//                    )
//                }
//                
//                completion(trips)
//            }
//    }
    
    
    func fetchPastTrips(forDriver driverName: String, completion: @escaping ([PastTrip]) -> Void) {
        let db = Firestore.firestore()
        db.collection("pastTrips")
            .whereField("driverName", isEqualTo: driverName)
            .getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    print("Error fetching past trips for driver: \(error)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let trips = documents.compactMap { doc -> PastTrip? in
                    let data = doc.data()
                    
                    guard
                        let driverName = data["driverName"] as? String,
                        let tripDetail = data["tripDetail"] as? String,
                        let timestamp = data["date"] as? Timestamp,
                        let cost = data["cost"] as? Double,
                        let mileage = data["mileage"] as? String,
                        let distanceKm = data["distanceKm"] as? Double,
                        let durationMinutes = data["durationMinutes"] as? Int
                    else {
                        return nil
                    }
                    
                    return PastTrip(
                        id: doc.documentID,
                        driverName: driverName,
                        tripDetail: tripDetail,
                        date: timestamp.dateValue(), // Converts Timestamp -> Date
                        cost: cost,
                        mileage: mileage,
                        distanceKm: distanceKm,
                        durationMinutes: durationMinutes
                    )
                }
                
                completion(trips)
            })
    }

    //MARK: - Firebase - Fetch Past Maintenance
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
    
    //MARK: - Firebase - Add New Fleet
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

    
    //MARK: - Firebase - Add New driver
    func addDriver(
           _ driver: Driver,
           profileImage: UIImage,
           licenseImage: UIImage?,
           completion: @escaping (Error?) -> Void
       ) {
           let driverRef = db.collection("fleetDrivers").document(driver.id)

           Task {
               do {
                   // 1) Build base fields
                   var data: [String: Any] = [
                       "id":            driver.id,
                       "name":          driver.driverName,
                       "age":           driver.driverAge,
                       "experience":    driver.driverExperience,
                       "contactNo":     driver.driverContactNo,
                       "licenseNo":     driver.driverLicenseNo,
                       "licenseType":   driver.driverLicenseType,
                       "createdAt":     FieldValue.serverTimestamp()
                   ]

                   // 2) Upload profile image
                   if let imgData = profileImage.jpegData(compressionQuality: 0.8) {
                       let url = try await uploadImage(imgData,
                           path: "drivers/\(driver.id)_profile.jpg"
                       )
                       data["driverImage"] = url
                   }

                   // 3) Upload license proof image (optional)
                   if let license = licenseImage,
                      let licData = license.jpegData(compressionQuality: 0.8) {
                       let url = try await uploadImage(licData,
                           path: "drivers/\(driver.id)_license.jpg"
                       )
                       data["licenseProofImage"] = url
                   }

                   // 4) Write to Firestore
                   try await driverRef.setData(data)
                   DispatchQueue.main.async { completion(nil) }

               } catch {
                   DispatchQueue.main.async { completion(error) }
               }
           }
       }

    
}


