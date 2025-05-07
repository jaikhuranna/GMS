//
//  NotificationScreen.swift
//  Fleet_Notification
//
//  Created by user@89 on 07/05/25.
//

import SwiftUI

struct MaintenanceNotificationScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Requests Section
                SectionView2(title: "Requests", items: [
                    NotificationData(
                        statusMessage: "Fleet Manager has raised a request",
                        statusColor: .red,
                        task: "Tire Replace Task",
                        vehicle: "KN23CB4563"
                    ),
                    NotificationData(
                        statusMessage: "Ravi Kumar has raised a request",
                        statusColor: .red,
                        task: "Tire Replace Task",
                        vehicle: "KN23CB4563"
                    )
                ])

                // Post Maintenance Reviews Section
                SectionView2(title: "Post Maintenance Reviews", items: [
                    NotificationData(
                        statusMessage: "Your work has been approved.",
                        statusColor: .green,
                        task: "Tire Replace Task",
                        vehicle: "KN23CB4563"
                    ),
                    NotificationData(
                        statusMessage: "Need to do the work again.",
                        statusColor: .red,
                        task: "Tire Replace Task",
                        vehicle: "KN23CB4563"
                    )
                ])
            }
            .padding()
        }
        .navigationTitle("Notification Screen")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionView2: View {
    let title: String
    let items: [NotificationData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            ForEach(items.indices, id: \.self) { index in
                NotificationCard(data: items[index])
            }
        }
    }
}

struct NotificationData {
    let statusMessage: String
    let statusColor: Color
    let task: String
    let vehicle: String
}

struct NotificationCard: View {
    let data: NotificationData

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "car.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(data.statusMessage)
                    .foregroundColor(data.statusColor)
                    .fontWeight(.bold)

                Text(data.task)
                    .foregroundColor(Color(hex: "#396BAF"))

                Text(data.vehicle)
                    .foregroundColor(Color(hex: "#396BAF"))
            }
            .font(.subheadline)

            Spacer()
        }
        .padding()
        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        MaintenanceNotificationScreen()
    }
}

