//
//  InfoCardView.swift
//  Fleet_Management
//
//  Created by admin81 on 22/04/25.
//

import SwiftUI
import Foundation

struct InfoCard: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let icon: String
}

struct Trip: Identifiable {
    let id = UUID()
    let driverName: String
    let vehicleNo: String
    let tripDetail: String
    let driverImage: String
}

struct PastTrip: Identifiable {
    let id = UUID()
    let driverName: String
    let vehicleNo: String
    let tripDetail: String
    let driverImage: String
    let date: String // <-- Add this back
}

struct PastMaintenance: Identifiable {
    let id = UUID()
    let note: String
    let observerName: String
    let dateOfMaintenance: String
}


struct VehicleDetail: Identifiable{
    var id = UUID()
    let vehicleNo: String
    let engineNumber: String
    let modelNuumber: String
    let vehicleTyper: String
    let licenseRenewed: String
    let maintenanceDate: String
    let distanceTravelled: Int
}

struct Vehicle: Identifiable {
    var id: String
    var vehicleNo: String
    var distanceTravelled: Int
    var vehicleCategory: String
    var vehicleType: String
    var modelName: String
    var averageMileage: Double
    var engineNo: String
    var licenseRenewalDate: Date
    var carImage: String // Optional: for static images from Assets

    enum VehicleType {
        case HMV
        case LMV
    }
}

struct Driver: Identifiable {
    var id: String
    var driverName: String
    var driverImage: String
    var driverExperience: Int
    var driverAge: Int
    var driverContactNo: String
    var driverLicenseNo: String
    var driverLicenseType: String


    enum DriverType {
        case HMV
        case LMV
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") { scanner.currentIndex = scanner.string.index(after: scanner.currentIndex) }

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct InfoCardView: View {
    var card: InfoCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(card.number)
                    .font(.title)
                    .bold()
                    .foregroundColor(Color(hex: "#396BAF"))
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50) // Increased size here
                    Image(systemName: card.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#396BAF"))
                }
            }
            Text(card.title)
                .font(.subheadline)
                .foregroundColor(Color(hex: "#396BAF"))
        }
        .padding()
        .background(Color(red: 237/255, green: 242/255, blue: 252/255))
        .cornerRadius(16)
    }
}

