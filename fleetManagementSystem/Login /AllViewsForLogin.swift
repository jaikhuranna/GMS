// AllViewsForLogin.swift
// fleetManagementSystem
//
// Created by Jai Khurana on 27/04/25.
//

import SwiftUI

// MARK: - Root View


struct AuthRootView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            // Screen switching based on auth state
            Group {
                switch viewModel.screen {
                case .loading:
                    // Show loading screen while checking session
                    VStack {
                        LogoView()
                        ProgressView("Checking login status...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.top, 30)
                    }
                case .login:
                    LoginView(viewModel: viewModel)
                case .setupMFA:
                    MFASetupView(viewModel: viewModel)
                case .verifyMFA:
                    EmailOTPVerificationView(viewModel: viewModel)
                case .home:
                    HomeScreenRouter(viewModel: viewModel)
                }
            }
            .animation(.easeInOut, value: viewModel.screen)
            
            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .alert("Error", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
            Button("OK") {
                viewModel.errorMessage = ""
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}


// MARK: - Logo View

struct LogoView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "car.fill") // Fallback if Logo isn't available
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.bottom, 8)
            
            Text("Navora")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
            
            Text("Manage your fleets")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
        }
        .padding(.top, 25)
        .padding(.bottom, 25)
    }
}

// MARK: - Login View

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBlue).opacity(0.1),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                LogoView()
                
                VStack(spacing: 16) {
                    TextField("Email ID", text: $viewModel.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))
                    
                    ZStack(alignment: .trailing) {
                        Group {
                            if viewModel.isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))
                        
                        Button(action: { viewModel.isPasswordVisible.toggle() }) {
                            Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button("Forgot password?") {
                            // Action for forgot password
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
                        .padding(.trailing, 4)
                    }
                }
                .padding(.bottom, 12)
                
                Button(action: viewModel.login) {
                    HStack {
                        Spacer()
                        Text("Log In")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 51/255, green: 102/255, blue: 204/255))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .padding(.top, 8)
                
                Button(action: viewModel.register) {
                    Text("Don't have an account? Sign Up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
                }
                .padding(.top, 12)
                
                Spacer()
                
                // Display user ID (for reference)
                if !viewModel.userId.isEmpty {
                    Text("User ID: \(viewModel.userId)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
    }
}

// MARK: - MFA Setup View

struct MFASetupView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LogoView()
                
                Text("Set Up Two-Factor Authentication")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("For additional security, we'll send you an email code when you sign in")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
                        Text("We'll send a verification code to your email")
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
                        Text("Enter the code to verify your identity")
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
                        Text("You'll need to do this each time you log in")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button(action: viewModel.setupEmailMFA) {
                    HStack {
                        Spacer()
                        Text("Enable Email Verification")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "envelope.shield.fill")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 51/255, green: 102/255, blue: 204/255))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .padding(.top, 24)
                
                // Display ID for reference
                if !viewModel.userId.isEmpty {
                    Text("User ID: \(viewModel.userId)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 24)
                }
            }
            .padding()
        }
    }
}

// MARK: - Email OTP Verification View

struct EmailOTPVerificationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedIndex: Int?
    
    var body: some View {
        VStack(spacing: 20) {
            LogoView()
            
            Text("Two-Factor Authentication")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please check your email and enter the 6-digit verification code")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitTextField(
                        text: $viewModel.otpDigits[index],
                        isFocused: focusedIndex == index
                    )
                    .focused($focusedIndex, equals: index)
                    .onChange(of: viewModel.otpDigits[index]) { newValue in
                        // Allow only one digit
                        if newValue.count > 1 {
                            viewModel.otpDigits[index] = String(newValue.suffix(1))
                        }
                        // Move to next field if current is filled
                        if !newValue.isEmpty && index < 5 {
                            focusedIndex = index + 1
                        }
                        // Move to previous field if current is empty
                        if newValue.isEmpty && index > 0 {
                            focusedIndex = index - 1
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            
            Button(action: viewModel.verifyChallenge) {
                HStack {
                    Spacer()
                    Text("Verify")
                        .font(.system(size: 18, weight: .semibold))
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
                .padding()
                .background(Color(red: 51/255, green: 102/255, blue: 204/255))
                .foregroundColor(.white)
                .cornerRadius(6)
            }
            .disabled(viewModel.otpDigits.joined().count < 6)
            .padding(.top, 8)
            
            Button(action: {
                viewModel.screen = .login
                viewModel.resetFields()
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back to Login")
                }
                .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
            }
            .padding(.top, 16)
            
            Spacer()
            
            // Display user ID
            if !viewModel.userId.isEmpty {
                Text("User ID: \(viewModel.userId)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }
        }
        .padding()
        .onAppear {
            focusedIndex = 0
        }
    }
}

// MARK: - OTP Digit TextField

struct OTPDigitTextField: View {
    @Binding var text: String
    var isFocused: Bool
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .frame(width: 44, height: 44)
            .background(Color.white)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isFocused ? Color.blue : Color.black.opacity(0.5), lineWidth: 2)
            )
            .font(.system(size: 20, weight: .bold))
    }
}

// MARK: - Home Screen Router

struct HomeScreenRouter: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        let _ = print("Current user role: \(viewModel.userRole.rawValue)")
        
        switch viewModel.userRole {
        case .driver:
//            DriverHomeScreen(viewModel: viewModel)
            TripAssignedView()
        case .fleetManager:
            MainTabView()
        case .maintenance:
            MaintenanceHomeScreen(viewModel: viewModel)
        case .unknown:
            UnknownRoleScreen(viewModel: viewModel)
        }
    }
}

// MARK: - Driver Home Screen

struct DriverHomeScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Driver Dashboard").font(.largeTitle).padding()
                Text("Welcome to the Driver Portal").font(.title2)
                
                Text("User ID: \(viewModel.userId)")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                
                Spacer()
                Button("Sign Out") {
                    viewModel.logout()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Driver Portal")
        }
    }
}

// MARK: - Fleet Manager Home Screen

struct FleetManagerHomeScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Fleet Manager Dashboard").font(.largeTitle).padding()
                Text("Welcome to the Fleet Management Portal").font(.title2)
                
                Text("User ID: \(viewModel.userId)")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                
                Spacer()
                Button("Sign Out") {
                    viewModel.logout()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Fleet Manager Portal")
        }
    }
}

// MARK: - Maintenance Home Screen

struct MaintenanceHomeScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Maintenance Dashboard").font(.largeTitle).padding()
                Text("Welcome to the Maintenance Portal").font(.title2)
                
                Text("User ID: \(viewModel.userId)")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                
                Spacer()
                Button("Sign Out") {
                    viewModel.logout()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Maintenance Portal")
        }
    }
}

// MARK: - Unknown Role Screen

struct UnknownRoleScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Role Not Assigned").font(.largeTitle).padding()
            Text("Your account doesn't have a role assigned yet. Please contact admin.")
                .multilineTextAlignment(.center)
                .padding()
            
            Text("User ID: \(viewModel.userId)")
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            
            Spacer()
            Button("Sign Out") {
                viewModel.logout()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
