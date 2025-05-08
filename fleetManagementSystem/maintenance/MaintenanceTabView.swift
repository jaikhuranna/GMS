//
//  MainTab.swift
//  Fleet_Inventory_Screen
//
//  Created by admin81 on 30/04/25.
//

import SwiftUI

struct MaintenanceTabView: View {
    // Use a reference to the AuthViewModel passed from parent
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // Home Tab - Pass the viewModel to HomeView
            NavigationStack{
                HomeView(viewModel: viewModel)
            }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Add other tabs as needed
            
            NavigationStack{
                TaskView()
            }
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            
            NavigationStack{
                InventoryView()
            }
                .tabItem {
                    Label("Inventory", systemImage: "shippingbox.fill")
                }
            
            
        }
    }
}

struct MaintenanceTabView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = AuthViewModel()
        MaintenanceTabView(viewModel: mockViewModel)
    }
}

