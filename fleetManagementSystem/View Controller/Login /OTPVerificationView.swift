//
//  OTPVerificationView.swift
//  fleetManagementSystem
//
//  Created by user@61 on 22/04/25.
//


import SwiftUI

struct OTPVerificationView: View {
    @ObservedObject var authViewModel: AuthViewModel
    var onSuccess: () -> Void
    
    @State private var otpCode = ""
    @State private var error = ""
    @State private var isResending = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Enter Verification Code")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We've sent a 6-digit code to your phone number. Please enter it below.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("6-digit code", text: $otpCode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Button("Verify") {
                authViewModel.verifyOTP(code: otpCode) { success, errorMsg in
                    if success {
                        onSuccess()
                    } else {
                        error = errorMsg ?? "Verification failed"
                    }
                }
            }
            .padding()
            .frame(minWidth: 200)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if !error.isEmpty {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
            
            Button("Resend Code") {
                isResending = true
                // Get last phone number from Firebase Auth current user
                if let phoneNumber = authViewModel.currentUser?.phoneNumber {
                    authViewModel.sendOTP(to: phoneNumber) { success, errorMsg in
                        isResending = false
                        if !success {
                            error = errorMsg ?? "Failed to resend code"
                        } else {
                            error = "" // Clear error on success
                        }
                    }
                } else {
                    isResending = false
                    error = "Phone number not found"
                }
            }
            .disabled(isResending)
            .padding(.top, 16)
            
            #if DEBUG
            // For testing purposes only
            Button("Use test code (123456)") {
                otpCode = authViewModel.testVerificationCode
            }
            .padding(.top, 16)
            .foregroundColor(.gray)
            #endif
        }
        .padding(30)
        .navigationTitle("Verification")
    }
}
