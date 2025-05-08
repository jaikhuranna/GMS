//
// TripCompletedView.swift
// fleetManagementSystem
//
// Created by user@61 on 04/05/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct TripCompletedCard: View {
    let bookingRequestID: String
    let onHideOverlay: () -> Void
    @ObservedObject var viewModel: AuthViewModel
    
    @State private var isUpdating = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)

            Text("Trip Completed!")
                .font(.title2).bold()

            Text("Thanks for driving safely.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                
            if isUpdating {
                ProgressView()
                    .padding()
            }

          
            Button("Done") {
                isUpdating = true
                let db = Firestore.firestore()
                
                // 1. First update booking status
                let ref = db.collection("bookingRequests")
                    .document(bookingRequestID)
                ref.updateData(["status": "completed"]) { error in
                    if let error = error {
                        errorMessage = "Failed to complete trip: \(error.localizedDescription)"
                        showError = true
                        isUpdating = false
                    } else {
                        // 2. Find and update driver's total trips count
                        db.collection("fleetDrivers")
                            .whereField("id", isEqualTo: viewModel.userId)
                            .limit(to: 1)
                            .getDocuments { (snapshot, error) in
                                if let doc = snapshot?.documents.first {
                                    // Get actual document ID
                                    let driverDocId = doc.documentID
                                    
                                    // Update using document ID
                                    db.collection("fleetDrivers")
                                        .document(driverDocId)
                                        .updateData([
                                            "totalTrips": FieldValue.increment(Int64(1))
                                        ]) { error in
                                            isUpdating = false
                                            if let error = error {
                                                print("Error updating trip count: \(error)")
                                            } else {
                                                print("Successfully incremented totalTrips")
                                            }
                                            // 3. Hide overlay and navigate
                                            onHideOverlay()
                                        }
                                } else {
                                    isUpdating = false
                                    print("No matching driver found")
                                    onHideOverlay()
                                }
                            }
                    }
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isUpdating ? Color.gray : Color(red: 57/255, green: 107/255, blue: 175/255))
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(isUpdating)
        }
        .padding()
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .shadow(radius: 6)
        .alert(errorMessage ?? "An error occurred", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }
}
