//
//  TripRowView.swift
//  Fleet_Management
//
//  Created by admin81 on 22/04/25.
//

import SwiftUI

struct TripRowView: View {
    var trip: Trip

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .foregroundColor(Color(hex: "#396BAF"))

            VStack(alignment: .leading, spacing: 6) {
                Text("Driver : \(trip.driverName)")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(Color(hex: "#396BAF"))

                Text("Vehicle No : \(trip.vehicleNo)")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#396BAF"))

                Text("Trip : \(trip.tripDetail)")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#396BAF"))
            }
            Spacer()
        }
        .padding()
        .background(Color(red: 237/255, green: 242/255, blue: 252/255))
        .cornerRadius(16)
    }
}
