import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
            }
            .tag(0)
            
            // Tab 2: Fleet
            FleetVehicleListView() // Your fleet management view
                .tabItem {
                    Label("Fleet", systemImage: selectedTab == 1 ? "box.truck.badge.clock.fill" : "box.truck.badge.clock")
                }
                .tag(1)
            
            // Tab 3: Driver
            FleetDriverListView()
            
                .tabItem {
                    Label("Driver", systemImage: selectedTab == 2 ? "person.crop.circle.fill.badge.plus" : "person.crop.circle.badge.plus")
                }
                .tag(2)
            
            //            // Tab 4: Maintenance
            //            NavigationStack {
            //                MaintenanceView() // Your maintenance view
            //            }
            //            .tabItem {
            //                Label("Maintenance", systemImage: selectedTab == 3 ? "car.badge.gearshape.fill" : "car.badge.gearshape")
            //            }
            //            .tag(3)
            //
            //            // Tab 5: Schedule
            //            NavigationStack {
            //                ScheduleView() // Your schedule view
            //            }
            //            .tabItem {
            //                Label("Schedule", systemImage: selectedTab == 4 ? "calendar.badge.plus" : "calendar")
            //            }
            //            .tag(4)
            //        }
                .accentColor(Color(hex: "396BAF"))
                .onAppear {
                    // Set translucent tab bar appearance
                    let appearance = UITabBarAppearance()
                    appearance.configureWithDefaultBackground()
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
        }
    }
}
// MARK: - Supporting Views

// Placeholder for FleetView (replace with your actual implementation)
struct FleetView: View {
    var body: some View {
        Text("Fleet Management View")
            .navigationTitle("Fleet")
    }
}

// Placeholder for MaintenanceView (replace with your actual implementation)
//struct MaintenanceView: View {
//    var body: some View {
//        Text("Maintenance View")
//            .navigationTitle("Maintenance")
//    }
//}
//
//// Placeholder for ScheduleView (replace with your actual implementation)
//struct ScheduleView: View {
//    var body: some View {
//        Text("Schedule View")
//            .navigationTitle("Schedule")
//    }
//}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
