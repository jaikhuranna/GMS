//
//  DriverDetailView.swift
//  Fleet_Management
//
//  Created by user@89 on 23/04/25.
//

import SwiftUI

struct DriverDetailView: View {
    let driver: Driver
    @State private var pastTrips: [PastTrip] = []
    @State private var selectedTab = 0
    @State private var isLoading = true
    @State private var driverImages: [String: String] = [:] // Mapping driverId -> driverImage URL

    var body: some View {
        VStack(spacing: 0) {
            driverHeader

            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else {
                        if selectedTab == 0 {
                            profileInfo
                        } else if selectedTab == 1 {
                            pastTripsView
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 60)

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
        .onAppear {
            fetchPastTrips()
            fetchDriverImages()
        }
    }

    private var driverHeader: some View {
        ZStack(alignment: .top) {
            Color(red: 231/255, green: 237/255, blue: 248/255)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 220)

            VStack(spacing: 24) {
                AsyncImage(url: URL(string: driver.driverImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 2)
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    @unknown default:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                }
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 100, height: 100)
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .padding(.top, 20)

                Text(driver.driverName)
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)

                segmentControl
            }
        }
    }

    private var segmentControl: some View {
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

    private var profileInfo: some View {
        VStack(spacing: 12) {
            InfoRow(title: "Name", value: driver.driverName)
            InfoRow(title: "Experience", value: "\(driver.driverExperience) years")
            InfoRow(title: "Age", value: "\(driver.driverAge)")
            InfoRow(title: "Contact", value: driver.driverContactNo)
            InfoRow(title: "License No", value: driver.driverLicenseNo)
            InfoRow(title: "License Type", value: driver.driverLicenseType)
        }
        .padding(.vertical, 16)
        .background(Color(hex: "396BAF").opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var pastTripsView: some View {
        VStack(spacing: 16) {
            if pastTrips.isEmpty {
                Text("No past trips found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(pastTrips) { trip in
                    HStack(spacing: 16) {
                        if let imageUrl = driverImages[trip.driverId], let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .foregroundColor(.gray)
                                case .empty:
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Trip: \(trip.tripDetail)")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text("Date: \(trip.date.formatted(date: .abbreviated, time: .omitted))")
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

    private func fetchPastTrips() {
        isLoading = true
        FirebaseModules.shared.fetchPastTrips(forDriverId: driver.id) { trips in
            self.pastTrips = trips
            self.isLoading = false
        }
    }

    private func fetchDriverImages() {
        FirebaseModules.shared.fetchDrivers { drivers in
            var mapping: [String: String] = [:]
            for driver in drivers {
                mapping[driver.id] = driver.driverImage
            }
            DispatchQueue.main.async {
                self.driverImages = mapping
            }
        }
    }
}
