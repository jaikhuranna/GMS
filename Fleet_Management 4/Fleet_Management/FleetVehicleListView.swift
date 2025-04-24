//
//  FleetVehicleListView.swift
//  FleetManagement
//
//  Created by user@89 on 22/04/25.
//

import SwiftUI

struct FleetVehicleListView: View {
    @State private var selectedSegment = "HMV"
    @State private var searchText = ""

    let segments = ["HMV", "LMV"]

    let hmvVehicles = [
        Vehicle(vehicleNo: "MH 02 AU 6546", distanceTravelled: 30000, carImage: "car"),
        Vehicle(vehicleNo: "KA 01 AB 1122", distanceTravelled: 40000, carImage: "car"),
        Vehicle(vehicleNo: "TN 10 BC 1234", distanceTravelled: 12000, carImage: "car"),
        Vehicle(vehicleNo: "DL 05 XY 7788", distanceTravelled: 8000, carImage: "car")
    ]

    let lmvVehicles = [
        Vehicle(vehicleNo: "TN 10 BC 1234", distanceTravelled: 12000, carImage: "car"),
        Vehicle(vehicleNo: "DL 05 XY 7788", distanceTravelled: 8000, carImage: "car"),
        Vehicle(vehicleNo: "MH 02 AU 6546", distanceTravelled: 30000, carImage: "car"),
        Vehicle(vehicleNo: "KA 01 AB 1122", distanceTravelled: 40000, carImage: "car")
    ]

    var filteredVehicles: [Vehicle] {
        let vehicles = selectedSegment == "HMV" ? hmvVehicles : lmvVehicles
        return searchText.isEmpty ? vehicles : vehicles.filter { $0.vehicleNo.lowercased().contains(searchText.lowercased()) }
    }

    @State private var navigateToAddFleet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                searchBar
                CustomSegmentedControl(selectedSegment: $selectedSegment, segments: segments)
                vehicleList
                
                NavigationLink(destination: AddDriverView(), isActive: $navigateToAddFleet) {
                    EmptyView()
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitle("Vehicles", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {navigateToAddFleet = true}) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.primary)
            })
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search vehicle", text: $searchText)
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    @State private var selectedVehicle: Vehicle?

    private var vehicleList: some View {
        ScrollView {
            VStack(spacing: 14) {
                if filteredVehicles.isEmpty {
                    Text("No vehicles found.")
                        .foregroundColor(.gray)
                        .padding(.top)
                } else {
                    ForEach(filteredVehicles) { vehicle in
                        Button {
                            selectedVehicle = vehicle
                        } label: {
                            vehicleRow(vehicle)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedVehicle) { vehicle in
            NavigationStack {
                VehicleDetailView()
                    .toolbar {
                        // Back button in top-left (navigationBarLeading)
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                selectedVehicle = nil
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                    }
            }
        }
    }
    private func vehicleRow(_ vehicle: Vehicle) -> some View {
        HStack(spacing: 16) {
                Image(vehicle.carImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(vehicle.vehicleNo)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#396BAF"))
                Text("Kms Travelled: \(vehicle.distanceTravelled)")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#396BAF"))
            }
            Spacer()
        }
        .padding()
        .background(Color(red: 237/255, green: 242/255, blue: 252/255))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct FleetVehicleListView_Previews: PreviewProvider {
    static var previews: some View {
        FleetVehicleListView()
    }
}
