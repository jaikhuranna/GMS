////
////  AuthenticatorSetupScreen.swift
////  fleetManagementSystem
////
////  Created by Steve on 27/04/25.
////
//
//import SwiftUI
//
//struct AuthenticatorSetupScreen: View {
//    @ObservedObject var viewModel: AuthViewModel
//
//    @State private var otpInput: String = ""
//
//    var body: some View {
//        VStack(spacing: 20) {
//            LogoView()
//
//            Text("Set up Two-Factor Authentication")
//                .font(.title2)
//                .bold()
//                .multilineTextAlignment(.center)
//                .padding()
//
//            if let url = URL(string: viewModel.totpUrl) {
//                AsyncImage(url: url) { image in
//                    image.resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 200, height: 200)
//                } placeholder: {
//                    ProgressView()
//                }
//                .padding()
//            }
//
//            Text("Scan this QR code in Google Authenticator or Authy app.\nThen enter the 6-digit code below.")
//                .multilineTextAlignment(.center)
//                .font(.subheadline)
//                .padding(.horizontal)
//
//            TextField("Enter 6-digit code", text: $otpInput)
//                .keyboardType(.numberPad)
//                .padding()
//                .background(Color.white)
//                .cornerRadius(6)
//                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray))
//
//            Button("Verify and Finish Setup") {
//                viewModel.verifyAuthenticatorCode(code: otpInput)
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(6)
//
//            Spacer()
//        }
//        .padding()
//    }
//}
