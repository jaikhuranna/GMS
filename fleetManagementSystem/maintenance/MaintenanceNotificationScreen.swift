import SwiftUI
import FirebaseFirestore

// MARK: - Model

struct MaintenanceReport: Identifiable {
    let id: String
    let tripId: String
    let vehicleNumber: String
    let driverId: String
    let issues: [String]
    let notes: String
    let timestamp: Date
}

// MARK: - ViewModel

final class MaintenanceNotificationViewModel: ObservableObject {
    @Published var reports: [MaintenanceReport] = []
    @Published var approvedTasks: [NotificationData] = []

    func fetchApprovedTasks() {
        FirebaseModules.shared.fetchApprovedBills { items in
            print("✅ Approved tasks fetched: \(items.count)")
            DispatchQueue.main.async {
                self.approvedTasks = items
            }
        }
    }

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchReports()
        fetchApprovedTasks()
    }

    deinit {
        listener?.remove()
    }

    func fetchReports() {
        listener = db
            .collection("maintenanceReports")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents else { return }
                self.reports = docs.compactMap { doc in
                    let data = doc.data()
                    guard
                        let tripId       = data["tripId"] as? String,
                        let vehicle      = data["vehicleNumber"] as? String,
                        let driver       = data["driverId"] as? String,
                        let issues       = data["issues"] as? [String],
                        let notes        = data["notes"] as? String,
                        let ts           = data["timestamp"] as? Timestamp
                    else { return nil }

                    return MaintenanceReport(
                        id: doc.documentID,
                        tripId: tripId,
                        vehicleNumber: vehicle,
                        driverId: driver,
                        issues: issues,
                        notes: notes,
                        timestamp: ts.dateValue()
                    )
                }
            }
    }
}

// MARK: - View

struct MaintenanceNotificationScreen: View {
    @StateObject private var viewModel = MaintenanceNotificationViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ————————————————————————————
                //  Live Maintenance Reports
                // ————————————————————————————
                if !viewModel.reports.isEmpty {
                    SectionView2(
                        title: "Maintenance Reports",
                        items: viewModel.reports.map { report in
                            NotificationData(
                                statusMessage: "Issue reported for \(report.vehicleNumber)",
                                statusColor: .orange,
                                task: report.issues.joined(separator: ", "),
                                vehicle: report.vehicleNumber,
                                date: report.timestamp,
                                notes: report.notes
                            )
                        }
                    )
                }

                //  Requests Section
                SectionView2(title: "Requests", items: [
                    NotificationData(
                        statusMessage: "Fleet Manager has raised a request",
                        statusColor: .red,
                        task: "Tire Replace Task",
                        vehicle: "KN23CB4563"
                    ),
                    NotificationData(
                        statusMessage: "Ravi Kumar has raised a request",
                        statusColor: .red,
                        task: "Tire Replace Task",
                        vehicle: "KN23CB4563"
                    )
                ])
                // ————————————————————————————
                //  Static “Post Maintenance Reviews” Section
                // ————————————————————————————
                if !viewModel.approvedTasks.isEmpty {
                       SectionView2(title: "Post Maintenance Reviews", items: viewModel.approvedTasks)
                   }
            }
            .padding()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Section & Card Views

struct SectionView2: View {
    let title: String
    let items: [NotificationData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            ForEach(items) { item in
                NotificationCard(data: item)
            }
        }
    }
}

struct NotificationData: Identifiable {
    let id = UUID()
    let statusMessage: String
    let statusColor: Color
    let task: String
    let vehicle: String
    var date: Date? = nil
    var notes: String? = nil
}

struct NotificationCard: View {
    let data: NotificationData

    // simple date formatter for real reports
    private var dateFormatted: String {
        guard let date = data.date else { return "" }
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(data.statusColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(data.statusMessage)
                    .foregroundColor(data.statusColor)
                    .fontWeight(.bold)

                // show issues/task
                Text(data.task)
                    .foregroundColor(Color(hex: "#396BAF"))

                // show vehicle
                Text(data.vehicle)
                    .foregroundColor(Color(hex: "#396BAF"))

                // for real reports, also notes & date
                if let notes = data.notes {
                    Text("Notes: \(notes)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                if data.date != nil {
                    Text(dateFormatted)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .font(.subheadline)

            Spacer()
        }
        .padding()
        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct MaintenanceNotificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MaintenanceNotificationScreen()
        }
    }
}


#Preview {
    NavigationStack {
        MaintenanceNotificationScreen()
    }
}
