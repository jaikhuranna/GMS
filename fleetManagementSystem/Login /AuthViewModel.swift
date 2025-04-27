// AuthViewModel.swift
// fleetManagementSystem
//
// Created by Jai Khurana on 27/04/25.
//

import SwiftUI
import Appwrite

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
    @Published var userId: String = ""
    
    // MARK: - Private Properties
    private let appwrite = Appwrite()
    private var challengeId: String = ""
    
    // MARK: - Initialization
    
    init() {
        if let savedUserId = appwrite.getSavedUserId() {
            self.userId = savedUserId
        }
        
        // Try to restore session
        Task {
            do {
                let user = try await appwrite.getCurrentUser()
                self.userId = user.id
                try await fetchUserRole()
            } catch {
                // No active session, stay on login screen
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
                let user = try await appwrite.onRegister(email, password)
                self.userId = user.id
                try await appwrite.createUserProfile(userId: user.id, role: UserRole.driver.rawValue)
                try await login()
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
                // Try to login with email/password
                let _ = try await appwrite.onLogin(email, password)
                
                // If successful, get the userId and user role
                if let savedId = appwrite.getSavedUserId() {
                    self.userId = savedId
                }
                
                try await fetchUserRole()
            } catch let error as AppwriteError {
                // Critical fix: Handle all MFA required errors
                print("Login error: \(String(describing: error.type)) - \(error.message)")
                
                if error.type == "user_mfa_required" ||
                   error.type == "user_more_factors_required" {
                    // This is expected behavior when MFA is required
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
                try await appwrite.onLogout()
                userId = ""
                resetFields()
                screen = .login
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    // MARK: - MFA Methods
    
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
                // Don't try to cast the result - just use it to confirm verification
                let _ = try await appwrite.verifyEmailChallenge(challengeId: challengeId, otp: otp)
                
                // After successful verification, get the current user
                try await appwrite.getCurrentUser()
                
                if let savedId = appwrite.getSavedUserId() {
                    self.userId = savedId
                }
                
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
            // Make sure we have a userId
            if userId.isEmpty {
                let user = try await appwrite.getCurrentUser()
                userId = user.id
            }
            
            // Get the user's role
            let document = try await appwrite.getUserRole(userId: userId)
            
            if let roleString = document.data["role"] as? String,
               let role = UserRole(rawValue: roleString) {
                userRole = role
            } else {
                userRole = .driver
            }
            
            screen = .home
            isLoading = false
        } catch {
            print("Error fetching user role: \(error)")
            // Create user profile if it doesn't exist
            try await createUserProfile()
        }
    }
    
    private func createUserProfile() async throws {
        do {
            let user = try await appwrite.getCurrentUser()
            userId = user.id
            try await appwrite.createUserProfile(userId: user.id, role: UserRole.driver.rawValue)
            userRole = .driver
            screen = .home
            isLoading = false
        } catch {
            throw error
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
