import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

struct VehicleChecklistView: View {
    // MARK: - Properties
    let vehicleNumber: String
    let bookingRequestID: String
    let phase: InspectionPhase
    let driverId: String
    @StateObject private var alertTimer = AlertTimerManager()
     @State private var navigateToDriverProfileAfterAlert = false
    
    private let db = Firestore.firestore()
    @ObservedObject var viewModel: AuthViewModel
    @State private var navigateToMap = false
    @State private var selectedItems = Set<String>()
    @State private var showCompleted = false
    @Environment(\.presentationMode) var presentationMode
    
    // Restored maintenance report functionality
    @State private var showReportPopup = false
    @State private var reportNotes = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let items = [
        "Engine",
        "Tires & Wheels",
        "Oil Levels",
        "Brake",
        "Transmission",
        "Exhaust System"
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Main Checklist UI ──
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.trailing, 16)
                    }
                    Spacer()
                    Text(phase == .pre ? "Pre-Trip Checklist" : "Post-Trip Checklist")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding()
                .background(Color.white)
                
                // Truck image & number
                VStack(spacing: 8) {
                    Image("truck")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                    Text(vehicleNumber)
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.vertical)
                
                // Checklist grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(items, id: \.self) { item in
                        ChecklistButton(
                            icon: iconName(for: item),
                            title: item,
                            isSelected: selectedItems.contains(item)
                        ) {
                            toggleSelection(item)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Save / Continue button
                Button {
                    handleAction()
                } label: {
                    HStack {
                        Image(systemName: selectedItems.count == items.count
                              ? "checkmark.seal.fill"
                              : "wrench.and.screwdriver")
                        .foregroundColor(.white)
                        Text(selectedItems.count == items.count
                             ? (phase == .pre ? "Vehicle Ready!" : "All Good!")
                             : "Report Maintenance Issue!")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        selectedItems.count == items.count
                        ? Color(red: 63/255, green: 98/255, blue: 163/255)
                        : Color.red.opacity(0.85)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Hidden nav back to map (pre‑trip)
                NavigationLink(
                    destination: NavigationMapView(
                        driverId: driverId,
                        bookingRequestID: bookingRequestID,
                        vehicleNumber: vehicleNumber,
                        viewModel: viewModel
                    ),
                    isActive: $navigateToMap
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .disabled(showCompleted || showReportPopup)
            .blur(radius: (showCompleted || showReportPopup) ? 2 : 0)
            
            // ── Maintenance Report Popup ──
            if showReportPopup {
                reportPopup
            }
            
            // ── Trip Completed Overlay ──
            if showCompleted {
                // Dimmed backdrop
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                // In VehicleChecklistView.swift - Change the TripCompletedCard code:
                TripCompletedCard(
                    bookingRequestID: bookingRequestID,
                    onHideOverlay: {
                        withAnimation { showCompleted = false }
                        // Don't dismiss immediately, wait for animation to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // First dismiss current view
                            presentationMode.wrappedValue.dismiss()
                            
                            // Then after dismissal is complete, reset root view controller
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    let driverProfileView = DriverProfile(viewModel: viewModel)
                                    window.rootViewController = UIHostingController(rootView: driverProfileView)
                                }
                            }
                        }
                    },
                    viewModel: viewModel
                )
                .frame(maxWidth: 350)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 8)
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: showCompleted)
        .animation(.easeInOut, value: showReportPopup)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .alert(alertMessage, isPresented: $alertTimer.showAlert) {
            Button("OK") {
                alertTimer.invalidateTimer()
                navigateToDriverProfile()
            }
        } message: {
            Text("This alert will automatically dismiss in 10 seconds.")
        }
    }
    
    // MARK: - Report Popup View
    private var reportPopup: some View {
        let issues = items.filter { !selectedItems.contains($0) }
        return ZStack {
            Color.black.opacity(0.35)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { /* block taps */ }
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(spacing: 24) {
                    Capsule()
                        .frame(width: 48, height: 6)
                        .foregroundColor(Color.gray.opacity(0.18))
                        .padding(.top, 18)
                        .padding(.bottom, 8)
                    Text("Report Maintenance Issues")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.bottom, 2)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Issues:")
                            .font(.subheadline).bold()
                        ForEach(issues, id: \.self) { issue in
                            Text("• \(issue)")
                                .font(.body)
                        }
                        Text("Notes:")
                            .font(.subheadline).bold()
                        TextEditor(text: $reportNotes)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2)
                    VStack(spacing: 14) {
                        Button(action: { showReportPopup = false }) {
                            Text("Cancel")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        Button(action: { sendMaintenanceReport(issues: issues) }) {
                            Text("Send")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 57/255, green: 107/255, blue: 175/255))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .background(Color.white)
                .cornerRadius(28)
                .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 8)
                .frame(maxWidth: 380)
                Spacer(minLength: 0)
            }
        }
    }
    
    // MARK: - Helpers
    private func toggleSelection(_ item: String) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
    
    private func iconName(for item: String) -> String {
        switch item {
        case "Engine": return "engine.combustion.badge.exclamationmark.fill"
        case "Oil Levels": return "oilcan.fill"
        case "Brake": return "abs.brakesignal"
        case "Transmission": return "gearshift.layout.sixspeed"
        case "Exhaust System": return "carbon.dioxide.cloud.fill"
        case "Tires & Wheels": return "tire"
        default: return "checkmark"
        }
    }
    
    // MARK: - Actions
    private func handleAction() {
        if selectedItems.count == items.count {
            saveChecklist()
        } else {
            showReportPopup = true
        }
    }
    
    private func saveChecklist() {
        let data: [String: Any] = [
            "tripId": bookingRequestID,
            "vehicleNumber": vehicleNumber,
            "checklist": Array(selectedItems),
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection(phase.collectionName)
            .addDocument(data: data) { error in
                if let error = error {
                    alertMessage = "Failed to save checklist: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    if phase == .pre {
                        navigateToMap = true
                    } else {
                        showCompleted = true
                    }
                }
            }
    }

    private func sendMaintenanceReport(issues: [String]) {
        // Prepare maintenance report entry
        let reportData: [String: Any] = [
            "tripId": bookingRequestID,
            "vehicleNumber": vehicleNumber,
            "driverId": driverId,
            "issues": issues,
            "notes": reportNotes,
            "timestamp": Timestamp(date: Date())
        ]
        
        // Write report
        db.collection("maintenanceReports").addDocument(data: reportData) { error in
            if let error = error {
                alertMessage = "Failed to report maintenance issues: \(error.localizedDescription)"
                alertTimer.startTimer()
                return
            }
            
            // Fetch user IDs by role
            let roles = ["fleet_manager", "maintenance"]
            let usersRef = db.collection("users")
            var recipientIDs = [String]()
            let dispatchGroup = DispatchGroup()
            
            for role in roles {
                dispatchGroup.enter()
                usersRef.whereField("role", isEqualTo: role).getDocuments { snapshot, err in
                    if let docs = snapshot?.documents {
                        let ids = docs.map { $0.documentID }
                        recipientIDs.append(contentsOf: ids)
                    }
                    dispatchGroup.leave()
                }
            }
            
            // After fetching all roles, send notification
            dispatchGroup.notify(queue: .main) {
                let notifData: [String: Any] = [
                    "title": "Maintenance Issue Reported",
                    "body": "Driver \(driverId) reported issues: \(issues.joined(separator: ", ")). Notes: \(reportNotes)",
                    "recipients": recipientIDs,
                    "tripId": bookingRequestID,
                    "timestamp": Timestamp(date: Date())
                ]
                
                db.collection("notifications").addDocument(data: notifData)
                
                // Setup the alert with timer and navigation
                alertMessage = "Maintenance issues reported successfully. Vehicle requires maintenance before trip."
                showReportPopup = false
                
                // Set the completion handler
                alertTimer.onTimerComplete = {
                    navigateToDriverProfile()
                }
                
                // Start the timer
                alertTimer.startTimer()
            }
        }
    }

    // Helper function to navigate to driver profile
    private func navigateToDriverProfile() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let driverProfileView = DriverProfile(viewModel: viewModel)
            window.rootViewController = UIHostingController(rootView: driverProfileView)
        }
    }


}

private struct ChecklistButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(Color(red: 57/255, green: 107/255, blue: 175/255))
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 57/255, green: 107/255, blue: 175/255))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 140, height: 140)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.gray.opacity(0.1), radius: 2, x: 0, y: 1)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(red: 57/255, green: 107/255, blue: 175/255), lineWidth: 1))
            .overlay {
                if isSelected {
                    Circle()
                        .fill(Color(red: 57/255, green: 107/255, blue: 175/255))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 50, y: -50)
                }
            }
        }
    }
}

class AlertTimerManager: ObservableObject {
    @Published var showAlert = false
    var timer: Timer?
    var onTimerComplete: (() -> Void)?
    
    func startTimer(seconds: Double = 10) {
        showAlert = true
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showAlert = false
                self?.onTimerComplete?()
            }
        }
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
