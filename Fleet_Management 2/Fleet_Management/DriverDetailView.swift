//
//  DriverDetailView.swift
//  Fleet_Management
//
//  Created by user@89 on 23/04/25.
//

import SwiftUI

// MARK: - Main View
struct DriverDetailView: View {
    let driver: Driver
    let driverName = "Alex Johnson"

    let driverDetails = Driver(driverName: "Alex Johnson", driverExperience: 5, driverImage: "person1")

    let pastTrips = [
        PastTrip(driverName: "Alex Johnson", vehicleNo: "KA05AK0432", tripDetail: "Bangalore to Mysore", driverImage: "person1", date: "10 April 2024"),
        PastTrip(driverName: "Alex Johnson", vehicleNo: "KA05AK0432", tripDetail: "Chennai to Coimbatore", driverImage: "person1", date: "6 April 2024"),
        PastTrip(driverName: "Alex Johnson", vehicleNo: "KA05AK0432", tripDetail: "Hyderabad to Vizag", driverImage: "person1", date: "1 April 2024")
    ]

    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            ZStack(alignment: .top) {
                Color(red: 231/255, green: 237/255, blue: 248/255)
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 220)

                VStack(spacing: 24) {
                    Image(driverDetails.driverImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .padding(.top, 20)

                    Text(driverDetails.driverName)
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)

                    // Segmented Control
                    HStack {
                        Button(action: { selectedTab = 0 }) {
                            Text("Profile")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(selectedTab == 0 ? Color.white : Color(hex: "396BAF"))
                                .foregroundColor(selectedTab == 0 ? Color(hex: "396BAF") : .white)
                                .cornerRadius(8)
                        }

                        Button(action: { selectedTab = 1 }) {
                            Text("Past Trips")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(selectedTab == 1 ? Color.white : Color(hex: "396BAF"))
                                .foregroundColor(selectedTab == 1 ? Color(hex: "396BAF") : .white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(4)
                    .background(Color(hex: "396BAF"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }

            // MARK: - Content Area
            ScrollView {
                VStack(spacing: 16) {
                    if selectedTab == 0 {
                        // Profile Tab
                        VStack(spacing: 12) {
                            InfoRow(title: "Name", value: driverDetails.driverName)
                            InfoRow(title: "Experience", value: "\(driverDetails.driverExperience) years")
                        }
                        .padding(.vertical, 16)
                        .background(Color(hex: "396BAF").opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    } else if selectedTab == 1 {
                        // Past Trips Tab
                        ForEach(pastTrips) { trip in
                            HStack(spacing: 16) {
                                Image(trip.driverImage)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Vehicle: \(trip.vehicleNo)")
                                        .font(.headline)
                                        .foregroundColor(Color(hex: "396BAF"))

                                    Text("Trip: \(trip.tripDetail)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Text("Date: \(trip.date)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color(hex: "396BAF").opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 60)

            // MARK: - Button
            Button(action: {
                // Assign new trip
            }) {
                Text("Assign New Trip")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "396BAF"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color(red: 231/255, green: 237/255, blue: 248/255).ignoresSafeArea())
    }
}

//// MARK: - Preview
//struct DriverDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DriverDetailView(driver: driver)
//    }
//}
