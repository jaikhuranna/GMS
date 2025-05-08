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
    private let storage = Storage.storage().reference()
    
    
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
                        let durationMinutes = data["durationMinutes"] as? Int,
                        let vehicleNo = data["vehicleNo"] as? String
                    else {
                        return nil
                    }
                    
                    return PastTrip(
                        id: doc.documentID,
                        driverId: driverName,
                        tripDetail: tripDetail,
                        date: timestamp.dateValue(),
                        cost: cost,
                        mileage: mileage,
                        distanceKm: distanceKm,
                        durationMinutes: durationMinutes,
                        vehicleNo: vehicleNo
                    )
                }
                
                completion(trips)
            }
    }
    
    
    
    // MARK: - Firebase - Fetch Past Trips for Driver
    func fetchPastTrips(forDriverId driverId: String, completion: @escaping ([PastTrip]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("pastTrips")
            .whereField("driverId", isEqualTo: driverId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching past trips for driver ID: \(error)")
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
                        let driverId = data["driverId"] as? String,
                        let driverName = data["driverName"] as? String, // ✅ still used for UI
                        let tripDetail = data["tripDetail"] as? String,
                        let timestamp = data["date"] as? Timestamp,
                        let cost = data["cost"] as? Double,
                        let mileage = data["mileage"] as? String,
                        let distanceKm = data["distanceKm"] as? Double,
                        let durationMinutes = data["durationMinutes"] as? Int,
                        let vehicleNo = data["vehicleNo"] as? String
                    else {
                        return nil
                    }
                    
                    return PastTrip(
                        id: doc.documentID,
                        driverId: driverId,
                        tripDetail: tripDetail,
                        date: timestamp.dateValue(),
                        cost: cost,
                        mileage: mileage,
                        distanceKm: distanceKm,
                        durationMinutes: durationMinutes,
                        driverName: driverName,
                        vehicleNo: vehicleNo // ✅ safe to display
                    )
                }
                
                completion(trips)
            }
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
    
    //MARK: - Firebase - Fetch Inventory details
    func fetchInventoryItems(completion: @escaping ([InventoryItem]) -> Void) {
        let db = Firestore.firestore()
        db.collection("inventoryItems").getDocuments { snapshot, error in
            var items: [InventoryItem] = []
            
            if let error = error {
                print("❌ Error fetching inventory: \(error.localizedDescription)")
                completion(items)
                return
            }

            guard let documents = snapshot?.documents else {
                completion(items)
                return
            }

            for doc in documents {
                let data = doc.data()

                guard
                    let name = data["name"] as? String,
                    let quantity = data["quantity"] as? Int,
                    let price = data["price"] as? Double,
                    let typeRaw = data["type"] as? String,
                    let type = InventoryItem.ItemType(rawValue: typeRaw)
                else { continue }

                if type == .part {
                    if let partID = data["partID"] as? String {
                        let item = InventoryItem(name: name, quantity: quantity, price: price, partID: partID)
                        items.append(item)
                    }
                } else {
                    let item = InventoryItem(name: name, quantity: quantity, price: price)
                    items.append(item)
                }
            }

            completion(items)
        }
    }
    
    
    //MARK: - Firebase - Add to Inventory
    func addInventoryItem(_ item: InventoryItem, completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "name": item.name,
            "quantity": item.quantity,
            "price": item.price,
            "type": item.type.rawValue
        ]
        
        if item.type == .part, let partID = item.partID {
            data["partID"] = partID
        }
        
        db.collection("inventoryItems").addDocument(data: data) { error in
            if let error = error {
                print("❌ Error saving item to Firestore:", error.localizedDescription)
            } else {
                print("✅ Item saved to Firestore.")
            }
            completion?(error)
        }
    }

    // MARK: - Firebase - Add Maintenance Task
    func addMaintenanceTask(_ taskData: [String: Any], taskId: String, completion: @escaping (Error?) -> Void) {
        let docRef = Firestore.firestore().collection("maintenanceTasks").document(taskId)
        
        docRef.setData(taskData) { error in
            if let error = error {
                print("❌ Failed to add maintenance task: \(error.localizedDescription)")
            } else {
                print("✅ Maintenance task successfully added with ID: \(taskId)")
            }
            completion(error)
        }
    }

    func uploadMaintenanceImages(taskId: String, images: [UIImage], completion: @escaping ([String], Error?) -> Void) {
        let storage = Storage.storage()
        var uploadedURLs: [String] = []
        let dispatchGroup = DispatchGroup()

        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            let imageRef = storage.reference().child("maintenanceImages/\(taskId)_\(index).jpg")

            dispatchGroup.enter()
            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("❌ Failed to upload image \(index): \(error)")
                    dispatchGroup.leave()
                    return
                }

                imageRef.downloadURL { url, error in
                    if let url = url {
                        uploadedURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(uploadedURLs, nil)
        }
    }


    //MARK: - Firebase - fetch pending Bill Notifications
    func fetchPendingBillNotifications(completion: @escaping ([NotificationItem]) -> Void) {
            let db = Firestore.firestore()
            db.collection("pendingBills")
                .whereField("status", isEqualTo: "pending")
                .getDocuments { snapshot, error in
                    var items: [NotificationItem] = []

                    guard let documents = snapshot?.documents else {
                        completion([])
                        return
                    }

                    for doc in documents {
                        let data = doc.data()
                        if let task = data["taskName"] as? String,
                           let vehicle = data["vehicleNo"] as? String {
                            items.append(.billRaised(id: doc.documentID, task: task, vehicle: vehicle))
                        }
                    }

                    completion(items)
                }
        }
    
    //MARK: - Firebase - Change the status to approved
    func updateBillToOngoing(billId: String, date: Date, completion: ((Error?) -> Void)? = nil) {
        db.collection("pendingBills").document(billId).updateData([
            "status": "ongoing",
            "scheduledDate": Timestamp(date: date)
        ]) { error in
            if let error = error {
                print("❌ Failed to update bill to ongoing:", error.localizedDescription)
            } else {
                print("✅ Bill moved to ongoing.")
            }
            completion?(error)
        }
    }



    func fetchApprovedBills(completion: @escaping ([PendingBill]) -> Void) {
        db.collection("pendingBills")
            .whereField("status", isEqualTo: "approved")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    print("❌ Failed to fetch approved bills:", error?.localizedDescription ?? "")
                    completion([])
                    return
                }

                let bills = docs.compactMap { doc -> PendingBill? in
                    let data = doc.data()
                    guard
                        let task = data["taskName"] as? String,
                        let vehicle = data["vehicleNo"] as? String,
                        let amount = data["total"] as? Double
                    else {
                        return nil
                    }

                    return PendingBill(id: doc.documentID, task: task, vehicle: vehicle, amount: amount)
                }

                completion(bills)
            }
    }


    
}

    
    
    //MARK: - Firebase - To upload past trips
    
    //    func seedSamplePastTrips() {
    //        let trips: [[String: Any]] = [
    //            [
    //                "driverId": "0C878AF1-39EC-456A-8642-C962C343DB2D",
    //                "driverName": "Priya Rawat",
    //                "vehicleNo": "KA01AB1234",
    //                "tripDetail": "Trip to warehouse in Bengaluru",
    //                "date": Timestamp(date: Date(timeIntervalSince1970: 1713551400)),
    //                "cost": 1200.0,
    //                "mileage": "15 km/l",
    //                "distanceKm": 80.0,
    //                "durationMinutes": 90
    //            ],
    //            [
    //                "driverId": "1C5DB90E-4AC8-4E36-8672-144A0F934C36",
    //                "driverName": "Ravi Reddy",
    //                "vehicleNo": "AP12CD5678",
    //                "tripDetail": "Delivery to Hyderabad hub",
    //                "date": Timestamp(date: Date(timeIntervalSince1970: 1713637800)),
    //                "cost": 1500.0,
    //                "mileage": "12 km/l",
    //                "distanceKm": 110.0,
    //                "durationMinutes": 130
    //            ],
    //            [
    //                "driverId": "4A7DD6B8-E5BA-465D-B96B-25F35D06CC59",
    //                "driverName": "Peter Jones",
    //                "vehicleNo": "MH14EF9012",
    //                "tripDetail": "Pickup from Pune logistics center",
    //                "date": Timestamp(date: Date(timeIntervalSince1970: 1713465000)),
    //                "cost": 950.0,
    //                "mileage": "13.5 km/l",
    //                "distanceKm": 75.0,
    //                "durationMinutes": 85
    //            ],
    //            [
    //                "driverId": "53AC589E-1861-4290-A763-861E54234A1B",
    //                "driverName": "Amit Kumar",
    //                "vehicleNo": "DL8CAF4567",
    //                "tripDetail": "Round trip from Delhi depot",
    //                "date": Timestamp(date: Date(timeIntervalSince1970: 1713378600)),
    //                "cost": 1800.0,
    //                "mileage": "11.5 km/l",
    //                "distanceKm": 140.0,
    //                "durationMinutes": 150
    //            ],
    //            [
    //                "driverId": "990A74B0-0A94-4C4A-BF16-2F4CACD10CB5",
    //                "driverName": "Jaden Smith",
    //                "vehicleNo": "GJ01JK4321",
    //                "tripDetail": "Pickup from Surat port",
    //                "date": Timestamp(date: Date(timeIntervalSince1970: 1713810600)),
    //                "cost": 1100.0,
    //                "mileage": "14.2 km/l",
    //                "distanceKm": 70.0,
    //                "durationMinutes": 75
    //            ],
    //            [
    //                "driverId": "F4BAEAFF-AC3C-42F5-B6AE-92AA76117E1D",
    //                "driverName": "Yahi",
    //                "vehicleNo": "RJ14MN2211",
    //                "tripDetail": "Food supplies to Jaipur warehouse",
    //                "date": Timestamp(date: Date(timeIntervalSince1970: 1713897000)),
    //                "cost": 1700.0,
    //                "mileage": "10.5 km/l",
    //                "distanceKm": 120.0,
    //                "durationMinutes": 110
    //            ],
    //            [
    //                "driverId": "F5A5CF5E-6A81-47F2-B6E1-4A3D3C0B3C8E",
    //                "driverName": "Ramesh",
    //                "vehicleNo": "MP09XY6543",
    //                "tripDetail": "Round trip to Indore industrial zone",
    //                "date": Timestamp(date: Date(timeIntervalSince1970: 1713983400)),
    //                "cost": 1450.0,
    //                "mileage": "12.8 km/l",
    //                "distanceKm": 95.0,
    //                "durationMinutes": 105
    //            ],
    //            [
    //                "driverId": "FD201419-1794-4134-9085-B895E35F1F7C",
    //                "driverName": "John Doe",
    //                "vehicleNo": "TN10GH7890",
    //                "tripDetail": "Urgent parcel to Chennai office",
    //                "date": Timestamp(date: Date(timeIntervalSince1970: 1714069800)),
    //                "cost": 2100.0,
    //                "mileage": "14 km/l",
    //                "distanceKm": 160.0,
    //                "durationMinutes": 170
    //            ]
    //        ]
    //
    //        let db = Firestore.firestore()
    //        let collection = db.collection("pastTrips")
    //
    //        for trip in trips {
    //            collection.addDocument(data: trip) { error in
    //                if let error = error {
    //                    print("Error adding trip: \(error.localizedDescription)")
    //                } else {
    //                    print("Trip added successfully.")
    //                }
    //            }
    //        }
    //    }
    //
    //
    
//
//    func seedInventoryItems() {
//        let db = Firestore.firestore()
//        let items: [[String: Any]] = [
//            [ // Part
//                "name": "Brake Pad Set",
//                "quantity": 50,
//                "price": 1200.0,
//                "type": "part",
//                "partID": "BRKPAD-1001"
//            ],
//            [ // Part
//                "name": "Air Filter",
//                "quantity": 75,
//                "price": 300.0,
//                "type": "part",
//                "partID": "AIRFLT-3002"
//            ],
//            [ // Part
//                "name": "Spark Plug",
//                "quantity": 200,
//                "price": 150.0,
//                "type": "part",
//                "partID": "SPPLG-7005"
//            ],
//            [ // Part
//                "name": "Fuel Pump",
//                "quantity": 20,
//                "price": 2800.0,
//                "type": "part",
//                "partID": "FLPMP-1010"
//            ],
//            [ // Part
//                "name": "Timing Belt",
//                "quantity": 30,
//                "price": 1800.0,
//                "type": "part",
//                "partID": "TMBLT-4421"
//            ],
//            [ // Part
//                "name": "Clutch Plate",
//                "quantity": 25,
//                "price": 2200.0,
//                "type": "part",
//                "partID": "CLTPL-3345"
//            ],
//            [ // Part
//                "name": "Alternator",
//                "quantity": 15,
//                "price": 5000.0,
//                "type": "part",
//                "partID": "ALT-8890"
//            ],
//            [ // Fluid
//                "name": "Engine Oil 5W-30",
//                "quantity": 100,
//                "price": 450.0,
//                "type": "fluid"
//            ],
//            [ // Fluid
//                "name": "Coolant",
//                "quantity": 60,
//                "price": 250.0,
//                "type": "fluid"
//            ],
//            [ // Fluid
//                "name": "Brake Fluid",
//                "quantity": 40,
//                "price": 180.0,
//                "type": "fluid"
//            ]
//        ]
//
//        for item in items {
//            db.collection("inventoryItems").addDocument(data: item) { error in
//                if let error = error {
//                    print("❌ Error adding inventory item: \(error.localizedDescription)")
//                } else {
//                    print("✅ Inventory item added.")
//                }
//            }
//        }
//    }

