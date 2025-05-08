//
//  BillApprovalLoaderView.swift
//  fleetManagementSystem
//
//  Created by Steve on 08/05/25.
//


import SwiftUI
import Firebase

struct BillApprovalLoaderView: View {
    let billId: String
    @State private var billRequest: BillRequest?

    var body: some View {
        Group {
            if let bill = billRequest {
                BillApprovalView(request: bill)
            } else {
                ProgressView("Loading bill...")
            }
        }
        .onAppear {
            fetchBill()
        }
    }

    func fetchBill() {
        Firestore.firestore().collection("pendingBills").document(billId).getDocument { snapshot, error in
            if let doc = snapshot, doc.exists {
                self.billRequest = BillRequest.from(doc)
            }
        }
    }
}
