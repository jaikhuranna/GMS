import SwiftUI
import FirebaseCore
import FirebaseFirestore

// MARK: - Main View
struct GeneratedBillView: View {
    let vehicleNo: String
    let taskName: String
    let description: String
    let bill: BillSummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // 🔹 Vehicle and Task Info
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Vehicle Number : \(vehicleNo)")
                            .font(.title3)
                            .foregroundColor(Color(hex: "#396BAF"))

                        Text(taskName)
                            .font(.title3)
                            .foregroundColor(Color(hex: "#396BAF"))

                        Text(description)
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // 🔹 Bill Items Table
                VStack(spacing: 16) {
                    HStack {
                        Text("S.No").frame(width: 50, alignment: .leading)
                        Text("Name").frame(width: 120, alignment: .leading)
                        Spacer()
                        Text("Qty").frame(width: 50)
                        Text("Price").frame(width: 70, alignment: .trailing)
                    }
                    .font(.headline)
                    .foregroundColor(Color(hex: "#396BAF"))

                    ForEach(bill.billItems) { item in
                        HStack {
                            Text("\(item.id).").frame(width: 50, alignment: .leading)
                            Text(item.name).frame(width: 120, alignment: .leading)
                            Spacer()
                            Text("\(item.quantity)").frame(width: 50)
                            Text("₹\(item.price)").frame(width: 70, alignment: .trailing)
                        }
                        .foregroundColor(Color(hex: "#396BAF"))
                    }

                    Divider()

                    Group {
                        HStack {
                            Text("Service Charge")
                            Spacer()
                            Text("₹\(bill.serviceCharge)")
                        }

                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text("₹\(bill.subtotal + bill.serviceCharge)")
                        }

                        HStack {
                            Text("GST (18%)")
                            Spacer()
                            Text("₹\(bill.gst)")
                        }

                        Divider()

                        HStack {
                            Text("Total").fontWeight(.bold)
                            Spacer()
                            Text("₹\(bill.total)").fontWeight(.bold)
                        }
                    }
                    .foregroundColor(Color(hex: "#396BAF"))
                }
                .padding()
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // 🔹 Action Button
                Button("Send For Approval") {
                    let db = Firestore.firestore()
                    let docId = UUID().uuidString

                    let billData: [String: Any] = [
                        "id": docId,
                        "vehicleNo": vehicleNo,
                        "taskName": taskName,
                        "description": description,
                        "parts": bill.billItems.map { ["name": $0.name, "quantity": $0.quantity, "price": $0.price] },
                        "subtotal": bill.subtotal,
                        "gst": bill.gst,
                        "serviceCharge": bill.serviceCharge,
                        "total": bill.total,
                        "status": "pending",
                        "timestamp": Timestamp(date: Date())
                    ]

                    db.collection("pendingBills").document(docId).setData(billData) { error in
                        if let error = error {
                            print("❌ Failed to send bill: \(error.localizedDescription)")
                        } else {
                            print("✅ Bill sent for approval.")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#F05545"))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Generated Bill")
        .navigationBarTitleDisplayMode(.inline)
    }
}





// MARK: - Preview
struct GeneratedBillView_Previews: PreviewProvider {
    static var previews: some View {
        let parts = [Part(name: "Brake Pad Set", quantity: "2")]
        let fluids = [Part(name: "Engine Oil 5W-30", quantity: "1")]
        let inventory = [
            InventoryItem(name: "Brake Pad Set", quantity: 10, price: 1200, partID: "BP-001"),
            InventoryItem(name: "Engine Oil 5W-30", quantity: 5, price: 450)
        ]
        let bill = BillSummary(parts: parts, fluids: fluids, inventory: inventory)

        NavigationStack {
            GeneratedBillView(
                vehicleNo: "KA01AB1234",
                taskName: "Routine Service",
                description: "Replaced brake pads and topped up engine oil.",
                bill: bill
            )
        }
    }
}
