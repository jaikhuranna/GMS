//
//  AuthViewModel.swift
//  fleetManagementSystem
//
//  Created by user@61 on 22/04/25.
//


//
//  AuthViewModel.swift
//  fleetManagementSystem
//
//  Created by Steve on 22/04/25.
//
//
//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//
//class AuthViewModel: ObservableObject {
//    @Published var errorMessage: String?
//    @Published var isLoading: Bool = false
//    @Published var isAuthenticated: Bool = false
//    @Published var currentUser: User?
//
//    private let auth = Auth.auth()
//    private let db = Firestore.firestore()
//
//    func signInWithEmail(email: String, password: String, completion: @escaping (Bool) -> Void) {
//        isLoading = true
//        errorMessage = nil
//
//        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//
//                if let error = error {
//                    self?.errorMessage = error.localizedDescription
//                    completion(false)
//                    return
//                }
//
//                self?.currentUser = authResult?.user
//                self?.isAuthenticated = true
//
//                if let uid = authResult?.user.uid {
//                    self?.fetchUserData(uid: uid)
//                }
//
//                completion(true)
//            }
//        }
//    }
//
//    private func fetchUserData(uid: String) {
//        db.collection("users").document(uid).getDocument { document, error in
//            if let document = document, document.exists {
//                print("User data retrieved: \(document.data() ?? [:])")
//            } else {
//                print("No user data found in Firestore")
//            }
//        }
//    }
//
//    func signOut() {
//        do {
//            try auth.signOut()
//            isAuthenticated = false
//            currentUser = nil
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//    }
//
//    func checkAuthStatus() {
//        if let user = auth.currentUser {
//            currentUser = user
//            isAuthenticated = true
//            fetchUserData(uid: user.uid)
//        }
//    }
//}
//
//

//
//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//
//class AuthViewModel: ObservableObject {
//    @Published var errorMessage: String?
//    @Published var isLoading: Bool = false
//    @Published var isAuthenticated: Bool = false
//    @Published var currentUser: User?
//    @Published var userProfile: UserProfile?
//
//    private let auth = Auth.auth()
//    private let db = Firestore.firestore()
//
//    // MARK: - Sign in
//    func signInWithEmail(email: String, password: String, completion: @escaping (Bool) -> Void) {
//        isLoading = true
//        errorMessage = nil
//
//        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                self.isLoading = false
//
//                if let error = error {
//                    self.errorMessage = error.localizedDescription
//                    print("❌ Sign-in error: \(error.localizedDescription)")
//                    completion(false)
//                    return
//                }
//
//                guard let user = authResult?.user else {
//                    self.errorMessage = "Failed to retrieve user."
//                    completion(false)
//                    return
//                }
//
//                self.currentUser = user
//                self.isAuthenticated = true
//                print("✅ User signed in: \(user.email ?? user.uid)")
//
//                self.fetchUserData(uid: user.uid)
//                completion(true)
//            }
//        }
//    }
//
//    // MARK: - Fetch user data from Firestore
//    private func fetchUserData(uid: String) {
//        db.collection("users").document(uid).getDocument { [weak self] document, error in
//            if let error = error {
//                print("⚠️ Error fetching user data: \(error.localizedDescription)")
//                return
//            }
//
//            guard let document = document, document.exists, let data = document.data() else {
//                print("⚠️ No user document found")
//                return
//            }
//
//            self?.userProfile = try? UserProfile(from: data)
//            print("📄 User data: \(data)")
//        }
//    }
//
//    // MARK: - Sign out
//    func signOut() {
//        do {
//            try auth.signOut()
//            self.isAuthenticated = false
//            self.currentUser = nil
//            self.userProfile = nil
//            print("👋 Signed out successfully.")
//        } catch {
//            self.errorMessage = error.localizedDescription
//            print("❌ Sign-out error: \(error.localizedDescription)")
//        }
//    }
//
//    // MARK: - Check auth on launch
//    func checkAuthStatus() {
//        if let user = auth.currentUser {
//            self.currentUser = user
//            self.isAuthenticated = true
//            fetchUserData(uid: user.uid)
//            print("🔁 User session active: \(user.email ?? user.uid)")
//        } else {
//            self.isAuthenticated = false
//            print("🔒 No active session")
//        }
//    }
//
//    // MARK: - Optional: reload user profile
//    func reloadUser() {
//        auth.currentUser?.reload(completion: { [weak self] error in
//            if let error = error {
//                self?.errorMessage = error.localizedDescription
//                print("🔄 Reload error: \(error.localizedDescription)")
//            } else {
//                self?.checkAuthStatus()
//            }
//        })
//    }
//}

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    
    // For two-factor auth
    @Published var emailVerified: Bool = false
    @Published var phoneVerified: Bool = false
    
    // For phone auth
    @Published var verificationID: String?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    // MARK: - Sign in with email/password
    func signInWithEmail(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("❌ Sign-in error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let user = authResult?.user else {
                    self.errorMessage = "Failed to retrieve user."
                    completion(false)
                    return
                }

                self.currentUser = user
                self.emailVerified = true
                // Not setting isAuthenticated to true yet, waiting for phone verification
                print("✅ Email verification complete: \(user.email ?? user.uid)")

                self.fetchUserData(uid: user.uid)
                completion(true)
            }
        }
    }

    func sendOTP(to phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, completion: { verificationID, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error sending OTP: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                    return
                }

                guard let verificationID = verificationID else {
                    print("❗️Verification ID unexpectedly nil")
                    completion(false, "Verification ID is nil")
                    return
                }

                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                print("📲 OTP sent. Verification ID: \(verificationID)")
                completion(true, nil)
            }
        })

    }


    // MARK: - Verify OTP
    func verifyOTP(code: String, completion: @escaping (Bool, String?) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            completion(false, "Missing verification ID")
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Error verifying OTP: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }

            // Successfully signed in
            completion(true, nil)
        }
    }

    
    // MARK: - Complete authentication after both steps
    func completeAuthentication() {
        if emailVerified && phoneVerified {
            isAuthenticated = true
            print("🔐 User fully authenticated")
            
            // If we authenticated with phone but don't have user data yet
            if let uid = currentUser?.uid {
                fetchUserData(uid: uid)
            }
        }
    }

    // MARK: - Fetch user data from Firestore
    private func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            if let error = error {
                print("⚠️ Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("⚠️ No user document found")
                return
            }

            self?.userProfile = try? UserProfile(from: data)
            print("📄 User data: \(data)")
        }
    }

    // MARK: - Sign out
    func signOut() {
        do {
            try auth.signOut()
            self.isAuthenticated = false
            self.emailVerified = false
            self.phoneVerified = false
            self.currentUser = nil
            self.userProfile = nil
            print("👋 Signed out successfully.")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Sign-out error: \(error.localizedDescription)")
        }
    }

    // MARK: - Check auth on launch
    func checkAuthStatus() {
        if let user = auth.currentUser {
            self.currentUser = user
            
            // If returning from app restart, assume full authentication
            self.emailVerified = true
            self.phoneVerified = true
            self.isAuthenticated = true
            
            fetchUserData(uid: user.uid)
            print("🔁 User session active: \(user.email ?? user.uid)")
        } else {
            self.isAuthenticated = false
            self.emailVerified = false
            self.phoneVerified = false
            print("🔒 No active session")
        }
    }

    // MARK: - Optional: reload user profile
    func reloadUser() {
        auth.currentUser?.reload(completion: { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("🔄 Reload error: \(error.localizedDescription)")
            } else {
                self?.checkAuthStatus()
            }
        })
    }
    
    // MARK: - For testing only
    let testVerificationCode = "123456"
}
