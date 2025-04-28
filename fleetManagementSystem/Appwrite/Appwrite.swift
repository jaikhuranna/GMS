// Appwrite.swift
// fleetManagementSystem
//
// Created by Jai Khurana on 27/04/25.
//

import Foundation
import Appwrite
import JSONCodable
import FirebaseAuth
import AppwriteEnums
import FirebaseFirestore

typealias AppwriteUser = AppwriteModels.User<[String: AnyCodable]>

class Appwrite {
    var client: Client
    var account: Account
    var databases: Databases
    
    // Store user IDs for reference
    private let appwriteUserIdKey = "com.navora.appwriteUserId"
    private let firebaseUidKey = "com.navora.firebaseUid"
    
    // Firebase references
    private let firestore = Firestore.firestore()
    
    public init() {
        self.client = Client()
            .setEndpoint("https://fra.cloud.appwrite.io/v1")
            .setProject("680c6adc000852dfc5d0")
        
        self.account = Account(client)
        self.databases = Databases(client)
    }
    
    // MARK: - Authentication Methods
    
    public func onRegister(
        _ email: String,
        _ password: String
    ) async throws -> AppwriteUser {
        // First register with Firebase to get the UID
        let firebaseUser = try await createFirebaseUser(email: email, password: password)
        let firebaseUid = firebaseUser.uid
        
        // Save Firebase UID
        
        saveFirebaseUid(firebaseUid)
        
        // Then create Appwrite user with same credentials
        let appwriteUser = try await account.create(
            userId: ID.unique(), // Generate Appwrite ID
            email: email,
            password: password
        )
        
        // Save Appwrite user ID
        saveAppwriteUserId(appwriteUser.id)
        
        // Create user document in Appwrite database using Firebase UID as document ID
        try await createUserProfile(
            firebaseUid: firebaseUid,
            appwriteUserId: appwriteUser.id,
            email: email,
            name: firebaseUser.displayName ?? "",
            role: "driver" // Default role
        )
        
        return appwriteUser
    }
    
    public func onLogin(
        _ email: String,
        _ password: String
    ) async throws -> Session {
        // First authenticate with Firebase
        let firebaseUser = try await signInWithFirebase(email: email, password: password)
        saveFirebaseUid(firebaseUser.uid)
        
        // Then authenticate with Appwrite (which handles MFA)
        let session = try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
        
        // Get Appwrite user ID and save it
        let appwriteUser = try await account.get()
        saveAppwriteUserId(appwriteUser.id)
        
        // Check if mapping exists, create if it doesn't
        do {
            _ = try await getUserDocument(firebaseUid: firebaseUser.uid)
        } catch {
            // If document doesn't exist, create mapping
            try await createUserProfile(
                firebaseUid: firebaseUser.uid,
                appwriteUserId: appwriteUser.id,
                email: email,
                name: firebaseUser.displayName ?? "",
                role: await fetchRoleFromFirebase(uid: firebaseUser.uid)
                
            )
        }
        
        return session
    }
    
    public func onLogout() async throws {
        // Logout from Appwrite
        _ = try await account.deleteSession(sessionId: "current")
        
        // Logout from Firebase
        try await Auth.auth().signOut()
        
        // Clear stored IDs
        clearAppwriteUserId()
        clearFirebaseUid()
    }
    
    // MARK: - MFA Methods
    
    public func updateMFA(enable: Bool) async throws {
        _ = try await account.updateMFA(mfa: enable)
    }
    
    public func listMFAFactors() async throws -> MfaFactors {
        return try await account.listMfaFactors()
    }
    
    public func createEmailChallenge() async throws -> MfaChallenge {
        return try await account.createMfaChallenge(factor: AuthenticationFactor.email)
    }
    
    public func verifyEmailChallenge(
        challengeId: String,
        otp: String
    ) async throws -> Any {
        return try await account.updateMfaChallenge(
            challengeId: challengeId,
            otp: otp
        )
    }
    
    // MARK: - User Management
    
    public func getCurrentUser() async throws -> AppwriteUser {
        let user = try await account.get()
        saveAppwriteUserId(user.id)
        return user
    }
    
    public func createUserProfile(
        firebaseUid: String,
        appwriteUserId: String,
        email: String,
        name: String,
        role: String
    ) async throws -> Document<[String: AnyCodable]> {
        // Create document in Appwrite using Firebase UID as the document ID
        return try await databases.createDocument(
            databaseId: "680e57380037ef7f5b77",
            collectionId: "users",
            documentId: firebaseUid, // Using Firebase UID as the document ID
            data: [
                "appwriteUserId": appwriteUserId,
                "email": email,
                "name": name,
                "role": role,
                "createdAt": Date().timeIntervalSince1970
            ]
        )
    }
    
    public func getUserDocument(firebaseUid: String) async throws -> Document<[String: AnyCodable]> {
        return try await databases.getDocument(
            databaseId: "680e57380037ef7f5b77",
            collectionId: "users",
            documentId: firebaseUid
        )
    }
    
    public func getUserRole() async throws -> String {
        guard let firebaseUid = getFirebaseUid() else {
            throw NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Firebase UID available"])
        }
        
        do {
            // First try to get from Appwrite
            let document = try await getUserDocument(firebaseUid: firebaseUid)
            if let roleValue = document.data["role"],
               let role = roleValue.value as? String {
                return role
            }
            throw NSError(domain: "Auth", code: 2, userInfo: [NSLocalizedDescriptionKey: "Role not found in document"])
        } catch {
            // If not found in Appwrite or role missing, try Firebase
            return try await fetchRoleFromFirebase(uid: firebaseUid)
        }
    }
    
    // MARK: - Firebase Integration
    
    private func createFirebaseUser(email: String, password: String) async throws -> FirebaseAuth.User {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = result?.user {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create Firebase user"]))
                }
            }
        }
    }
    
    private func signInWithFirebase(email: String, password: String) async throws -> FirebaseAuth.User {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = result?.user {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: NSError(domain: "Auth", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to sign in with Firebase"]))
                }
            }
        }
    }
    
    private func fetchRoleFromFirebase(uid: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            firestore.collection("users").document(uid).getDocument { document, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let document = document, document.exists,
                          let role = document.data()?["role"] as? String {
                    continuation.resume(returning: role)
                } else {
                    continuation.resume(returning: "driver") // Default role
                }
            }
        }
    }
    
    // MARK: - User ID Management
    
    private func saveAppwriteUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: appwriteUserIdKey)
    }
    
    public func getAppwriteUserId() -> String? {
        return UserDefaults.standard.string(forKey: appwriteUserIdKey)
    }
    
    private func clearAppwriteUserId() {
        UserDefaults.standard.removeObject(forKey: appwriteUserIdKey)
    }
    
    private func saveFirebaseUid(_ uid: String) {
        UserDefaults.standard.set(uid, forKey: firebaseUidKey)
    }
    
    public func getFirebaseUid() -> String? {
        return UserDefaults.standard.string(forKey: firebaseUidKey)
    }
    
    private func clearFirebaseUid() {
        UserDefaults.standard.removeObject(forKey: firebaseUidKey)
    }
}
