//
//  ContentView.swift
//  FleetManagement
//
//  Created by user@89 on 22/04/25.
//

import SwiftUI

struct DriverView: View {
    var body: some View {
        TabView {
            // Home - Placeholder
            Text("Home")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            // Fleet - Vehicle List
            FleetVehicleListView()
                .tabItem {
                    Image(systemName: "truck.box.fill")
                    Text("Fleet")
                }

            // Driver - Driver List
            FleetDriverListView()
                .tabItem {
                    Image(systemName: "person.badge.plus")
                    Text("Driver")
                }

            // Maintenance - Placeholder
            Text("Maintenance")
                .tabItem {
                    Image(systemName: "car.badge.gearshape.fill")
                    Text("Maintenance")
                }

            // Schedule - Placeholder
            Text("Schedule")
                .tabItem {
                    Image(systemName: "calendar.badge.plus")
                    Text("Schedule")
                }
        }
        .accentColor(Color.blue) // Tab icon tint color
    }
}

#Preview {
    DriverView()
}
