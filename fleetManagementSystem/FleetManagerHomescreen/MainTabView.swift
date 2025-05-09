import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            NavigationStack {
                DashboardView(viewModel: viewModel)
            }
            .tabItem {
                Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
            }
            .tag(0)

            // Tab 2: Fleet
            FleetVehicleListView()
                .tabItem {
                    Label("Fleet", systemImage: selectedTab == 1 ? "box.truck.fill" : "box.truck")
                }
                .tag(1)

            // Tab 3: Driver
            FleetDriverListView()
                .tabItem {
                    Label("Driver", systemImage: selectedTab == 2 ? "person.crop.circle.fill.badge.plus" : "person.crop.circle.badge.plus")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "396BAF"))
        .onAppear {
            // Set translucent tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("SwitchToHomeTab"))) { _ in
            selectedTab = 0
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(viewModel: AuthViewModel())
    }
}
