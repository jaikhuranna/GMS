import SwiftUI

// MARK: - Helper View
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

// MARK: - Main View
struct VehicleDetailView: View {
    let vehicleNumber = "KA05AK0434"

    let vehicleDetails: [VehicleDetail] = [
        VehicleDetail(
            vehicleNo: "KA05AK0432",
            engineNumber: "23456789",
            modelNuumber: "2345678",
            vehicleTyper: "LMV",
            licenseRenewed: "12 June 2025",
            maintenanceDate: "24 June 2024",
            distanceTravelled: 400
        )
    ]

    let pastTrips = [
        PastTrip(driverName: "Alex Johnson", vehicleNo: "KA05AK0432", tripDetail: "Bangalore to Mysore", driverImage: "person1", date: "10 April 2024"),
        PastTrip(driverName: "David Lee", vehicleNo: "KA05AK0432", tripDetail: "Chennai to Coimbatore", driverImage: "person1", date: "6 April 2024"),
        PastTrip(driverName: "Emma Brown", vehicleNo: "KA05AK0432", tripDetail: "Hyderabad to Vizag", driverImage: "person1", date: "1 April 2024")
    ]
    
    let pastMaintenances = [
        PastMaintenance(note: "Tyre was Replaced", observerName: "Aviral", dateOfMaintenance: "20/12/2023"),
        PastMaintenance(note: "Gear box was Replaced", observerName: "Aviral", dateOfMaintenance: "20/2/2024"),
        PastMaintenance(note: "Colour was changed from Black to Blue", observerName: "Aviral", dateOfMaintenance: "20/3/2025")
    ]


    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            ZStack(alignment: .top) {
                Color(red: 231/255, green: 237/255, blue: 248/255)
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 220)

                VStack(spacing: 24) {
                    Image("Truck")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                    Text(vehicleNumber)
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)

                    // Segmented Control
                    HStack {
                        Button(action: { selectedTab = 0 }) {
                            Text("Profile")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(selectedTab == 0 ? Color.white : Color(hex: "396BAF"))
                                .foregroundColor(selectedTab == 0 ? Color(hex: "396BAF") : .white)
                                .cornerRadius(8)
                        }

                        Button(action: { selectedTab = 1 }) {
                            Text("Past Trips")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(selectedTab == 1 ? Color.white : Color(hex: "396BAF"))
                                .foregroundColor(selectedTab == 1 ? Color(hex: "396BAF") : .white)
                                .cornerRadius(8)
                        }

                        Button(action: { selectedTab = 2 }) {
                            Text("Maintenance")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(selectedTab == 2 ? Color.white : Color(hex: "396BAF"))
                                .foregroundColor(selectedTab == 2 ? Color(hex: "396BAF") : .white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(4)
                    .background(Color(hex: "396BAF"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }

            // MARK: - Content Area
            ScrollView {
                VStack(spacing: 16) {
                    if selectedTab == 0 {
                        // Profile Tab
                        ForEach(vehicleDetails) { detail in
                            VStack(spacing: 12) {
                                InfoRow(title: "Vehicle Number", value: detail.vehicleNo)
                                InfoRow(title: "Model Number", value: detail.modelNuumber)
                                InfoRow(title: "Engine Number", value: detail.engineNumber)
                                InfoRow(title: "Vehicle Type", value: detail.vehicleTyper)
                                InfoRow(title: "License Renewed", value: detail.licenseRenewed)
                                InfoRow(title: "Maintenance Date", value: detail.maintenanceDate)
                                InfoRow(title: "Distance Travelled", value: "\(detail.distanceTravelled) Kms")
                            }
                            .padding(.vertical, 16)
                            .background(Color(hex: "396BAF").opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    } else if selectedTab == 1 {
                        // Past Trips Tab
                        ForEach(pastTrips) { trip in
                            HStack(alignment: .center, spacing: 16) {
                                Image(trip.driverImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
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
                                    
                                    Text("Date: \(trip.date)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .cornerRadius(12)
                            .background(Color(hex: "396BAF").opacity(0.1))
                            .padding(.horizontal)
                        }
                    } else if selectedTab == 2 {
                        // Past Maintenance Tab
                        ForEach(pastMaintenances) { maintenance in
                            HStack(alignment: .center, spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Note: \(maintenance.note)")
                                        .font(.headline)
                                        .foregroundColor(Color(hex: "FF0000"))
                                    
                                    Text("Observer Name: \(maintenance.observerName)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Date of Maintenance: \(maintenance.dateOfMaintenance)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .cornerRadius(12)
                            .background(Color(hex: "396BAF").opacity(0.1))
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 60) // to avoid overlap with button

            // MARK: - Schedule Button
            Button(action: {
                // Schedule trip action
            }) {
                Text("Schedule A Trip")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "396BAF"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color(red: 231/255, green: 237/255, blue: 248/255).ignoresSafeArea())
    }
}

// MARK: - Preview
struct VehicleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleDetailView()
    }
}
