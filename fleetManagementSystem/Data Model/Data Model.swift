//
//  Data Model.swift
//  fleetManagementSystem
//
//  Created by user@61 on 24/04/25.
//

import Foundation
import UIKit
import FirebaseCore


// MARK: - FleetVehicle Model

enum VehicleCategory: String, CaseIterable, Codable {
    case HMV, LMV
}

enum VehicleType: String, CaseIterable, Codable {
    case car, truck, bus
}

struct FleetVehicle: Identifiable, Codable {
    let id: UUID
    var vehicleNo: String
    var modelName: String
    var engineNo: String
    var licenseRenewalDate: Date
    var distanceTravelled: Double
    var averageMileage: Double
    var vehicleType: VehicleType
    var vehicleCategory: VehicleCategory
    var insuranceProofImage: UIImage?
    var vehiclePhoto: UIImage?

    enum CodingKeys: String, CodingKey {
        case id, vehicleNo, modelName, engineNo,
             licenseRenewalDate, distanceTravelled,
             averageMileage, vehicleType, vehicleCategory
    }

    init(
        id: UUID = UUID(),
        vehicleNo: String,
        modelName: String,
        engineNo: String,
        licenseRenewalDate: Date,
        distanceTravelled: Double,
        averageMileage: Double,
        vehicleType: VehicleType,
        vehicleCategory: VehicleCategory,
        insuranceProofImage: UIImage? = nil,
        vehiclePhoto: UIImage? = nil
    ) {
        self.id = id
        self.vehicleNo = vehicleNo
        self.modelName = modelName
        self.engineNo = engineNo
        self.licenseRenewalDate = licenseRenewalDate
        self.distanceTravelled = distanceTravelled
        self.averageMileage = averageMileage
        self.vehicleType = vehicleType
        self.vehicleCategory = vehicleCategory
        self.insuranceProofImage = insuranceProofImage
        self.vehiclePhoto = vehiclePhoto
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        vehicleNo = try container.decode(String.self, forKey: .vehicleNo)
        modelName = try container.decode(String.self, forKey: .modelName)
        engineNo = try container.decode(String.self, forKey: .engineNo)
        licenseRenewalDate = try container.decode(Date.self, forKey: .licenseRenewalDate)
        distanceTravelled = try container.decode(Double.self, forKey: .distanceTravelled)
        averageMileage = try container.decode(Double.self, forKey: .averageMileage)
        vehicleType = try container.decode(VehicleType.self, forKey: .vehicleType)
        vehicleCategory = try container.decode(VehicleCategory.self, forKey: .vehicleCategory)
        insuranceProofImage = nil
        vehiclePhoto = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(vehicleNo, forKey: .vehicleNo)
        try container.encode(modelName, forKey: .modelName)
        try container.encode(engineNo, forKey: .engineNo)
        try container.encode(licenseRenewalDate, forKey: .licenseRenewalDate)
        try container.encode(distanceTravelled, forKey: .distanceTravelled)
        try container.encode(averageMileage, forKey: .averageMileage)
        try container.encode(vehicleType, forKey: .vehicleType)
        try container.encode(vehicleCategory, forKey: .vehicleCategory)
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "vehicleNo": vehicleNo,
            "modelName": modelName,
            "engineNo": engineNo,
            "licenseRenewalDate": Timestamp(date: licenseRenewalDate),
            "distanceTravelled": distanceTravelled,
            "averageMileage": averageMileage,
            "vehicleType": vehicleType.rawValue,
            "vehicleCategory": vehicleCategory.rawValue
        ]
    }
}

// MARK: - FleetDriver Model

enum LicenseType: String, Codable {
    case HMV, LMV
}

struct FleetDriver: Identifiable, Codable {
    let id: UUID
    var name: String
    var age: Int
    var licenseNo: String
    var contactNo: String
    var experience: Int  // in years
    var licenseType: LicenseType
    var driverImage: UIImage?
    var licenseImage: UIImage?

    enum CodingKeys: String, CodingKey {
        case id, name, age, licenseNo, contactNo, experience, licenseType
    }

    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        licenseNo: String,
        contactNo: String,
        experience: Int,
        licenseType: LicenseType,
        driverImage: UIImage? = nil,
        licenseImage: UIImage? = nil
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.licenseNo = licenseNo
        self.contactNo = contactNo
        self.experience = experience
        self.licenseType = licenseType
        self.driverImage = driverImage
        self.licenseImage = licenseImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        licenseNo = try container.decode(String.self, forKey: .licenseNo)
        contactNo = try container.decode(String.self, forKey: .contactNo)
        experience = try container.decode(Int.self, forKey: .experience)
        licenseType = try container.decode(LicenseType.self, forKey: .licenseType)
        driverImage = nil
        licenseImage = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(licenseNo, forKey: .licenseNo)
        try container.encode(contactNo, forKey: .contactNo)
        try container.encode(experience, forKey: .experience)
        try container.encode(licenseType, forKey: .licenseType)
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "age": age,
            "licenseNo": licenseNo,
            "contactNo": contactNo,
            "experience": experience,
            "licenseType": licenseType.rawValue
        ]
    }
}
