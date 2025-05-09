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
    @State private var showConfetti = false
    @State private var animateCheck = false

    var body: some View {
        ZStack {
            // Fullscreen white background
            Color.white.ignoresSafeArea()
            
            // Confetti animation (simple circles for now)
            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
            }

            VStack(spacing: 32) {
                Spacer()
                // Animated checkmark
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 120, height: 120)
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 100, height: 100)
                        .scaleEffect(animateCheck ? 1.0 : 0.5)
                        .opacity(animateCheck ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateCheck)
                }
                .padding(.bottom, 8)
                
                Text("Trip Completed!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 4)
                Text("Thanks for driving safely.")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                
                if isUpdating {
                    ProgressView()
                        .padding()
                }
                
                Spacer()
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
                .cornerRadius(16)
                .disabled(isUpdating)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, 16)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateCheck = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeIn(duration: 0.6)) {
                        showConfetti = true
                    }
                }
            }
            .alert(errorMessage ?? "An error occurred", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

// Simple confetti animation view
struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [.green, .blue, .yellow, .red, .purple, .orange]
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<18) { i in
                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: 12, height: 12)
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: animate ? geo.size.height + 40 : CGFloat.random(in: 0...geo.size.height/2)
                    )
                    .opacity(0.7)
                    .animation(
                        .easeIn(duration: Double.random(in: 1.2...2.2)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
        .allowsHitTesting(false)
    }
}
