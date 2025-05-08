//
//  NotificationScreen.swift
//  Fleet_Notification
//
//  Created by user@89 on 07/05/25.
//

//import SwiftUI
//import FirebaseFirestore
//
//
//struct NotificationScreen: View {
//    @State private var billNotifications: [NotificationItem] = []
//    
//    
//    var body: some View {
//        
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//                NotificationSection(title: "Trips Acceptance", items: [
//                    .tripResponse(name: "Ravi Kumar", status: .accepted, vehicle: "KN23CB6463", route: "Mysore - Bangalore", date: "24/05/26 - 27/05/26"),
//                    .tripResponse(name: "Ravi Kumar", status: .rejected, vehicle: "KN23CB6463", route: "Mysore - Bangalore", date: "24/05/26 - 27/05/26")
//                ])
//
//                NotificationSection(title: "Bill Approvals", items: billNotifications)
//
//
//                NotificationSection(title: "Post Maintenance Reviews", items: [
//                    .maintenanceReview(task: "Tire Replace Task", vehicle: "KN23CB6463"),
//                    .maintenanceReview(task: "Tire Replace Task", vehicle: "KN23CB6463")
//                ])
//
//                NotificationSection(title: "Completed Trips", items: [
//                    .tripCompleted(name: "Ravi Kumar", vehicle: "KN23CB6463", route: "Mysore - Bangalore", date: "24/05/26 - 27/05/26"),
//                    .tripCompleted(name: "Ravi Kumar", vehicle: "KN23CB6463", route: "Mysore - Bangalore", date: "24/05/26 - 27/05/26")
//                ])
//
//                NotificationSection(title: "Inventory", items: [
//                    .inventoryRestock(item: "Steering Wheel", quantity: 4),
//                    .inventoryNewPart(item: "Wheel 10AB", quantity: 4)
//                ])
//            }
//            .onAppear {
//                FirebaseModules.shared.fetchPendingBillNotifications { notifications in
//                    self.billNotifications = notifications
//                }
//            }
//
//            .padding()
//        }
//        .navigationTitle("Notifications")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - Notification Section
//
//struct NotificationSection: View {
//    let title: String
//    let items: [NotificationItem]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(title)
//                .font(.title3.bold())
//                .padding(.bottom, 4)
//
//            ForEach(items.indices, id: \.self) { index in
//                let item = items[index]
//                
//                switch item {
//                case let .billRaised(id, task, vehicle):
//                    NavigationLink {
//                        BillApprovalLoaderView(billId: id)
//                    } label: {
//                        item.notificationView()
//                    }
//
//                case .maintenanceReview:
//                    NavigationLink(destination: PostMaintenanceReviewView()) {
//                        item.notificationView()
//                    }
//                case .inventoryRestock, .inventoryNewPart:
//                    NavigationLink(destination: InventoryRequestNotification()) {
//                        item.notificationView()
//                    }
//                default:
//                    item.notificationView()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Notification Item Enum
//
//enum NotificationItem {
//    case tripResponse(name: String, status: TripStatus, vehicle: String, route: String, date: String)
//    case billRaised(id: String, task: String, vehicle: String)
//    case maintenanceReview(task: String, vehicle: String)
//    case tripCompleted(name: String, vehicle: String, route: String, date: String)
//    case inventoryRestock(item: String, quantity: Int)
//    case inventoryNewPart(item: String, quantity: Int)
//
//    enum TripStatus {
//        case accepted, rejected
//    }
//
//    @ViewBuilder
//    func notificationView() -> some View {
//        HStack(alignment: .top, spacing: 10) {
//            Image(systemName: iconName)
//                .resizable()
//                .frame(width: 24, height: 24)
//                .foregroundColor(iconColor)
//
//            VStack(alignment: .leading, spacing: 4) {
//                switch self {
//                case let .tripResponse(name, status, vehicle, route, date):
//                    Text("\(name) has \(status == .accepted ? "accepted" : "rejected") the trip")
//                        .foregroundColor(status == .accepted ? .green : .red)
//                        .bold()
//                    Text("\(route), \(vehicle)")
//                    Text(date)
//
//                case let .billRaised(id, task, vehicle):
//
//                    Text("Maintenance Manager has raised a request")
//                        .foregroundColor(Color(hex: "#F18701"))
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                        .lineSpacing(2)
//                    Text(task)
//                    Text(vehicle)
//
//                case let .maintenanceReview(task, vehicle):
//                    Text("Maintenance Manager has raised a request")
//                        .foregroundColor(Color(hex: "#F18701"))
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                        .lineSpacing(2)
//                    Text(task)
//                    Text(vehicle)
//
//
//                case let .tripCompleted(name, vehicle, route, date):
//                    Text("\(name) has completed the trip.")
//                        .foregroundColor(.green)
//                        .bold()
//                    Text("\(route), \(vehicle)")
//                    Text(date)
//
//                case let .inventoryRestock(item, quantity):
//                    Text("Maintenance has requested for restocking")
//                        .foregroundColor(Color(hex: "#F18701"))
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                        .lineSpacing(2)
//                    Text(item)
//                    Text("Quantity: \(quantity)")
//
//                case let .inventoryNewPart(item, quantity):
//                    Text("Maintenance has requested a new part")
//                        .foregroundColor(Color(hex: "#F18701"))
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                        .lineSpacing(2)
//                    Text(item)
//                    Text("Quantity: \(quantity)")
//                }
//            }
//            .font(.subheadline)
//            .foregroundColor(Color(hex: "#396BAF"))
//
//            Spacer()
//        }
//        .padding()
//        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
//        .cornerRadius(12)
//    }
//
//    private var iconName: String {
//        switch self {
//        case .tripResponse: return "person.fill"
//        case .billRaised: return "doc.text.fill"
//        case .maintenanceReview: return "wrench.and.screwdriver.fill"
//        case .tripCompleted: return "checkmark.circle.fill"
//        case .inventoryRestock, .inventoryNewPart: return "drop.fill"
//        }
//    }
//
//    private var iconColor: Color {
//        switch self {
//        case .tripResponse(_, let status, _, _, _):
//            return status == .accepted ? .green : .red
//        case .billRaised: return Color(hex: "#F18701")
//        case .maintenanceReview: return Color(hex: "#F18701")
//        case .tripCompleted: return .green
//        case .inventoryRestock, .inventoryNewPart: return .red
//        }
//    }
//}
//
//// MARK: - Preview
//
//struct NotificationScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            NotificationScreen()
//        }
//    }
//}



import SwiftUI
import FirebaseFirestore
import CoreLocation
import MapKit

// MARK: – Notification Screen

struct NotificationScreen: View {
    @StateObject private var viewModel = NotificationViewModel()
    

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // 1) Live Off-Route Alerts
                if !viewModel.offRouteAlerts.isEmpty {
                    NotificationSection(
                        title: "Live Off-Route Alerts",
                        items: viewModel.offRouteAlerts
                    )
                }

                // 2) Maintenance Reports (from Firestore)
                if !viewModel.maintenanceItems.isEmpty {
                    NotificationSection(
                        title: "Maintenance Reports",
                        items: viewModel.maintenanceItems
                    )
                }

                // 3) Static/demo sections
                NotificationSection(title: "Trips Acceptance",           items: viewModel.tripResponses)
                
                
                if !viewModel.billRequests.isEmpty {
                    NotificationSection(title: "Bill Approvals", items: viewModel.billRequests)
                }

                
                NotificationSection(title: "Post Maintenance Reviews",  items: viewModel.maintenanceReviews)
                NotificationSection(title: "Completed Trips",           items: viewModel.tripCompletions)
                NotificationSection(title: "Inventory",                 items: viewModel.inventoryNotifications)
            }
            .padding()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.fetchAllNotifications() }
    }
}

// MARK: – ViewModel

final class NotificationViewModel: ObservableObject {
    @Published var offRouteAlerts:      [NotificationItem] = []
    @Published var maintenanceItems:   [NotificationItem] = []
    @Published var tripResponses:      [NotificationItem] = []
    @Published var billRequests:       [NotificationItem] = []
    @Published var maintenanceReviews: [NotificationItem] = []
    @Published var tripCompletions:    [NotificationItem] = []
    @Published var inventoryNotifications: [NotificationItem] = []

    private let db = Firestore.firestore()

    func fetchAllNotifications() {
        fetchOffRouteAlerts()
        fetchMaintenanceReports()
        fetchTripResponses()
        fetchBillRequests()
        fetchMaintenanceReviews()
        fetchCompletedTrips()
        fetchInventory()
    }

    private func fetchOffRouteAlerts() {
        db.collection("notifications")
          .whereField("title", isEqualTo: "Off-Route Alert")
          .order(by: "timestamp", descending: true)
          .addSnapshotListener { [weak self] snap, error in
            if let error = error {
              print("🔴 Off-route listener error:", error.localizedDescription)
              return
            }
            guard let docs = snap?.documents else { return }

            let alerts = docs.compactMap { doc -> NotificationItem? in
              let d = doc.data()
              guard
                let vehicle  = d["vehicleNumber"] as? String,
                let driver   = d["driverId"]    as? String,
                let gp       = d["location"]    as? GeoPoint,
                let mapsUrl  = d["mapsUrl"]     as? String,
                let ts       = d["timestamp"]   as? Timestamp,
                let tripId   = d["tripId"]      as? String
              else { return nil }

              return .offRoute(
                vehicle:     vehicle,
                driverId:    driver,
                location:    CLLocationCoordinate2D(latitude: gp.latitude, longitude: gp.longitude),
                mapsUrl:     mapsUrl,
                date:        ts.dateValue(),
                tripId:      tripId
              )
            }

            DispatchQueue.main.async {
              self?.offRouteAlerts = alerts
            }
        }
    }


    // — Maintenance Reports
    private func fetchMaintenanceReports() {
        db.collection("maintenanceReports")
          .order(by: "timestamp", descending: true)
          .getDocuments { snap, _ in
            guard let docs = snap?.documents else { return }
            DispatchQueue.main.async {
                self.maintenanceItems = docs.compactMap { doc in
                    let d = doc.data()
                    guard
                        let vehicle = d["vehicleNumber"] as? String,
                        let issues  = d["issues"]       as? [String],
                        let notes   = d["notes"]        as? String,
                        let ts      = d["timestamp"]    as? Timestamp
                    else { return nil }
                    return .maintenanceReport(
                        vehicle: vehicle,
                        issues: issues,
                        notes: notes,
                        date: ts.dateValue()
                    )
                }
            }
        }
    }

    // MARK: — Static/demo data

    private func fetchTripResponses() {
        tripResponses = [
            .tripResponse(name: "Ravi Kumar", status: .accepted, vehicle: "KN23CB6463", route: "Mysore – Bangalore", date: "24/05/26 – 27/05/26"),
            .tripResponse(name: "Ravi Kumar", status: .rejected, vehicle: "KN23CB6463", route: "Mysore – Bangalore", date: "24/05/26 – 27/05/26"),
        ]
    }

    private func fetchBillRequests() {
        FirebaseModules.shared.fetchPendingBillNotifications { items in
            DispatchQueue.main.async {
                self.billRequests = items
            }
        }
    }


    private func fetchMaintenanceReviews() {
        maintenanceReviews = [
            .maintenanceReview(task: "Oil Change Review",       vehicle: "KN23CB6463"),
            .maintenanceReview(task: "Wheel Alignment Review", vehicle: "MH31LK7788"),
        ]
    }

    private func fetchCompletedTrips() {
        tripCompletions = [
            .tripCompleted(name: "Ravi Kumar", vehicle: "KN23CB6463", route: "Mysore – Bangalore", date: "24/05/26 – 27/05/26"),
            .tripCompleted(name: "Ravi Kumar", vehicle: "MH31LK7788", route: "Chennai – Coimbatore", date: "20/04/26 – 21/04/26"),
        ]
    }

    private func fetchInventory() {
        inventoryNotifications = [
            .inventoryRestock(item: "Steering Wheel", quantity: 4),
            .inventoryNewPart(item: "Wheel 10AB",    quantity: 4),
        ]
    }
}

// MARK: – Notification Section

struct NotificationSection: View {
    let title: String
    let items: [NotificationItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .padding(.bottom, 4)

            ForEach(items) { item in
                item.navigationLink(
                    destination: { item.destinationView() },
                    label:       { item.notificationView() }
                )
            }
        }
    }
}

// MARK: – Notification Item

enum NotificationItem: Identifiable {
    case tripResponse(name: String, status: TripStatus, vehicle: String, route: String, date: String)
    case billRaised(id: String, task: String, vehicle: String)

    case maintenanceReview(task: String, vehicle: String)
    case tripCompleted(name: String, vehicle: String, route: String, date: String)
    case inventoryRestock(item: String, quantity: Int)
    case inventoryNewPart(item: String, quantity: Int)
    case maintenanceReport(vehicle: String, issues: [String], notes: String, date: Date)
    case offRoute(
      vehicle: String,
      driverId: String,
      location: CLLocationCoordinate2D,
      mapsUrl: String,
      date: Date,
      tripId: String
    )


    var id: String {
        switch self {
        case let .tripResponse(name, status, vehicle, _, date):
            return "trip_\(name)_\(status.rawValue)_\(vehicle)_\(date)"
            
            
        case let .billRaised(id, task, vehicle):
            return "bill_\(id)_\(task)_\(vehicle)"

        case let .maintenanceReview(task, vehicle):
            return "review_\(task)_\(vehicle)"
        case let .tripCompleted(name, vehicle, _, date):
            return "completed_\(name)_\(vehicle)_\(date)"
        case let .inventoryRestock(item, qty):
            return "restock_\(item)_\(qty)"
        case let .inventoryNewPart(item, qty):
            return "newpart_\(item)_\(qty)"
        case let .maintenanceReport(vehicle, issues, _, date):
            return "maint_\(vehicle)_\(issues.joined())_\(date.timeIntervalSince1970)"
        case let .offRoute(vehicle, driver, _, _, date, trip):
                    return "offRoute_\(vehicle)_\(driver)_\(trip)_\(Int(date.timeIntervalSince1970))"
                
        }
    }

    enum TripStatus: String { case accepted, rejected }
}

// MARK: – Navigation & Rendering

extension NotificationItem {
    @ViewBuilder
    func navigationLink<Label: View, Destination: View>(
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label:       @escaping () -> Label
    ) -> some View {
        switch self {
        case .billRaised, .maintenanceReview, .inventoryRestock, .inventoryNewPart:
            NavigationLink(destination: destination(), label: label)
        case .offRoute:
            NavigationLink(destination: OffRouteMapView(alert: self), label: label)
        default:
            label()
        }
    }

    @ViewBuilder
    func destinationView() -> some View {
        switch self {
            
        case let .billRaised(id, _, _):
            BillApprovalLoaderView(billId: id)

        case .maintenanceReview:
            PostMaintenanceReviewView()
        case .inventoryRestock, .inventoryNewPart:
            InventoryRequestNotification()
        default:
            EmptyView()
        }
    }

    func notificationView() -> some View {
        Group {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: iconName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(iconColor)

                VStack(alignment: .leading, spacing: 4) {
                    switch self {
                    case let .tripResponse(name, status, vehicle, route, date):
                        Text("\(name) has \(status.rawValue) the trip")
                            .bold()
                            .foregroundColor(status == .accepted ? .green : .red)
                        Text("\(route), \(vehicle)")
                        Text(date)

                    case let .billRaised(_, task, vehicle):
                        Text("Maintenance Manager raised a request")
                            .bold()
                            .foregroundColor(Color(hex: "#F18701"))
                        Text(task)
                        Text(vehicle)

                    case let .maintenanceReview(task, vehicle):
                        Text("Maintenance Manager raised a review")
                            .bold()
                            .foregroundColor(Color(hex: "#F18701"))
                        Text(task)
                        Text(vehicle)

                    case let .tripCompleted(name, vehicle, route, date):
                        Text("\(name) has completed the trip")
                            .bold()
                            .foregroundColor(.green)
                        Text("\(route), \(vehicle)")
                        Text(date)

                    case let .inventoryRestock(item, qty):
                        Text("Requested restocking")
                            .bold()
                            .foregroundColor(Color(hex: "#F18701"))
                        Text(item)
                        Text("Qty: \(qty)")

                    case let .inventoryNewPart(item, qty):
                        Text("Requested new part")
                            .bold()
                            .foregroundColor(Color(hex: "#F18701"))
                        Text(item)
                        Text("Qty: \(qty)")

                    case let .maintenanceReport(vehicle, issues, notes, date):
                        Text("Issue reported for \(vehicle)")
                            .bold()
                            .foregroundColor(.orange)
                        Text("Issues: \(issues.joined(separator: ", "))")
                        if !notes.isEmpty { Text("Notes: \(notes)") }
                        Text(date, style: .date)

                    case let .offRoute(vehicle, driver, _, _, _, _):
                        Text("Off-Route: \(vehicle)")
                            .bold()
                            .foregroundColor(.orange)
                        Text("Driver: \(driver)")
                    }
                }
                .font(.subheadline)
                .foregroundColor(Color(hex: "#396BAF"))

                Spacer()
            }
            .padding()
            .background(Color(red: 231/255, green: 237/255, blue: 248/255))
            .cornerRadius(12) // ✅ This now works
        }
    }


    private var iconName: String {
        switch self {
        case .tripResponse:       return "person.fill"
        case .billRaised:         return "doc.text.fill"
        case .maintenanceReview:  return "wrench.and.screwdriver.fill"
        case .tripCompleted:      return "checkmark.circle.fill"
        case .inventoryRestock,
             .inventoryNewPart:   return "drop.fill"
        case .maintenanceReport:  return "exclamationmark.triangle.fill"
        case .offRoute:           return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        switch self {
        case let .tripResponse(_, status, _, _, _):
            return status == .accepted ? .green : .red
        case .billRaised,
             .maintenanceReview,
             .inventoryRestock,
             .inventoryNewPart:
            return Color(hex: "#F18701")
        case .tripCompleted:      return .green
        case .maintenanceReport:  return .orange
        case .offRoute:           return .orange
        }
    }
}









// MARK: – Preview

struct NotificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotificationScreen()
        }
    }
}
