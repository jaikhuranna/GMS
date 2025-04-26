//
//  Input Data.swift
//  fleetManagementSystem
//
//  Created by user@61 on 24/04/25.
//

import Foundation
import UIKit
import FirebaseFirestore
// Mark :- Vehcile sample data

//let sampleFleet: [FleetVehicle] = [
//    {
//        var v = FleetVehicle(
//            vehicleNo: "MH12AB1234",
//            modelName: "Toyota Innova",
//            engineNo: "ENG1234567890",
//            licenseRenewalDate: Date().addingTimeInterval(60*60*24*365),
//            distanceTravelled: 120000,
//            averageMileage: 12.5,
//            vehicleType: .car,
//            vehicleCategory: .LMV,
//            insuranceProofImage: UIImage(systemName: "doc.richtext"),
//            vehiclePhoto: UIImage(systemName: "car")
//        )
//        return v
//    }(),
//    {
//        var v = FleetVehicle(
//            vehicleNo: "MH14XY5678",
//            modelName: "Tata Ace",
//            engineNo: "ENG9876543210",
//            licenseRenewalDate: Date().addingTimeInterval(60*60*24*200),
//            distanceTravelled: 95000,
//            averageMileage: 10.2,
//            vehicleType: .truck,
//            vehicleCategory: .HMV,
//            insuranceProofImage: UIImage(systemName: "doc.text"),
//            vehiclePhoto: UIImage(systemName: "truck")
//        )
//        return v
//    }(),
//    {
//        var v = FleetVehicle(
//            vehicleNo: "MH10GH1122",
//            modelName: "Ashok Leyland Bus",
//            engineNo: "ENG1029384756",
//            licenseRenewalDate: Date().addingTimeInterval(60*60*24*400),
//            distanceTravelled: 210000,
//            averageMileage: 6.8,
//            vehicleType: .bus,
//            vehicleCategory: .HMV,
//            insuranceProofImage: UIImage(systemName: "doc.plaintext"),
//            vehiclePhoto: UIImage(systemName: "bus")
//        )
//        return v
//    }(),
//    {
//        var v = FleetVehicle(
//            vehicleNo: "MH20QR3344",
//            modelName: "Hyundai Verna",
//            engineNo: "ENG111222333",
//            licenseRenewalDate: Date().addingTimeInterval(60*60*24*180),
//            distanceTravelled: 85000,
//            averageMileage: 14.0,
//            vehicleType: .car,
//            vehicleCategory: .LMV,
//            insuranceProofImage: UIImage(systemName: "doc.text.image"),
//            vehiclePhoto: UIImage(systemName: "car")
//        )
//        return v
//    }(),
//    {
//        var v = FleetVehicle(
//            vehicleNo: "MH31LK7788",
//            modelName: "Mahindra Bolero Pickup",
//            engineNo: "ENG5566778899",
//            licenseRenewalDate: Date().addingTimeInterval(60*60*24*250),
//            distanceTravelled: 132000,
//            averageMileage: 11.3,
//            vehicleType: .truck,
//            vehicleCategory: .HMV,
//            insuranceProofImage: UIImage(systemName: "doc.richtext"),
//            vehiclePhoto: UIImage(systemName: "car")
//        )
//        return v
//    }()
//]


// MARK : - Driver sample data 

//let sampleDrivers: [FleetDriver] = [
//    {
//        var d = FleetDriver(
//            name: "John Doe",
//            age: 35,
//            licenseNo: "LD1234567890",
//            contactNo: "+91 9876543210",
//            experience: 10,
//            licenseType: .LMV,
//            driverImage: UIImage(systemName: "person.fill"),
//            licenseImage: UIImage(systemName: "doc.text")
//        )
//        return d
//    }(),
//    {
//        var d = FleetDriver(
//            name: "Jane Smith",
//            age: 29,
//            licenseNo: "LD9876543210",
//            contactNo: "+91 9988776655",
//            experience: 5,
//            licenseType: .HMV,
//            driverImage: UIImage(systemName: "person.fill"),
//            licenseImage: UIImage(systemName: "doc.text")
//        )
//        return d
//    }(),
//    {
//        var d = FleetDriver(
//            name: "Amit Kumar",
//            age: 42,
//            licenseNo: "LD1029384756",
//            contactNo: "+91 9000112233",
//            experience: 18,
//            licenseType: .LMV,
//            driverImage: UIImage(systemName: "person.fill"),
//            licenseImage: UIImage(systemName: "doc.text")
//        )
//        return d
//    }(),
//    {
//        var d = FleetDriver(
//            name: "Priya Verma",
//            age: 30,
//            licenseNo: "LD5647382910",
//            contactNo: "+91 8811223344",
//            experience: 8,
//            licenseType: .HMV,
//            driverImage: UIImage(systemName: "person.fill"),
//            licenseImage: UIImage(systemName: "doc.text")
//        )
//        return d
//    }(),
//    {
//        var d = FleetDriver(
//            name: "Ravi Reddy",
//            age: 38,
//            licenseNo: "LD1928374650",
//            contactNo: "+91 7629348110",
//            experience: 12,
//            licenseType: .LMV,
//            driverImage: UIImage(systemName: "person.fill"),
//            licenseImage: UIImage(systemName: "doc.text")
//        )
//        return d
//    }()
//]

//
//// Assuming your struct definitions are as follows (including vehicleId):
//struct PastTrip: Identifiable, Codable {
//    let id: UUID
//    let vehicleId: String
//    let driverName: String
//    let vehicleNo: String
//    let tripDetail: String
//    let driverImage: String // Assuming this is a URL or identifier string
//    let date: String // Assuming date is stored as a String
//
//    init(id: UUID = UUID(), vehicleId: String, driverName: String, vehicleNo: String, tripDetail: String, driverImage: String, date: String) {
//        self.id = id
//        self.vehicleId = vehicleId
//        self.driverName = driverName
//        self.vehicleNo = vehicleNo
//        self.tripDetail = tripDetail
//        self.driverImage = driverImage
//        self.date = date
//    }
//}
//
//struct PastMaintenance: Identifiable, Codable {
//    let id: UUID
//    let vehicleNo: String
//    let note: String
//    let observerName: String
//    let dateOfMaintenance: String // Assuming date is stored as a String
//
//    init(id: UUID = UUID(), vehicleNo: String, note: String, observerName: String, dateOfMaintenance: String) {
//        self.id = id
//        self.vehicleNo = vehicleNo
//        self.note = note
//        self.observerName = observerName
//        self.dateOfMaintenance = dateOfMaintenance
//    }
//}
//
//// --- Extended Sample PastTrip data with vehicleId ---
//let extendedSamplePastTrips: [PastTrip] = [
//    PastTrip(vehicleId: "vehicle_MH12AB1234", driverName: "John Doe", vehicleNo: "MH12AB1234", tripDetail: "Mumbai to Pune", driverImage: "driver_john_doe.jpg", date: "2023-10-26"),
//    PastTrip(vehicleId: "vehicle_MH14CD5678", driverName: "Jane Smith", vehicleNo: "MH14CD5678", tripDetail: "Delhi to Jaipur", driverImage: "driver_jane_smith.jpg", date: "2023-10-25"),
//    PastTrip(vehicleId: "vehicle_MH10EF9012", driverName: "Peter Jones", vehicleNo: "MH10EF9012", tripDetail: "Bangalore to Chennai", driverImage: "driver_peter_jones.jpg", date: "2023-10-26"),
//    PastTrip(vehicleId: "vehicle_MH20QR3344", driverName: "Amit Kumar", vehicleNo: "MH20QR3344", tripDetail: "Kolkata to Puri", driverImage: "driver_amit_kumar.jpg", date: "2023-10-24"),
//    PastTrip(vehicleId: "vehicle_MH12AB1234", driverName: "John Doe", vehicleNo: "MH12AB1234", tripDetail: "Pune to Mumbai", driverImage: "driver_john_doe.jpg", date: "2023-10-27"),
//
//    // Added more PastTrip data
//    PastTrip(vehicleId: "vehicle_MH31LK7788", driverName: "Ravi Reddy", vehicleNo: "MH31LK7788", tripDetail: "Hyderabad to Bangalore", driverImage: "driver_ravi_reddy.jpg", date: "2023-10-27"),
//    PastTrip(vehicleId: "vehicle_MH14CD5678", driverName: "Jane Smith", vehicleNo: "MH14CD5678", tripDetail: "Jaipur to Delhi", driverImage: "driver_jane_smith.jpg", date: "2023-10-26"),
//    PastTrip(vehicleId: "vehicle_MH10EF9012", driverName: "Peter Jones", vehicleNo: "MH10EF9012", tripDetail: "Chennai to Bangalore", driverImage: "driver_peter_jones.jpg", date: "2023-10-27"),
//    PastTrip(vehicleId: "vehicle_MH20QR3344", driverName: "Amit Kumar", vehicleNo: "MH20QR3344", tripDetail: "Puri to Kolkata", driverImage: "driver_amit_kumar.jpg", date: "2023-10-25"),
//    PastTrip(vehicleId: "vehicle_MH31LK7788", driverName: "Ravi Reddy", vehicleNo: "MH31LK7788", tripDetail: "Bangalore to Hyderabad", driverImage: "driver_ravi_reddy.jpg", date: "2023-10-28")
//]
//
//// --- Extended Sample PastMaintenance data with vehicleId ---
//let extendedSamplePastMaintenances: [PastMaintenance] = [
//    PastMaintenance(vehicleNo: "MH12AB1234", note: "Oil change and filter replacement", observerName: "Mechanic A", dateOfMaintenance: "2023-10-20"),
//    PastMaintenance(vehicleNo: "MH14CD5678", note: "Tire rotation and alignment", observerName: "Mechanic B", dateOfMaintenance: "2023-09-15"),
//    PastMaintenance(vehicleNo: "MH10EF9012", note: "Brake pad replacement", observerName: "Mechanic C", dateOfMaintenance: "2023-10-01"),
//    PastMaintenance(vehicleNo: "MH12AB1234", note: "General checkup", observerName: "Mechanic A", dateOfMaintenance: "2023-10-22"),
//
//    // Added more PastMaintenance data
//    PastMaintenance(vehicleNo: "MH31LK7788", note: "Fluid level check", observerName: "Mechanic D", dateOfMaintenance: "2023-10-25"),
//    PastMaintenance(vehicleNo: "MH14CD5678", note: "Battery inspection", observerName: "Mechanic B", dateOfMaintenance: "2023-10-10"),
//    PastMaintenance(vehicleNo: "MH10EF9012", note: "Air filter replacement", observerName: "Mechanic C", dateOfMaintenance: "2023-10-15"),
//    PastMaintenance(vehicleNo: "MH20QR3344", note: "Coolant system flush", observerName: "Mechanic E", dateOfMaintenance: "2023-09-28"),
//    PastMaintenance(vehicleNo: "MH31LK7788", note: "Wiper blade replacement", observerName: "Mechanic D", dateOfMaintenance: "2023-10-26")
//]
//
//
//// You can now use these arrays (extendedSamplePastTrips and extendedSamplePastMaintenances)
//// to push data to Firebase or for testing purposes.
