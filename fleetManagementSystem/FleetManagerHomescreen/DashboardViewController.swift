//
// DashboardViewController.swift
// Fleet_Management
//
// Created by admin81 on 22/04/25.
//

import SwiftUI

struct DashboardView: View {
    // Add viewModel parameter
    @ObservedObject var viewModel: AuthViewModel
    @State private var selectedTab: Int = 0
    
    // Get username from email for display
    var username: String {
        return viewModel.email.components(separatedBy: "@").first ?? "Manager"
    }
    
    let infoCards = [
        InfoCard(number: "5", title: "Running Trips", icon: "person.line.dotted.person"),
        InfoCard(number: "5", title: "Cars In Maintenance", icon: "car.side.front.open"),
        InfoCard(number: "5", title: "Ideal Vehicles", icon: "car.2"),
        InfoCard(number: "5", title: "Ideal Drivers", icon: "person.3")
    ]
    
    let trips = [
        Trip(driverName: "John Doe", vehicleNo: "WB12 4567", tripDetail: "Kolkata to Delhi", driverImage: "person1"),
        Trip(driverName: "Jane Smith", vehicleNo: "MH04 2231", tripDetail: "Mumbai to Pune", driverImage: "person2"),
        Trip(driverName: "Trishita Yadav", vehicleNo: "MH04 2231", tripDetail: "Mysore to Chennai", driverImage: "person2")
    ]
    
    var body: some View {
        VStack(spacing: 22) {
            // Header
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 30, style: .circular)
                    .fill(Color(red: 231/255, green: 237/255, blue: 248/255))
                    .edgesIgnoringSafeArea(.top)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome,")
                            .font(.title3)
                            .foregroundColor(.black)
                        Text(username) // Use username variable instead of hardcoded "Manager"
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)
                    }
                    Spacer()
                    HStack(spacing: 20) {
                        Image(systemName: "bell.fill").font(.system(size: 26))
                        // Add logout functionality
                        Menu {
                            Button(action: {
                                viewModel.logout()
                            }) {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            Image(systemName: "person.crop.circle").font(.system(size: 26))
                        }
                    }
                    .font(.title3)
                    .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .frame(height: 100)
            .zIndex(1)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(infoCards) { card in
                            InfoCardView(card: card)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("On Going Trips")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(Color.primary)
                    VStack(spacing: 12) {
                        ForEach(trips) { trip in
                            TripRowView(trip: trip)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            
            // Display User ID at bottom for debugging
            Text("User ID: \(viewModel.firebaseUid)")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.bottom, 4)
        }
    }
}
