//
//  NotificationScreen.swift
//  Fleet_Notification
//
//  Created by user@89 on 07/05/25.
//

import SwiftUI

struct NotificationScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                NotificationSection(title: "Trips Acceptance", items: [
                    .tripResponse(name: "Ravi Kumar", status: .accepted, vehicle: "KN23CB6463", route: "Mysore - Bangalore", date: "24/05/26 - 27/05/26"),
                    .tripResponse(name: "Ravi Kumar", status: .rejected, vehicle: "KN23CB6463", route: "Mysore - Bangalore", date: "24/05/26 - 27/05/26")
                ])

                NotificationSection(title: "Bill Approvals", items: [
                    .billRaised(task: "Tire Replace Task", vehicle: "KN23CB6463"),
                    .billRaised(task: "Tire Replace Task", vehicle: "KN23CB6463")
                ])

                NotificationSection(title: "Post Maintenance Reviews", items: [
                    .maintenanceReview(task: "Tire Replace Task", vehicle: "KN23CB6463"),
                    .maintenanceReview(task: "Tire Replace Task", vehicle: "KN23CB6463")
                ])

                NotificationSection(title: "Completed Trips", items: [
                    .tripCompleted(name: "Ravi Kumar", vehicle: "KN23CB6463", route: "Mysore - Bangalore", date: "24/05/26 - 27/05/26"),
                    .tripCompleted(name: "Ravi Kumar", vehicle: "KN23CB6463", route: "Mysore - Bangalore", date: "24/05/26 - 27/05/26")
                ])

                NotificationSection(title: "Inventory", items: [
                    .inventoryRestock(item: "Steering Wheel", quantity: 4),
                    .inventoryNewPart(item: "Wheel 10AB", quantity: 4)
                ])
            }
            .padding()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Notification Section

struct NotificationSection: View {
    let title: String
    let items: [NotificationItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .padding(.bottom, 4)

            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                
                switch item {
                case .billRaised:
                    NavigationLink(destination: BillApprovalView()) {
                        item.notificationView()
                    }
                case .maintenanceReview:
                    NavigationLink(destination: PostMaintenanceReviewView()) {
                        item.notificationView()
                    }
                case .inventoryRestock, .inventoryNewPart:
                    NavigationLink(destination: InventoryRequestNotification()) {
                        item.notificationView()
                    }
                default:
                    item.notificationView()
                }
            }
        }
    }
}

// MARK: - Notification Item Enum

enum NotificationItem {
    case tripResponse(name: String, status: TripStatus, vehicle: String, route: String, date: String)
    case billRaised(task: String, vehicle: String)
    case maintenanceReview(task: String, vehicle: String)
    case tripCompleted(name: String, vehicle: String, route: String, date: String)
    case inventoryRestock(item: String, quantity: Int)
    case inventoryNewPart(item: String, quantity: Int)

    enum TripStatus {
        case accepted, rejected
    }

    @ViewBuilder
    func notificationView() -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(iconColor)

            VStack(alignment: .leading, spacing: 4) {
                switch self {
                case let .tripResponse(name, status, vehicle, route, date):
                    Text("\(name) has \(status == .accepted ? "accepted" : "rejected") the trip")
                        .foregroundColor(status == .accepted ? .green : .red)
                        .bold()
                    Text("\(route), \(vehicle)")
                    Text(date)

                case let .billRaised(task, vehicle):
                    Text("Maintenance Manager has raised a request")
                        .foregroundColor(Color(hex: "#F18701"))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                    Text(task)
                    Text(vehicle)

                case let .maintenanceReview(task, vehicle):
                    Text("Maintenance Manager has raised a request")
                        .foregroundColor(Color(hex: "#F18701"))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                    Text(task)
                    Text(vehicle)


                case let .tripCompleted(name, vehicle, route, date):
                    Text("\(name) has completed the trip.")
                        .foregroundColor(.green)
                        .bold()
                    Text("\(route), \(vehicle)")
                    Text(date)

                case let .inventoryRestock(item, quantity):
                    Text("Maintenance has requested for restocking")
                        .foregroundColor(Color(hex: "#F18701"))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                    Text(item)
                    Text("Quantity: \(quantity)")

                case let .inventoryNewPart(item, quantity):
                    Text("Maintenance has requested a new part")
                        .foregroundColor(Color(hex: "#F18701"))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                    Text(item)
                    Text("Quantity: \(quantity)")
                }
            }
            .font(.subheadline)
            .foregroundColor(Color(hex: "#396BAF"))

            Spacer()
        }
        .padding()
        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
        .cornerRadius(12)
    }

    private var iconName: String {
        switch self {
        case .tripResponse: return "person.fill"
        case .billRaised: return "doc.text.fill"
        case .maintenanceReview: return "wrench.and.screwdriver.fill"
        case .tripCompleted: return "checkmark.circle.fill"
        case .inventoryRestock, .inventoryNewPart: return "drop.fill"
        }
    }

    private var iconColor: Color {
        switch self {
        case .tripResponse(_, let status, _, _, _):
            return status == .accepted ? .green : .red
        case .billRaised: return Color(hex: "#F18701")
        case .maintenanceReview: return Color(hex: "#F18701")
        case .tripCompleted: return .green
        case .inventoryRestock, .inventoryNewPart: return .red
        }
    }
}

// MARK: - Preview

struct NotificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotificationScreen()
        }
    }
}

