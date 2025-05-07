import SwiftUI
import Combine
import FirebaseFirestore

import FirebaseAuth

//struct DriverProfile: View {
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        
//            ZStack(alignment: .top) {
//                Color(.systemGray6).ignoresSafeArea()
//
//                ScrollView {
//                    VStack(spacing: 16) {
//                        Spacer().frame(height: 90)
//
//                        // Stats Section
//                        HStack(spacing: 21) {
//                            StatCardWithIcon(icon: "steeringwheel", value: "671", label: "Total Trips")
//                            StatCardWithIcon(icon: "clock", value: "2684 Hrs", label: "Spent")
//                            StatCardWithIcon(icon: "gauge.open.with.lines.needle.33percent", value: "25671 km", label: "Distance")
//                        }
//                        .padding(.horizontal)
//
//                        // Ongoing Trip Card
//                        VStack(alignment: .leading, spacing: 16) {
//                            HStack {
//                                Text("Ongoing")
//                                    .font(.system(size: 20, weight: .bold))
//                                Spacer()
//                                Text("Navigation")
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundColor(.blue)
//                                    .padding(.horizontal, 12)
//                                    .padding(.vertical, 4)
//                                    .background(Color(.systemGray6))
//                                    .cornerRadius(12)
//                            }
//
//                            TripLocationView(
//                                icon: "arrow.up.circle.fill",
//                                iconColor: .green,
//                                title: "Infosys Gate 2",
//                                subtitle: "Meenakunte, Hebbal Industrial Area"
//                            )
//
//                            Rectangle()
//                                .fill(Color.gray.opacity(0.3))
//                                .frame(width: 2, height: 16)
//                                .padding(.leading, 10)
//
//                            TripLocationView(
//                                icon: "arrow.down.circle.fill",
//                                iconColor: .red,
//                                title: "Mysuru Airport",
//                                subtitle: "Mandakalli, Karnataka 571311"
//                            )
//
//                            Divider()
//
//                            HStack {
//                                Text("All Trips (671)")
//                                    .font(.system(size: 14, weight: .medium))
//                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//                        .padding(.horizontal)
//
//                        // Maintenance Requests Card
//                        VStack(alignment: .leading, spacing: 16) {
//                            Text("Maintenance Requests")
//                                .font(.system(size: 18, weight: .bold))
//
//                            Text("Requested on 24th Apr")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//
//                            HStack {
//                                HStack(spacing: 12) {
//                                    Image(systemName: "exclamationmark.triangle.fill")
//                                        .foregroundColor(.blue)
//                                        .font(.system(size: 24))
//                                    Image(systemName: "drop.triangle.fill")
//                                        .foregroundColor(.red)
//                                        .font(.system(size: 24))
//                                }
//
//                                Spacer()
//
//                                VStack(alignment: .trailing) {
//                                    Image(systemName: "truck.box.fill")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 70, height: 40)
//
//                                    Text("KA01HE6655")
//                                        .font(.system(size: 14))
//                                        .foregroundColor(.black)
//                                }
//                            }
//
//                            HStack(spacing: 8) {
//                                Circle()
//                                    .fill(Color.green)
//                                    .frame(width: 10, height: 10)
//                                Text("In Progress")
//                                    .font(.system(size: 14, weight: .semibold))
//                                Spacer()
//                            }
//
//                            Divider()
//
//                            // NavigationLink to RequestListView
//                            NavigationLink(destination: RequestListView()) {
//                                HStack {
//                                    Text("Past Requests (9)")
//                                        .font(.system(size: 14, weight: .medium))
//                                    Spacer()
//                                    Image(systemName: "chevron.right")
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//                        .padding(.horizontal)
//
//                        // Support and Sign Out
//                        VStack(spacing: 16) {
//                            HStack {
//                                Image(systemName: "questionmark.circle")
//                                Text("Support")
//                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.gray)
//                            }
//                            Divider()
//
//                            Button(action: {
//                                // Sign out logic
//                            }) {
//                                Text("Sign Out")
//                                    .foregroundColor(.red)
//                                    .font(.system(size: 16, weight: .medium))
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    .padding(.horizontal, 20)
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//                        .padding(.horizontal)
//
//                        Spacer(minLength: 0)
//                    }
//                }
//
//                // Static Blue Header
//                VStack(spacing: 0) {
//                    ZStack(alignment: .topLeading) {
//                        RoundedRectangle(cornerRadius: 32, style: .continuous)
//                            .fill(Color(hex: "#396BAF"))
//                            .frame(height: 150)
//                            .edgesIgnoringSafeArea(.top)
//
//                        VStack(alignment: .leading, spacing: 12) {
//                            HStack {
//                                Button(action: {
//                                    dismiss()
//                                }) {
//                                    Image(systemName: "arrow.left")
//                                        .foregroundColor(.white)
//                                        .padding()
//                                }
//
//                                Text("Hello Dave!")
//                                    .font(.title2.bold())
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 5)
//
//                                Spacer()
//
//                                Image(systemName: "person.crop.circle.fill")
//                                    .resizable()
//                                    .frame(width: 40, height: 40)
//                                    .foregroundColor(.white)
//                                    .padding()
//                            }
//                        }
//                    }
//
//                    Spacer()
//                }
//            }
//            .navigationBarHidden(true)
//        }
//}
//
//
//// MARK: - Updated Stat Card
//
//struct StatCardWithIcon: View {
//    var icon: String
//    var value: String
//    var label: String
//
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: icon)
//                .font(.system(size: 32))
//                .foregroundColor(.black)
//
//            Text(value)
//                .font(.system(size: 18, weight: .bold))
//                .foregroundColor(.black)
//
//            Text(label)
//                .font(.system(size: 14))
//                .foregroundColor(.blue)
//        }
//        .frame(maxWidth: .infinity, minHeight: 100)
//        .padding()
//        .background(Color(red: 0.95, green: 0.97, blue: 1.0)) // light blue
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.blue, lineWidth: 1)
//        )
//        .cornerRadius(12)
//    }
//}
//
//// MARK: - Trip Location Component
//
//struct TripLocationView: View {
//    let icon: String
//    let iconColor: Color
//    let title: String
//    let subtitle: String
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            Image(systemName: icon)
//                .foregroundColor(iconColor)
//                .font(.system(size: 20))
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.system(size: 16, weight: .semibold))
//                Text(subtitle)
//                    .font(.system(size: 14))
//                    .foregroundColor(.blue)
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//struct DriverProfile_Previews: PreviewProvider {
//    static var previews: some View {
//        DriverProfile()
//    }

class RecentBookingService: ObservableObject {
  @Published var recent: BookingRequest?
  init(driverId: String) {
    let db = Firestore.firestore()

    // 1) Try completed first
    let completedQuery = db.collection("bookingRequests")
      .whereField("driverId", isEqualTo: driverId)
      .whereField("status",   isEqualTo: "completed")
      .order(by:   "createdAt", descending: true)
      .limit(to:   1)

    completedQuery.getDocuments { snap, err in
      if let doc = snap?.documents.first,
         let br  = BookingRequest(doc) {
        DispatchQueue.main.async { self.recent = br }
      } else {
        // 2) Fallback to accepted
        let acceptedQuery = db.collection("bookingRequests")
          .whereField("driverId", isEqualTo: driverId)
          .whereField("status",   isEqualTo: "accepted")
          .order(by:   "createdAt", descending: true)
          .limit(to:   1)
        acceptedQuery.getDocuments { snap2, _ in
          if let doc2 = snap2?.documents.first,
             let br2  = BookingRequest(doc2) {
            DispatchQueue.main.async { self.recent = br2 }
          }
        }
      }
    }
  }
}


struct DriverProfile: View {
    @Environment(\.dismiss) private var dismiss

    // You’ll still need these two services:
    @StateObject private var driverService: DriverService
    @StateObject private var recentService: RecentBookingService

    init(driverId: String) {
        _driverService  = StateObject(wrappedValue: DriverService(driverId: driverId))
        _recentService = StateObject(
          wrappedValue: RecentBookingService(driverId: driverId)
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 90)

                    // MARK: — Stats Section
                    if let d = driverService.driver {
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
                    } else {
                        ProgressView().padding()
                    }

                    // MARK: — Ongoing Trip Card
                    if let trip = recentService.recent{
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

                    // MARK: — Maintenance Requests (STATIC DATA)
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

                    // MARK: — Support & Sign Out
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Support")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        Divider()
                        Button("Sign Out") {
                            // your sign‑out logic here
                        }
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
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

            // MARK: — Static Blue Header
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
        .background(Color(red: 0.95, green: 0.97, blue: 1.0)) // light blue
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
// MARK: — Preview

struct DriverProfile_Previews: PreviewProvider {
    static var previews: some View {
        DriverProfile(driverId: "SOME_DRIVER_ID")
    }
}
