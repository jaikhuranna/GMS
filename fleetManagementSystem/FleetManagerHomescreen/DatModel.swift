//
//  InfoCardView.swift
//  Fleet_Management
//
//  Created by admin81 on 22/04/25.
//




import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import Combine

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


struct PastMaintenance: Identifiable {
    let id = UUID()
    let note: String
    let observerName: String
    let dateOfMaintenance: String
    let vehicleNo: String
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

// MARK: – Ve Model
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
    
    enum VehicleType: String, CaseIterable, Identifiable {
        case HMV
        case LMV
        
        var id: String { rawValue }
    }
}

// MARK: – Driver Model
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

// MARK: – PastTrip Model
struct PastTrip: Identifiable {
    let id: String
    let driverId: String
    let tripDetail: String
    let date: Date
    let cost: Double
    let mileage: String
    let distanceKm: Double
    let durationMinutes: Int
    var driverName: String? 
    let vehicleNo: String
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
                    .foregroundColor(Color.accentColor)
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 50, height: 50) // Increased size here
                    Image(systemName: card.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color.accentColor)
                }
            }
            Text(card.title)
                .font(.subheadline)
                .foregroundColor(Color.accentColor)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}



struct OngoingTrip: Identifiable {
  let id: String
  let driverName: String
  let vehicleNo: String
  let tripDetail: String
  let driverImageUrl: String?
}

final class DashboardService: ObservableObject {
  @Published var runningTripsCount      = 0
  @Published var carsInMaintenanceCount = 0
  @Published var idleVehiclesCount      = 0
  @Published var idleDriversCount       = 0
  @Published var ongoingTrips: [OngoingTrip] = []

  private let db = Firestore.firestore()
  private var cancellables = Set<AnyCancellable>()

  func fetchAll() {
    let group = DispatchGroup()

    // 1) Running trips = bookingRequests where status == inProgress
    group.enter()
    db.collection("bookingRequests")
      .whereField("status", isEqualTo: "accepted")
      .getDocuments { snap, _ in
        self.runningTripsCount = snap?.documents.count ?? 0
        self.ongoingTrips = snap?.documents.compactMap { doc in
          let data = doc.data()
          guard
            let driverName = data["driverName"]  as? String,
            let vehicleNo  = data["vehicleNo"]   as? String,
            let from       = data["pickupName"]  as? String,
            let to         = data["dropoffName"] as? String
          else { return nil }
          return OngoingTrip(
            id: doc.documentID,
            driverName: driverName,
            vehicleNo: vehicleNo,
            tripDetail: "\(from) → \(to)",
            driverImageUrl: data["driverImageUrl"] as? String
          )
        } ?? []
        group.leave()
      }

    // 2) Cars in maintenance = vehicles where inMaintenance == true
    group.enter()
    db.collection("vehicles")
      .whereField("inMaintenance", isEqualTo: true)
      .getDocuments { snap, _ in
        self.carsInMaintenanceCount = snap?.documents.count ?? 0
        group.leave()
      }

    // 3) Idle vehicles = total vehicles minus those in an inProgress trip
    group.enter()
    Publishers.Zip(
      db.collection("vehicles")
        .getDocumentsPublisher(),
      db.collection("bookingRequests")
        .whereField("status", isEqualTo: "inProgress")
        .getDocumentsPublisher()
    )
    .sink(receiveCompletion: { _ in }) { vehSnap, tripSnap in
      let allIds  = Set(vehSnap.documents.map { $0.documentID })
      let busyIds = Set(tripSnap.documents.compactMap { $0.data()["vehicleId"] as? String })
      self.idleVehiclesCount = allIds.subtracting(busyIds).count
      group.leave()
    }
    .store(in: &cancellables)

    // 4) Idle drivers = total drivers minus those on an inProgress trip
    group.enter()
    Publishers.Zip(
      db.collection("fleetDrivers")
        .getDocumentsPublisher(),
      db.collection("bookingRequests")
        .whereField("status", isEqualTo: "inProgress")
        .getDocumentsPublisher()
    )
    .sink(receiveCompletion: { _ in }) { drvSnap, tripSnap in
      let allIds  = Set(drvSnap.documents.map { $0.documentID })
      let busyIds = Set(tripSnap.documents.compactMap { $0.data()["driverId"] as? String })
      self.idleDriversCount = allIds.subtracting(busyIds).count
      group.leave()
    }
    .store(in: &cancellables)
  }
}

// MARK: – Firestore + Combine helper

extension Query {
  /// Wraps `getDocuments(completion:)` in a Combine publisher
  func getDocumentsPublisher() -> AnyPublisher<QuerySnapshot, Error> {
    Future<QuerySnapshot, Error> { promise in
      self.getDocuments { snapshot, error in
        if let error = error {
          promise(.failure(error))
        } else if let snapshot = snapshot {
          promise(.success(snapshot))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}



struct BookingRequest: Identifiable, Equatable {
    var driverId: String
    let id: String
    let pickupName: String
    let pickupAddress: String
    let pickupLatitude: Double
    let pickupLongitude: Double
    let dropoffName: String
    let dropoffAddress: String
    let dropoffLatitude: Double
    let dropoffLongitude: Double
    let distanceKm: Double
    let createdAt: Date
    let vehicleNo: String

    // Failable init pulling addresses and coordinates
    init?(_ document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        guard
            let driverId      = data["driverId"]      as? String,
            let pickupName    = data["pickupName"]    as? String,
            let pickupAddress = data["pickupAddress"] as? String,
            let pickupLat     = data["pickupLatitude"] as? Double,
            let pickupLon     = data["pickupLongitude"]as? Double,
            let dropoffName   = data["dropoffName"]   as? String,
            let dropoffAddress = data["dropoffAddress"]as? String,
            let dropoffLat    = data["dropoffLatitude"]as? Double,
            let dropoffLon    = data["dropoffLongitude"]as? Double,
            let km            = data["distanceKm"]    as? Double,
            let ts            = data["createdAt"]     as? Timestamp,
            let vehicleNo     = data["vehicleNo"]     as? String
        else { return nil }

        self.driverId         = driverId
        self.id               = document.documentID
        self.pickupName       = pickupName
        self.pickupAddress    = pickupAddress
        self.pickupLatitude   = pickupLat
        self.pickupLongitude  = pickupLon
        self.dropoffName      = dropoffName
        self.dropoffAddress   = dropoffAddress
        self.dropoffLatitude  = dropoffLat
        self.dropoffLongitude = dropoffLon
        self.distanceKm       = km
        self.createdAt        = ts.dateValue()
        self.vehicleNo        = vehicleNo
    }

    // Non-failable init for previews/mocks
    init(
        driverId: String,
        id: String,
        pickupName: String,
        pickupAddress: String,
        pickupLatitude: Double,
        pickupLongitude: Double,
        dropoffName: String,
        dropoffAddress: String,
        dropoffLatitude: Double,
        dropoffLongitude: Double,
        distanceKm: Double,
        createdAt: Date,
        vehicleNo: String
    ) {
        self.driverId         = driverId
        self.id               = id
        self.pickupName       = pickupName
        self.pickupAddress    = pickupAddress
        self.pickupLatitude   = pickupLatitude
        self.pickupLongitude  = pickupLongitude
        self.dropoffName      = dropoffName
        self.dropoffAddress   = dropoffAddress
        self.dropoffLatitude  = dropoffLatitude
        self.dropoffLongitude = dropoffLongitude
        self.distanceKm       = distanceKm
        self.createdAt        = createdAt
        self.vehicleNo        = vehicleNo
    }
}
