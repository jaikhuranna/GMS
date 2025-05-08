import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import CoreLocation
import MapKit

struct DashboardView: View {
    @StateObject private var dashboard = DashboardService()
    @StateObject private var notifVM   = NotificationViewModel()
    @ObservedObject var viewModel: AuthViewModel
    
    @State private var currentOffRoute: NotificationItem?
    @State private var selectedOffRoute: NotificationItem?
    @State private var showingOffRouteMap = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                header

                ScrollView {
                    statsGrid
                    ongoingSection
                }
                .onAppear {
                    dashboard.fetchAll()
                    notifVM.fetchAllNotifications()
                }
                .onReceive(notifVM.$offRouteAlerts) { alerts in
                    currentOffRoute = alerts.first
                }
            }
            
                    .alert(item: $currentOffRoute) { alert in
                        // now binding all six slots (use underscores for the ones you don’t care about)
                        guard case let .offRoute(vehicle, driverId, _, _, _, _) = alert else {
                            return Alert(title: Text("Alert"),
                                         message: Text("Unknown alert type"),
                                         dismissButton: .default(Text("OK")))
                        }
                        return Alert(
                            title: Text("Vehicle Off-Route"),
                            message: Text("Vehicle \(vehicle) driven by \(driverId) has left the assigned route."),
                            primaryButton: .default(Text("View on Map")) {
                                selectedOffRoute = alert
                                showingOffRouteMap = true
                            },
                            secondaryButton: .cancel()
                        )
                    }
            
            .fullScreenCover(isPresented: $showingOffRouteMap) {
                // full-screen modal map
                if let off = selectedOffRoute {
                    OffRouteMapView(alert: off)
                } else {
                    Text("No location available")
                        .font(.headline)
                        .padding()
                }
            }
        }
    }

    // MARK: – Header
    private var header: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(hex: "#396BAF"))
                .ignoresSafeArea()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome,").font(.title3)
                        .foregroundColor(.white)
                    Text("Manager").font(.title2).bold()
                        .foregroundColor(.white)
                }
                Spacer()
                HStack(spacing: 20) {
                    NavigationLink(destination: NotificationScreen()) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 24))
                    }
                    Menu {
                        Button(role: .destructive, action: {
                            Task {
                                await viewModel.logout()
                            }
                        }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.black)
                                .font(.system(size: 24))
                        }

                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .frame(height: 100)
        .zIndex(1)
    }

    // MARK: – Stats Grid
    private var statsGrid: some View {
        LazyVGrid(
            columns: [ GridItem(.flexible()), GridItem(.flexible()) ],
            spacing: 10
        ) {
            InfoCardView(card: .init(
                number: "\(dashboard.runningTripsCount)",
                title: "Running Trips",
                icon: "person.line.dotted.person"
            ))
            InfoCardView(card: .init(
                number: "\(dashboard.carsInMaintenanceCount)",
                title: "Cars In Maintenance",
                icon: "car.side.front.open"
            ))
            InfoCardView(card: .init(
                number: "\(dashboard.idleVehiclesCount)",
                title: "Idle Vehicles",
                icon: "car.2"
            ))
            InfoCardView(card: .init(
                number: "\(dashboard.idleDriversCount)",
                title: "Idle Drivers",
                icon: "person.3"
            ))
        }
        .padding(.horizontal)
    }

    // MARK: – Ongoing Trips Section
    private var ongoingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("On Going Trips")
                .font(.title3).bold()
                .padding(.horizontal)

            ForEach(dashboard.ongoingTrips) { trip in
                TripRowView(trip: trip)
                    .padding(.horizontal)
            }
            .padding(.bottom, 2)
        }
    }
}
//
//struct DashboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        DashboardView(viewModel: AuthViewModel)
//    }
//}

// MARK: – Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // Initialize with a mock or default AuthViewModel for preview
        DashboardView(viewModel: AuthViewModel())
    }
}
