////
////  PendingBillsView.swift
////  fleetManagementSystem
////
////  Created by Steve on 07/05/25.
////
//
//
//import SwiftUI
//import Firebase
//
//struct PendingBillsView: View {
//    @State private var pendingBills: [BillRequest] = []
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                ForEach(pendingBills) { bill in
//                    GeneratedBillView(
//                        vehicleNo: bill.vehicleNo,
//                        taskName: bill.taskName,
//                        description: bill.description,
//                        bill: bill.summary
//                    )
//                    .overlay(
//                        HStack {
//                            Button("Reject") {
//                                updateStatus(id: bill.id, to: "rejected")
//                            }
//                            .foregroundColor(.red)
//
//                            Spacer()
//
//                            Button("Accept") {
//                                updateStatus(id: bill.id, to: "approved")
//                            }
//                            .foregroundColor(.green)
//                        }
//                        .padding()
//                        .background(Color.white)
//                        , alignment: .bottom
//                    )
//                }
//            }
//            .padding()
//        }
//        .onAppear(perform: fetchBills)
//        .navigationTitle("Pending Approvals")
//    }
//
//    func fetchBills() {
//        let db = Firestore.firestore()
//        db.collection("pendingBills")
//            .whereField("status", isEqualTo: "pending")
//            .getDocuments { snapshot, error in
//                if let docs = snapshot?.documents {
//                    self.pendingBills = docs.compactMap { doc in
//                        BillRequest.from(doc)
//                    }
//                }
//            }
//    }
//
//    func updateStatus(id: String, to status: String) {
//        Firestore.firestore().collection("pendingBills").document(id).updateData([
//            "status": status
//        ])
//    }
//}
