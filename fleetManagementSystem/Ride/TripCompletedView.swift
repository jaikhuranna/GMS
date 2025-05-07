//
//  TripCompletedView.swift
//  fleetManagementSystem
//
//  Created by user@61 on 04/05/25.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

//struct TripCompletedCard: View {
//    let onDone: () -> Void
//    @State private var navigateToDriverProfile = false
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Capsule()
//                .frame(width: 40, height: 6)
//                .foregroundColor(.gray.opacity(0.4))
//                .padding(.top, 8)
//
//            Text("Trip Completed!")
//                .font(.title2).bold()
//
//            Text("Thanks for driving safely.")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//            NavigationLink(destination: DriverProfile(), isActive: $navigateToDriverProfile) {
//                Button("Done") {
//                    // Action when done is tapped
//                    navigateToDriverProfile = true
//                    onDone()
//                }
//                .font(.headline)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(12)
//            }
//        }
//        .padding()
//        .cornerRadius(24, corners: [.topLeft, .topRight])
//        .shadow(radius: 6)
//    }
//}
//


//
//  TripCompletedView.swift
//  fleetManagementSystem
//
//  Created by user@61 on 04/05/25.
//

struct TripCompletedCard: View {
    let bookingRequestID: String
    let onDone: () -> Void
    @ObservedObject var viewModel: AuthViewModel
    
    @State private var navigateToDriverProfile = false
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
            
            NavigationLink(
                   destination: DriverProfile(viewModel: viewModel),
                   isActive: $navigateToDriverProfile
                 ) {
                   Button("Done") {
                     isUpdating = true
                     let ref = Firestore.firestore()
                         .collection("bookingRequests")
                         .document(bookingRequestID)
                     ref.updateData(["status": "completed"]) { error in
                       isUpdating = false
                       if let error = error {
                         errorMessage = "Failed to complete trip: \(error.localizedDescription)"
                         showError = true
                       } else {
                         print("Trip completed")
                         onDone()
                         navigateToDriverProfile = true
                       }
                     }
                   }
                   .font(.headline)
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(isUpdating ? Color.gray : Color.blue)
                   .foregroundColor(.white)
                   .cornerRadius(12)
                   .disabled(isUpdating)
            }
        }
        .padding()
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .shadow(radius: 6)
        .alert(errorMessage ?? "An error occurred", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }
}

// MARK: - Booking Service Extension
extension BookingService {
    func clearBooking() {
        DispatchQueue.main.async {
            self.booking = nil
        }
    }
}
