//
//  PhoneEntryView.swift
//  fleetManagementSystem
//
//  Created by user@61 on 22/04/25.
//


import SwiftUI

struct PhoneEntryView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var phoneNumber: String
    @State private var navigateToOTP = false
    @State private var error = ""
    var onVerificationComplete: () -> Void
    
    init(authViewModel: AuthViewModel, initialPhoneNumber: String = "", onVerificationComplete: @escaping () -> Void) {
        self.authViewModel = authViewModel
        self._phoneNumber = State(initialValue: initialPhoneNumber)
        self.onVerificationComplete = onVerificationComplete
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your phone number").font(.title2)
            
            TextField("+91XXXXXXXXXX", text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text("Please enter your phone number with country code (+91)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button("Send OTP") {
                // Ensure the phone number starts with +91
                var formattedPhone = phoneNumber
                if !formattedPhone.hasPrefix("+") {
                    formattedPhone = "+" + formattedPhone
                }
                if !formattedPhone.hasPrefix("+91") && formattedPhone.hasPrefix("+") {
                    formattedPhone = "+91" + formattedPhone.dropFirst()
                }
                
                authViewModel.sendOTP(to: formattedPhone) { success, errorMsg in
                    if success {
                        navigateToOTP = true
                        phoneNumber = formattedPhone // Save the formatted number
                    } else {
                        error = errorMsg ?? "Failed to send OTP"
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
            
            #if DEBUG
            // For testing purposes only
            Button("Use test code (dev only)") {
                navigateToOTP = true
            }
            .padding(.top, 20)
            .foregroundColor(.gray)
            #endif
            
            NavigationLink(
                destination: OTPVerificationView(
                    authViewModel: authViewModel,
                    onSuccess: onVerificationComplete
                ),
                isActive: $navigateToOTP
            ) {
                EmptyView()
            }
        }
        .padding(30)
        .navigationTitle("Phone Verification")
    }
}
