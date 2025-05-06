
import SwiftUI
import Firebase
import FirebaseFirestore

// MARK: – InfoRow Helper
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 150, alignment: .leading)
            Text(value)
                .bold()
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: – VehicleDetailView Main
struct VehicleDetailView: View {
    let vehicle: Vehicle

    @State private var selectedTab = 0
    @State private var pastTrips: [PastTrip] = []
    @State private var pastMaintenances: [PastMaintenance] = []
    @State private var showScheduler = false

    @State private var selectedTrip: PastTrip? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == 0 {
                            profileView
                        } else if selectedTab == 1 {
                            pastTripsView
                        } else {
                            maintenanceView
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 60)
                }

                Button {
                    showScheduler = true
                } label: {
                    Text("Schedule A Trip")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "396BAF"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                NavigationLink(
                    destination: ScheduleTripView(vehicle: vehicle),
                    isActive: $showScheduler,
                    label: { EmptyView() }
                )
                .hidden()
            }
            .navigationTitle(vehicle.vehicleNo)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 231/255, green: 237/255, blue: 248/255).ignoresSafeArea())
            .onAppear {
                FirebaseModules.fetchPastTrips(for: vehicle.vehicleNo) { self.pastTrips = $0 }
                FirebaseModules.fetchPastMaintenances(for: vehicle.vehicleNo) { self.pastMaintenances = $0 }
            }
            .sheet(item: $selectedTrip) { trip in
                TripDetailBottomSheetView(trip: trip)
                    .presentationDetents([.fraction(0.55), .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: – Subviews

    private var headerView: some View {
        ZStack(alignment: .top) {
            Color(red: 231/255, green: 237/255, blue: 248/255)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 220)

            VStack(spacing: 24) {
                Image("truck")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.top, 20)

                Text(vehicle.vehicleNo)
                    .font(.title).bold()

                HStack {
                    Button("Profile") { selectedTab = 0 }
                        .tabStyle(isSelected: selectedTab == 0)
                    Button("Past Trips") { selectedTab = 1 }
                        .tabStyle(isSelected: selectedTab == 1)
                    Button("Maintenance") { selectedTab = 2 }
                        .tabStyle(isSelected: selectedTab == 2)
                }
                .padding(4)
                .background(Color(hex: "396BAF"))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }

    private var profileView: some View {
        VStack(spacing: 12) {
            InfoRow(title: "Vehicle Number", value: vehicle.vehicleNo)
            InfoRow(title: "Model Name", value: vehicle.modelName)
            InfoRow(title: "Engine Number", value: vehicle.engineNo)
            InfoRow(title: "Vehicle Type", value: vehicle.vehicleType)
            InfoRow(title: "Vehicle Category", value: vehicle.vehicleCategory)
            InfoRow(title: "License Renewal", value: formatDateString(vehicle.licenseRenewalDate))
            InfoRow(title: "Distance Travelled", value: "\(vehicle.distanceTravelled) Kms")
            InfoRow(title: "Average Mileage", value: "\(vehicle.averageMileage) Km/L")
        }
        .padding(.vertical, 16)
        .background(Color(hex: "396BAF").opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var pastTripsView: some View {
        VStack(spacing: 12) {
            ForEach(pastTrips) { trip in
                Button {
                    selectedTrip = trip
                } label: {
                    HStack(spacing: 16) {
                        Image("driver_placeholder")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Driver: \(trip.driverName)")
                                .font(.headline)
                                .foregroundColor(Color(hex: "396BAF"))
                            Text("Trip: \(trip.tripDetail)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Date: \(formatDateString(trip.date))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "396BAF").opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
    }

    private var maintenanceView: some View {
        VStack(spacing: 12) {
            ForEach(pastMaintenances) { m in
                VStack(alignment: .leading, spacing: 6) {
                    Text("Note: \(m.note)")
                        .font(.headline)
                        .foregroundColor(.red)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Observer Name: \(m.observerName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Date of Maintenance: \(m.dateOfMaintenance)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading) // Fixed height for uniformity
                .background(Color(hex: "396BAF").opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }

    // MARK: – Helpers

    private func formatDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

// MARK: – Trip Detail Bottom Sheet
struct TripDetailBottomSheetView: View {
    let trip: PastTrip

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear

            VStack(spacing: 0) {
                // Blue Header
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .fill(Color(hex: "396BAF"))
                    .frame(height: 140)
                    .overlay(
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "arrow.triangle.swap")
                                    .foregroundColor(.white)
                                Text(trip.tripDetail)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            HStack {
                                Label("\(Int(trip.distanceKm)) Kms", systemImage: "paperplane.fill")
                                    .foregroundColor(.white)
                                Spacer()
                                Label("\(trip.durationMinutes) Mins", systemImage: "clock.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                    )

                Spacer()
            }

            VStack(spacing: 16) {
                Spacer().frame(height: 110) // Push white cards slightly below

                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        tripInfoCard(title: trip.driverName!, subtitle: "Driver", icon: "person.fill")
                        tripInfoCard(title: formatDateString(trip.date), subtitle: "Date Of Trip", icon: "calendar")
                    }
                    HStack(spacing: 16) {
                        tripInfoCard(title: "\(Int(trip.cost))", subtitle: "Trip Cost", icon: "indianrupeesign.circle.fill")
                        tripInfoCard(title: trip.mileage, subtitle: "Average Mileage", icon: "fuelpump.fill")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    func tripInfoCard(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
            Text(title)
                .font(.headline)
                .bold()
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    func formatDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

// MARK: – Tab Style Modifier
fileprivate extension View {
    func tabStyle(isSelected: Bool) -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(isSelected ? Color.white : Color.clear)
            .foregroundColor(isSelected ? Color(hex: "396BAF") : .white)
            .cornerRadius(8)
    }
}

// MARK: – PreviewProvider
struct VehicleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleVehicle = Vehicle(
            id: "PREVIEW-001",
            vehicleNo: "MH12AB1234",
            distanceTravelled: 120_000,
            vehicleCategory: "LMV",
            vehicleType: "Car",
            modelName: "Toyota Innova",
            averageMileage: 12.5,
            engineNo: "ENG1234567890",
            licenseRenewalDate: Date(),
            carImage: "car"
        )

        VehicleDetailView(vehicle: sampleVehicle)
    }
}
