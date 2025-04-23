//
//  FleetDriverListView.swift
//  FleetManagement
//
//  Created by user@89 on 22/04/25.
//

import SwiftUI

struct FleetDriverListView: View {
    @State private var selectedSegment = "HMV"
    @State private var searchText = ""

    let segments = ["HMV", "LMV"]

    let hmvDrivers = [
        Driver(driverName: "Angel Kenter", driverExperience: 4, driverImage: "driverImage"),
        Driver(driverName: "Vikram Reddy", driverExperience: 5, driverImage: "driverImage"),
        Driver(driverName: "Sonia Dsouza", driverExperience: 3, driverImage: "driverImage")
    ]

    let lmvDrivers = [
        Driver(driverName: "Raj Mehra", driverExperience: 6, driverImage: "driverImage"),
        Driver(driverName: "Sonia Dsouza", driverExperience: 3, driverImage: "driverImage"),
        Driver(driverName: "Angel Kenter", driverExperience: 4, driverImage: "driverImage")
    ]

    var filteredDrivers: [Driver] {
        let drivers = selectedSegment == "HMV" ? hmvDrivers : lmvDrivers
        return searchText.isEmpty ? drivers : drivers.filter { $0.driverName.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                searchBar
                CustomSegmentedControl(selectedSegment: $selectedSegment, segments: segments)
                driverList
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitle("Drivers", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.primary)
            })
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search driver", text: $searchText)
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    private var driverList: some View {
        ScrollView {
            VStack(spacing: 14) {
                if filteredDrivers.isEmpty {
                    Text("No drivers found.")
                        .foregroundColor(.gray)
                        .padding(.top)
                } else {
                    ForEach(filteredDrivers) { driver in
                        driverRow(driver)
                    }
                }
            }
        }
    }

    private func driverRow(_ driver: Driver) -> some View {
        HStack(spacing: 16) {
                Image(driver.driverImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(driver.driverName)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#396BAF"))
                Text("Experience: \(driver.driverExperience) Years")
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
                        .background(selectedSegment == segment ? Color.white : Color(hex: "396BAF"))
                        .foregroundColor(selectedSegment == segment ? Color(hex: "396BAF") : .white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(4)
        .background(Color(hex: "396BAF"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct FleetDriverListView_Previews: PreviewProvider {
    static var previews: some View {
        FleetDriverListView()
    }
}
