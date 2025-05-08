//
//  MainTab.swift
//  Fleet_Inventory_Screen
//
//  Created by admin81 on 30/04/25.
//

import SwiftUI

struct MaintenanceTabView: View {
    var body: some View {
        TabView {
            // Home Tab with Navigation Stack
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            // Tasks Tab with Navigation Stack
            NavigationStack {
                TaskView()
            }
            .tabItem {
                Label("Tasks", systemImage: "slider.horizontal.3")
            }
            
            // Inventory Tab with Navigation Stack
            NavigationStack {
                InventoryView()
            }
            .tabItem {
                Label("Inventory", systemImage: "drop")
            }
        }
    }
}

struct MaintenanceTabView_Previews: PreviewProvider {
    static var previews: some View {
        MaintenanceTabView()
            .background(Color.white)
            .previewDevice("iPhone 14 Pro")
    }
}
