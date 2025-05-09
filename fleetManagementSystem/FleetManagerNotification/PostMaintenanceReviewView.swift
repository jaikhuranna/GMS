import SwiftUI
import PhotosUI
import FirebaseFirestore

struct PostMaintenanceReviewView: View {
    let billId: String

    @State private var taskName = ""
    @State private var vehicleNo = ""
    @State private var preImages: [String] = []
    @State private var postImages: [String] = []
    @State private var billItems: [BillItem] = []
    @State private var serviceCharge: Double = 0
    @State private var gstAmount: Double = 0
    @State private var totalAmount: Double = 0
    @State private var billRequest: BillRequest?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    



    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Pre-maintenance Images
                Text("Pre Maintenance Images")
                    .font(.headline)
                imageGrid(urls: preImages)

                // Bill and Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bill And Details")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#3B71CA"))
                        .padding(.bottom, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Vehicle Number : \(vehicleNo)")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#3B71CA"))

                        Text(taskName)
                            .font(.subheadline)
                            .foregroundColor(Color.red)
                    }
                    .padding(.bottom, 8)

                    VStack(spacing: 8) {
                        HStack {
                            Text("S.No")
                                .foregroundColor(Color(hex: "#3B71CA"))
                                .frame(width: 50, alignment: .leading)
                            Text("Name")
                                .foregroundColor(Color(hex: "#3B71CA"))
                                .frame(minWidth: 100, alignment: .leading)
                            Text("Quantity")
                                .foregroundColor(Color(hex: "#3B71CA"))
                                .frame(width: 80, alignment: .leading)
                            Text("Price")
                                .foregroundColor(Color(hex: "#3B71CA"))
                                .frame(width: 80, alignment: .trailing)
                        }
                        .font(.subheadline)
                        
                        ForEach(billItems.indices, id: \.self) { i in
                            let item = billItems[i]
                            HStack {
                                Text("\(i + 1).")
                                    .foregroundColor(Color(hex: "#3B71CA"))
                                    .frame(width: 50, alignment: .leading)
                                Text(item.name)
                                    .foregroundColor(Color(hex: "#3B71CA"))
                                    .frame(minWidth: 100, alignment: .leading)
                                Text("\(item.quantity)")
                                    .foregroundColor(Color(hex: "#3B71CA"))
                                    .frame(width: 80, alignment: .leading)
                                Text("\(Int(item.price))")
                                    .foregroundColor(Color(hex: "#3B71CA"))
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .font(.subheadline)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 6)
                    
                    HStack {
                        Text("Service Charge")
                            .foregroundColor(Color(hex: "#3B71CA"))
                        Spacer()
                        Text("\(Int(serviceCharge))")
                            .foregroundColor(Color(hex: "#3B71CA"))
                    }
                    .font(.subheadline)
                    
                    Divider()
                        .padding(.vertical, 6)
                    
                    HStack {
                        Text("GST 18%")
                            .foregroundColor(Color(hex: "#3B71CA"))
                        Spacer()
                        Text("\(Int(gstAmount))")
                            .foregroundColor(Color(hex: "#3B71CA"))
                    }
                    .font(.subheadline)
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#3B71CA"))
                        Spacer()
                        Text("\(Int(totalAmount))")
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#3B71CA"))
                    }
                    .font(.subheadline)
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // Post-maintenance Images
                Text("Post Maintenance Images")
                    .font(.headline)
                imageGrid(urls: postImages)

                // Action Buttons
                HStack(spacing: 16) {
                    Button("Needs Review") {
                        updateStatus(to: "need review")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Approved") {
                        updateStatus(to: "approved")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Post Review")
        .onAppear {
            fetchBillDetails()
            
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                // This assumes MainTabView is the root, and Home tab is tag 0
                NotificationCenter.default.post(name: Notification.Name("SwitchToHomeTab"), object: nil)
                dismiss() // Go back to previous screen
            }
        }

    }

    private func imageGrid(urls: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(urls, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        Color.red
                    } else {
                        ProgressView()
                    }
                }
                .frame(height: 120)
                .cornerRadius(10)
            }
        }
    }
    
    
    private func fetchBillDetails() {
        let ref = Firestore.firestore().collection("pendingBills").document(billId)
        ref.getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else {
                print("❌ Bill not found or error:", error?.localizedDescription ?? "Unknown error")
                return
            }

            // ✅ Parse full BillRequest using shared logic
            if let request = BillRequest.from(snapshot) {
                self.billRequest = request
                self.vehicleNo = request.vehicleNo
                self.taskName = request.taskName

                self.billItems = request.summary.billItems
                self.serviceCharge = Double(request.summary.serviceCharge)
                self.gstAmount = Double(request.summary.gst)
                self.totalAmount = Double(request.summary.total)

                // ✅ Post-maintenance images
                self.postImages = snapshot.data()?["postMaintenanceImages"] as? [String] ?? []

                // ✅ Pre-maintenance images via FirebaseModules
                FirebaseModules.shared.fetchPreMaintenanceImages(
                    vehicleNo: request.vehicleNo,
                    taskName: request.taskName
                ) { urls in
                    self.preImages = urls
                }
            } else {
                print("❌ Failed to parse BillRequest from snapshot.")
            }
        }
    }

    
    
    private func updateStatus(to newStatus: String) {
        let ref = Firestore.firestore().collection("pendingBills").document(billId)
        ref.updateData(["status": newStatus]) { error in
            if let error = error {
                print("❌ Failed to update:", error.localizedDescription)
            } else {
                print("✅ Status updated to \(newStatus)")
                alertMessage = newStatus == "approved" ? "Bill Approved" : "Review Needed"
                showAlert = true
            }
        }
    }

}


struct PostMaintenanceReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PostMaintenanceReviewView(billId: "demo_bill_id_123")
        }
    }
}

