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
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            TaskView()
                .tabItem {
                    Label("Tasks", systemImage: "slider.horizontal.3")
                }
            
            InventoryView()
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
