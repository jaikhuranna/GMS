// AuthViewModel.swift
// fleetManagementSystem
//
// Created by Jai Khurana on 27/04/25.
//

import SwiftUI
import Appwrite

enum AuthScreen {
    case loading // Add loading state
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
    @Published var screen: AuthScreen = .loading // Start with loading
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var userRole: UserRole = .unknown
    @Published var otpDigits: [String] = Array(repeating: "", count: 6)
    @Published var userId: String = ""
    @Published var debugRoleString: String = "No role fetched"
    
    // MARK: - Private Properties
    private let appwrite = Appwrite()
    private var challengeId: String = ""
    
    // MARK: - Initialization
    init() {
        if let savedUserId = appwrite.getUserId() {
            self.userId = savedUserId
            DispatchQueue.main.async {
                print("Found saved user ID: \(savedUserId)")
            }
        }
        
        // Try to restore session
        Task {
            do {
                // Attempt to get the current user (will throw if no valid session)
                let user = try await appwrite.getCurrentUser()
                self.userId = user.id
                
                DispatchQueue.main.async {
                    print("Session restored for user: \(user.id)")
                }
                
                // Fetch user role and navigate to home screen
                try await fetchUserRole()
            } catch {
                DispatchQueue.main.async {
                    print("No active session: \(error.localizedDescription)")
                    // No valid session, show login screen
                    self.screen = .login
                }
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
                // Register with Appwrite
                let user = try await appwrite.onRegister(email, password)
                self.userId = user.id
                
                // Check if MFA needs to be set up
                let factors = try await appwrite.listMFAFactors()
                if factors.email == false {
                    // Email not set up as a factor, need to set up MFA
                    try await enableMFA()
                } else {
                    // MFA already set up, go to home
                    userRole = .driver // Default role for new users
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
                // Login with Appwrite
                let _ = try await appwrite.onLogin(email, password)
                
                // Update user ID
                if let savedId = appwrite.getUserId() {
                    self.userId = savedId
                }
                
                // Fetch role and go to home
                try await fetchUserRole()
            } catch let error as AppwriteError {
                // Handle MFA required errors
                DispatchQueue.main.async {
                    print("Login error: \(String(describing: error.type)) - \(error.message)")
                }
                
                if error.type == "user_mfa_required" ||
                   error.type == "user_more_factors_required" {
                    // Create MFA challenge for second factor
                    DispatchQueue.main.async {
                        print("MFA required, creating challenge")
                    }
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
            DispatchQueue.main.async {
                print("Creating email challenge")
            }
            let challenge = try await appwrite.createEmailChallenge()
            DispatchQueue.main.async {
                print("Challenge created: \(challenge.id)")
            }
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
                // Logout from Appwrite
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
        DispatchQueue.main.async {
            print("Verifying challenge: \(self.challengeId) with OTP: \(otp)")
        }
        
        Task {
            do {
                // Verify OTP with Appwrite
                let _ = try await appwrite.verifyEmailChallenge(challengeId: challengeId, otp: otp)
                
                // Update user ID if needed
                if let savedId = appwrite.getUserId(), userId.isEmpty {
                    self.userId = savedId
                }
                
                // Fetch role and go to home
                try await fetchUserRole()
            } catch {
                DispatchQueue.main.async {
                    print("Challenge verification failed: \(error)")
                }
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
            
            // Get role from Appwrite
            let role = try await appwrite.getUserRole()
            DispatchQueue.main.async {
                print("Retrieved role string from database: \(role)")
                self.debugRoleString = "DB role: \(role)"
            }
            
            // Convert string role to enum
            if let userRole = UserRole(rawValue: role) {
                DispatchQueue.main.async {
                    print("Successfully converted to enum: \(userRole)")
                }
                self.userRole = userRole
            } else {
                DispatchQueue.main.async {
                    print("⚠️ Failed to convert role string to enum: \(role)")
                }
                self.userRole = .unknown
            }
            
            screen = .home
            isLoading = false
        } catch {
            DispatchQueue.main.async {
                print("❌ Error fetching user role: \(error)")
            }
            userRole = .unknown
            screen = .home
            isLoading = false
        }
    }
    
    // MARK: - Debugging
    
    func forceRoleRefresh() {
        Task {
            do {
                userRole = .unknown
                try await fetchUserRole()
            } catch {
                print("Role refresh failed: \(error)")
            }
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
