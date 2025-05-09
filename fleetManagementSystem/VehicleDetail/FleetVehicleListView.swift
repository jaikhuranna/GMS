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
    @State private var allVehicles: [Vehicle] = []
    @State private var selectedVehicle: Vehicle?
    @State private var showAddVehicle = false
    @State private var navigateToAddFleet = false


    let segments = ["HMV", "LMV"]

//    let hmvVehicles = [
//        Vehicle(vehicleNo: "MH 02 AU 6546", distanceTravelled: 30000, carImage: "car"),
//        Vehicle(vehicleNo: "KA 01 AB 1122", distanceTravelled: 40000, carImage: "car"),
//        Vehicle(vehicleNo: "TN 10 BC 1234", distanceTravelled: 12000, carImage: "car"),
//        Vehicle(vehicleNo: "DL 05 XY 7788", distanceTravelled: 8000, carImage: "car")
//    ]
//
//    let lmvVehicles = [
//        Vehicle(vehicleNo: "TN 10 BC 1234", distanceTravelled: 12000, carImage: "car"),
//        Vehicle(vehicleNo: "DL 05 XY 7788", distanceTravelled: 8000, carImage: "car"),
//        Vehicle(vehicleNo: "MH 02 AU 6546", distanceTravelled: 30000, carImage: "car"),
//        Vehicle(vehicleNo: "KA 01 AB 1122", distanceTravelled: 40000, carImage: "car")
//    ]

    
    struct CustomSegmentedControl: View {
        @Binding var selectedSegment: String
        let segments: [String]
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(segments, id: \.self) { segment in
                    Button(action: {
                        selectedSegment = segment
                    }) {
                        Text(segment)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(selectedSegment == segment ? Color(.systemBackground) : Color.accentColor)
                            .foregroundColor(selectedSegment == segment ? Color.accentColor : .white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(Color.accentColor)
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    
    
    var filteredVehicles: [Vehicle] {
           allVehicles.filter { vehicle in
               vehicle.vehicleCategory == selectedSegment &&
               (searchText.isEmpty || vehicle.vehicleNo.lowercased().contains(searchText.lowercased()))
           }
       }
    
    var body: some View {
          NavigationView {
              VStack(spacing: 4) {
                  searchBar
                  CustomSegmentedControl(selectedSegment: $selectedSegment, segments: segments)
                  vehicleList
                  
                  NavigationLink(destination: AddFleetVehicleView(), isActive: $navigateToAddFleet) {
                      EmptyView()
                  }
              }
              
              
              
              .background(Color.white.ignoresSafeArea())
              .navigationBarItems(trailing: Button(action: {
                  navigateToAddFleet = true
              }) {
                  Image(systemName: "plus.circle.fill")
                      .foregroundColor(.primary)
                      .font(.system(size: 24))
              })
              .onAppear {
                  FirebaseModules.shared.fetchAllVehicles { vehicles in
                      self.allVehicles = vehicles
                  }
              }
          }
      }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search Ideal Vehicle", text: $searchText)
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    private var vehicleList: some View {
        ScrollView {
            VStack(spacing: 6) {
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
                // Pass the selected vehicle to VehicleDetailView
                                VehicleDetailView(vehicle: vehicle)
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
        HStack(spacing: 8) {
                Image("tt")
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
