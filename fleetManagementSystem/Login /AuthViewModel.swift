// AuthViewModel.swift
// fleetManagementSystem
//
// Created by Jai Khurana on 27/04/25.
//

import SwiftUI
import Appwrite
import FirebaseAuth
import FirebaseFirestore

enum AuthScreen {
    case login
    case setupMFA
    case verifyMFA
    case home
}

enum UserRole: String {
    case driver = "driver"
    case fleetManager = "fleet_manager"
    case maintenance = "maintenance"
    case unknown = "unknown"
}

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var screen: AuthScreen = .login
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var userRole: UserRole = .unknown
    @Published var otpDigits: [String] = Array(repeating: "", count: 6)
    @Published var appwriteUserId: String = ""
    @Published var firebaseUid: String = ""
    
    // MARK: - Private Properties
    private let appwrite = Appwrite()
    private var challengeId: String = ""
    
    // MARK: - Initialization
    
    init() {
        if let savedUserId = appwrite.getAppwriteUserId() {
            self.appwriteUserId = savedUserId
        }
        
        if let firebaseUid = appwrite.getFirebaseUid() {
            self.firebaseUid = firebaseUid
        }
        
        // Try to restore session
        Task {
            do {
                if Auth.auth().currentUser != nil && !appwriteUserId.isEmpty {
                    try await fetchUserRole()
                }
            } catch {
                print("No active session: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func register() {
        guard validateInputs() else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Register with Appwrite (which now handles Firebase registration too)
                let user = try await appwrite.onRegister(email, password)
                self.appwriteUserId = user.id
                
                if let firebaseUid = appwrite.getFirebaseUid() {
                    self.firebaseUid = firebaseUid
                }
                
                // Set default role and proceed to home or MFA setup
                userRole = .driver
                
                // Check if MFA needs to be set up
                let factors = try await appwrite.listMFAFactors()
                if factors.email == false {
                    // Email not set up as a factor, need to set up MFA
                    try await enableMFA()
                } else {
                    // MFA already set up, go to home
                    screen = .home
                }
                
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func login() {
        guard validateInputs() else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Login with Appwrite (which also handles Firebase login)
                let _ = try await appwrite.onLogin(email, password)
                
                // Update user IDs
                if let savedAppwriteId = appwrite.getAppwriteUserId() {
                    self.appwriteUserId = savedAppwriteId
                }
                
                if let savedFirebaseUid = appwrite.getFirebaseUid() {
                    self.firebaseUid = savedFirebaseUid
                }
                
                // Fetch role and go to home
                try await fetchUserRole()
                isLoading = false
            } catch let error as AppwriteError {
                // Handle MFA required errors
                print("Login error: \(String(describing: error.type)) - \(error.message)")
                
                if error.type == "user_mfa_required" ||
                   error.type == "user_more_factors_required" {
                    // Create MFA challenge for second factor
                    print("MFA required, creating challenge")
                    await createMFAChallenge()
                } else {
                    errorMessage = error.message
                    isLoading = false
                }
            } catch {
                errorMessage = "Login failed: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func createMFAChallenge() async {
        do {
            print("Creating email challenge")
            let challenge = try await appwrite.createEmailChallenge()
            print("Challenge created: \(challenge.id)")
            self.challengeId = challenge.id
            screen = .verifyMFA
            isLoading = false
        } catch {
            errorMessage = "Failed to create MFA challenge: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func logout() {
        isLoading = true
        
        Task {
            do {
                // Logout from both systems
                try await appwrite.onLogout()
                appwriteUserId = ""
                firebaseUid = ""
                resetFields()
                screen = .login
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    // MARK: - MFA Methods
    
    private func enableMFA() async throws {
        try await appwrite.updateMFA(enable: true)
        screen = .setupMFA
    }
    
    func setupEmailMFA() {
        isLoading = true
        
        Task {
            do {
                let challenge = try await appwrite.createEmailChallenge()
                challengeId = challenge.id
                screen = .verifyMFA
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func verifyChallenge() {
        let otp = otpDigits.joined()
        guard otp.count == 6 else {
            errorMessage = "Please enter all 6 digits"
            return
        }
        
        isLoading = true
        print("Verifying challenge: \(challengeId) with OTP: \(otp)")
        
        Task {
            do {
                // Verify OTP with Appwrite
                let _ = try await appwrite.verifyEmailChallenge(challengeId: challengeId, otp: otp)
                
                // Update user IDs if needed
                if let savedAppwriteId = appwrite.getAppwriteUserId(), appwriteUserId.isEmpty {
                    self.appwriteUserId = savedAppwriteId
                }
                
                if let savedFirebaseUid = appwrite.getFirebaseUid(), firebaseUid.isEmpty {
                    self.firebaseUid = savedFirebaseUid
                }
                
                // Fetch role and go to home
                try await fetchUserRole()
            } catch {
                print("Challenge verification failed: \(error)")
                errorMessage = "Verification failed: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    // MARK: - User Data Methods
    
    private func fetchUserRole() async throws {
        do {
            // Get role from Appwrite (which checks Firebase as fallback)
            let role = try await appwrite.getUserRole()
            
            // Convert string role to enum
            if let userRole = UserRole(rawValue: role) {
                self.userRole = userRole
            } else {
                self.userRole = .driver
            }
            
            screen = .home
            isLoading = false
        } catch {
            print("Error fetching user role: \(error)")
            userRole = .driver
            screen = .home
            isLoading = false
        }
    }
    
    // MARK: - Utility Methods
    
    private func validateInputs() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return false
        }
        
        return true
    }
    
    func resetFields() {
        email = ""
        password = ""
        otpDigits = Array(repeating: "", count: 6)
        errorMessage = ""
    }
}
