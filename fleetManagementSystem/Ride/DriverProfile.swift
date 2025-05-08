import SwiftUI
import Combine
import FirebaseFirestore

struct DriverProfile: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AuthViewModel // AuthViewModel for Appwrite auth
    
    // Services for driver data
    @StateObject private var driverService: DriverService
    @StateObject private var recentService: RecentBookingService
    
    // Initialize with AuthViewModel
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        
        // Use Appwrite user ID to find the driver
        _driverService = StateObject(wrappedValue: DriverService(appwriteUserId: viewModel.userId))
        
        // Initialize with placeholder - we'll update when driver is loaded
//        _recentService = StateObject(wrappedValue: RecentBookingService(driverId: "placeholder"))
              _recentService = StateObject(
                 wrappedValue: RecentBookingService(driverId: viewModel.userId)
               )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGray6).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 90)
                    
                    // MARK: - Stats Section
                    if let d = driverService.driver {
                        // Update booking service with real driver ID
                        VStack {
                            HStack(spacing: 21) {
                                StatCardWithIcon(icon: "steeringwheel",
                                               value: "\(d.totalTrips)",
                                               label: "Total Trips")
                                
                                StatCardWithIcon(icon: "clock",
                                               value: String(format: "%.0f Hrs", d.totalTime),
                                               label: "Spent")
                                
                                StatCardWithIcon(icon: "gauge.open.with.lines.needle.33percent",
                                               value: String(format: "%.0f km", d.totalDistance),
                                               label: "Distance")
                            }
                            .padding(.horizontal)
                        }
                        .onAppear {
                            if recentService.driverId == "placeholder" {
                                recentService.updateDriverId(d.id)
                            }
                        }
                    } else {
                        ProgressView().padding()
                    }
                    
                    // MARK: - Ongoing Trip Card
                    if let trip = recentService.recent {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recent")
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                                Text("Navigation")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            
                            TripLocationView(
                                icon: "arrow.up.circle.fill",
                                iconColor: .green,
                                title: trip.pickupName,
                                subtitle: trip.pickupAddress
                            )
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 2, height: 16)
                                .padding(.leading, 10)
                            
                            TripLocationView(
                                icon: "arrow.down.circle.fill",
                                iconColor: .red,
                                title: trip.dropoffName,
                                subtitle: trip.dropoffAddress
                            )
                            
                            Divider()
                            
                            HStack {
                                Text("All Trips (\(driverService.driver?.totalTrips ?? 0))")
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05),
                                radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Maintenance Requests (STATIC DATA)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Maintenance Requests")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Requested on 24th Apr")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        HStack {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 24))
                                
                                Image(systemName: "drop.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 24))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Image(systemName: "truck.box.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 40)
                                
                                Text("KA01HE6655")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            
                            Text("In Progress")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        
                        Divider()
                        
                        NavigationLink(destination: RequestListView()) {
                            HStack {
                                Text("Past Requests (9)")
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05),
                            radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // MARK: - Support & Sign Out
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Support")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                        
                        Button(action: {
                            // Sign out using AuthViewModel
                            Task {
                                   await viewModel.logout()
                                   // Force navigation reset
                                   DispatchQueue.main.async {
                                       if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                          let window = windowScene.windows.first {
                                           let rootView = ApplicationSwitcher().environmentObject(viewModel)
                                           window.rootViewController = UIHostingController(rootView: rootView)
                                       }
                                   }
                               }
                       
                        }) {
                            Text("Sign Out")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .medium))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05),
                            radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 0)
                }
            }
            
            // MARK: - Static Blue Header
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(hex: "#396BAF"))
                        .frame(height: 150)
                        .edgesIgnoringSafeArea(.top)
                    
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        if let full = driverService.driver?.name {
                            let first = full.split(separator: " ").first.map(String.init) ?? full
                            Text("Hello \(first)!")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                        } else {
                            Text("Hello!")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Additional RecentBookingService method

class RecentBookingService: ObservableObject {
    @Published var recent: BookingRequest?
    @Published var driverId: String
    
    init(driverId: String) {
        self.driverId = driverId
        fetchRecentBooking()
    }
    
    func updateDriverId(_ newId: String) {
        if driverId != newId {
            driverId = newId
            fetchRecentBooking()
        }
    }
    

    
    func fetchRecentBooking() {
        guard driverId != "placeholder" else { return }
        
        let db = Firestore.firestore()
        let completedQuery = db.collection("bookingRequests")
            .whereField("driverId", isEqualTo: driverId)
            .whereField("status",   isEqualTo: "completed")    // ← make sure this matches exactly what you’ve written in Firestore
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
        
        completedQuery.getDocuments { snap, err in
            if let err = err {
                print(" completedQuery error:", err)
            } else {
                print(" completedQuery returned \(snap?.documents.count ?? 0) docs")
            }
            
            if let doc = snap?.documents.first,
               let br  = BookingRequest(doc) {
                DispatchQueue.main.async { self.recent = br }
            } else {
                // … fallback to accepted …
                let acceptedQuery = db.collection("bookingRequests")
                    .whereField("driverId", isEqualTo: self.driverId)
                    .whereField("status",   isEqualTo: "accepted")
                    .order(by: "createdAt", descending: true)
                    .limit(to: 1)
                
                acceptedQuery.getDocuments { snap2, err2 in
                    if let err2 = err2 {
                        print("🔥 acceptedQuery error:", err2)
                    } else {
                        print("✅ acceptedQuery returned \(snap2?.documents.count ?? 0) docs")
                    }
                    
                    if let doc2 = snap2?.documents.first,
                       let br2  = BookingRequest(doc2) {
                        DispatchQueue.main.async { self.recent = br2 }
                    }
                }
            }
        }
    }
}
// Keep existing supporting views unchanged

struct StatCardWithIcon: View {
    var icon: String
    var value: String
    var label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.black)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct TripLocationView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
        }
    }
}
