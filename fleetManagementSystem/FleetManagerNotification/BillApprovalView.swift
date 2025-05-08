//
//  BillApprovalView.swift
//  fleetManagementSystem
//
//  Created by Steve on 07/05/25.
//

import SwiftUI
import FirebaseFirestore

struct BillApprovalView: View {
    let request: BillRequest
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Vehicle Info Box
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vehicle Number: \(request.vehicleNo)\n")
                        .font(.body)
                        .foregroundColor(Color(hex: "#396BAF"))
                    
                    Text("\(request.taskName):")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#396BAF"))

                    Text(request.description)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 144, alignment: .leading)
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // Table Box
                VStack(spacing: 8) {
                    HStack {
                        Text("S.No").bold()
                            .frame(width: 44, alignment: .leading)

                        Text("Name").bold()
                            .frame(width: 120, alignment: .leading)

                        Text("Quantity").bold()
                            .frame(width: 70, alignment: .center)

                        Text("Price").bold()
                            .frame(width: 70, alignment: .trailing)
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                
                    Divider()

                    ForEach(request.summary.billItems) { item in
                        HStack {
                            Text("\(item.id)")
                                .frame(width: 44, alignment: .leading)

                            Text(item.name)
                                .frame(width: 120, alignment: .leading)

                            Text("\(item.quantity)")
                                .frame(width: 70, alignment: .center)

                            Text("₹\(item.price)")
                                .frame(width: 70, alignment: .trailing)
                        }
                        .font(.body)
                        .foregroundColor(Color(hex: "#396BAF"))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // Charges Summary Box
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Service Charge")
                        Spacer()
                        Text("₹\(request.summary.serviceCharge)")
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                
                    HStack {
                        Text("GST 18%")
                        Spacer()
                        Text("₹\(request.summary.gst)")
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                
                    Divider()
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("₹\(request.summary.total)")
                            .font(.headline)
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        updateBillStatus(to: "rejected")
                    }) {
                        Text("Reject")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        updateBillStatus(to: "approved")
                    }) {
                        Text("Accept")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Maintenance Request Approval")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle.contains("Success") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
    
    func updateBillStatus(to status: String) {
        Firestore.firestore().collection("pendingBills")
            .document(request.id)
            .updateData(["status": status]) { error in
                if let error = error {
                    alertTitle = "Error"
                    alertMessage = "Failed to update status: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    alertTitle = "Success"
                    alertMessage = "Request has been \(status == "approved" ? "approved" : "rejected")"
                    showAlert = true
                }
            }
    }
}

// MARK: - Preview

struct BillApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRequest = BillRequest(
            id: "sample123",
            vehicleNo: "GH 89 YG 2345",
            taskName: "Regular Check Up Task",
            description: "The tires need to be changed",
            summary: BillSummary(
                billItems: [
                    BillItem(id: 1, name: "Front Tires", quantity: 2, price: 3200),
                    BillItem(id: 2, name: "Rear Tires", quantity: 2, price: 3200),
                    BillItem(id: 3, name: "Wheel Alignment", quantity: 1, price: 1500)
                ],
                subtotal: 7900,
                serviceCharge: 500,
                gst: 1512,
                total: 9912
            )
        )

        return NavigationView {
            BillApprovalView(request: sampleRequest)
        }
    }
}
