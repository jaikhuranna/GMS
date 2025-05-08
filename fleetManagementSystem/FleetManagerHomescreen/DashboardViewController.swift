//
//  DashboardViewController.swift
//  Fleet_Management
//
//  Created by admin81 on 22/04/25.
//
//import SwiftUI
//import SwiftUI
//import Firebase
//import FirebaseFirestore
//import Combine
//
//
//
//struct DashboardView: View {
//    @StateObject private var dashboard = DashboardService()
//    
//    var body: some View {
//        
//        VStack(spacing: 22) {
//            // MARK: – Header
//            ZStack(alignment: .top) {
//                RoundedRectangle(cornerRadius: 30, style: .circular)
//                    .fill(Color(red: 231/255, green: 237/255, blue: 248/255))
//                    .edgesIgnoringSafeArea(.top)
//                
//                HStack {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Welcome,")
//                            .font(.title3)
//                            .foregroundColor(.black)
//                        Text("Manager")
//                            .font(.title2)
//                            .bold()
//                            .foregroundColor(.black)
//                    }
//                    Spacer()
//                    HStack(spacing: 20) {
//                        NavigationLink(destination: PendingBillsView()) {
//                            Image(systemName: "bell.fill")
//                        }
//
//                        Image(systemName: "person.crop.circle").font(.system(size: 26))
//                    }
//                    .foregroundColor(.black)
//                }
//                .padding(.horizontal)
//                .padding(.top, 20)
//            }
//            .frame(height: 100)
//            .zIndex(1)
//            
//            // MARK: – Cards + Trips List
//            ScrollView {
//                // 1) Info cards grid
//                VStack(alignment: .leading , spacing: 10){
//                    LazyVGrid(columns: [ GridItem(.flexible()), GridItem(.flexible()) ], spacing: 10) {
//                        InfoCardView(card: InfoCard(
//                            number: "\(dashboard.runningTripsCount)",
//                            title: "Running Trips",
//                            icon: "person.line.dotted.person"
//                        ))
//                        InfoCardView(card: InfoCard(
//                            number: "\(dashboard.carsInMaintenanceCount)",
//                            title: "Cars In Maintenance",
//                            icon: "car.side.front.open"
//                        ))
//                        InfoCardView(card: InfoCard(
//                            number: "\(dashboard.idleVehiclesCount)",
//                            title: "Idle Vehicles",
//                            icon: "car.2"
//                        ))
//                        InfoCardView(card: InfoCard(
//                            number: "\(dashboard.idleDriversCount)",
//                            title: "Idle Drivers",
//                            icon: "person.3"
//                        ))
//                    }
//                    .padding(.horizontal)
//                    
//                    // 2) Ongoing trips header
//                    Text("On Going Trips")
//                        .font(.title3).bold()
//                        .padding(.horizontal)
//                    
//                    // 3) Ongoing trips rows
//                    VStack(spacing: 12) {
//                        ForEach(dashboard.ongoingTrips) { trip in
//                            TripRowView(trip: trip)
//                                .padding(.horizontal)
//                        }
//                    }
//                    .padding(.bottom, 20)
//                }
//            }
//            .onAppear {
//                dashboard.fetchAll()
//            }
//        }
//    }
//}
//// MARK: - Preview
//struct DashBoardView: PreviewProvider {
//    static var previews: some View {
//        DashboardView()
//    }
//}


import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

struct DashboardView: View {
    @StateObject private var dashboard = DashboardService()
    
    var body: some View {
        VStack(spacing: 22) {
            // MARK: – Header
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 30, style: .circular)
                    .fill(Color(red: 231/255, green: 237/255, blue: 248/255))
                    .edgesIgnoringSafeArea(.top)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome,")
                            .font(.title3)
                            .foregroundColor(.black)
                        Text("Manager")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)
                    }
                    Spacer()
                    HStack(spacing: 20) {
//                        NavigationLink(destination: PendingBillsView()) {
//                            Image(systemName: "bell.fill")
//                        }
                        
                        NavigationLink(destination: ManagerProfileView(viewModel: AuthViewModel())) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 26))
                        }
                    }
                    .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .frame(height: 100)
            .zIndex(1)
            
            // MARK: – Cards + Trips List
            ScrollView {
                // 1) Info cards grid
                VStack(alignment: .leading, spacing: 10) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        InfoCardView(card: InfoCard(
                            number: "\(dashboard.runningTripsCount)",
                            title: "Running Trips",
                            icon: "person.line.dotted.person"
                        ))
                        InfoCardView(card: InfoCard(
                            number: "\(dashboard.carsInMaintenanceCount)",
                            title: "Cars In Maintenance",
                            icon: "car.side.front.open"
                        ))
                        InfoCardView(card: InfoCard(
                            number: "\(dashboard.idleVehiclesCount)",
                            title: "Idle Vehicles",
                            icon: "car.2"
                        ))
                        InfoCardView(card: InfoCard(
                            number: "\(dashboard.idleDriversCount)",
                            title: "Idle Drivers",
                            icon: "person.3"
                        ))
                    }
                    .padding(.horizontal)
                    
                    // 2) Ongoing trips header
                    Text("On Going Trips")
                        .font(.title3).bold()
                        .padding(.horizontal)
                    
                    // 3) Ongoing trips rows
                    VStack(spacing: 12) {
                        ForEach(dashboard.ongoingTrips) { trip in
                            TripRowView(trip: trip)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                dashboard.fetchAll()
            }
        }
    }
}

// MARK: - Preview
struct DashBoardView: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
