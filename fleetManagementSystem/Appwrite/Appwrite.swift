// Appwrite.swift
// fleetManagementSystem
//
// Created by Jai Khurana on 27/04/25.
//

import Foundation
import Appwrite
import JSONCodable
import AppwriteEnums

typealias AppwriteUser = AppwriteModels.User<[String: AnyCodable]>

class Appwrite {
    var client: Client
    var account: Account
    var databases: Databases
    
    // Store user ID for reference
    private let userIdKey = "com.navora.userId"
    
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
        // Create Appwrite user
        let user = try await account.create(
            userId: ID.unique(),
            email: email,
            password: password
        )
        
        // Save user ID
        saveUserId(user.id)
        
        // Create user profile with default role
        try await createUserProfile(
            userId: user.id,
            email: email,
            name: email.components(separatedBy: "@").first ?? "",
            role: "driver" // Default role
        )
        
        return user
    }
    
    public func onLogin(
        _ email: String,
        _ password: String
    ) async throws -> Session {
        // Login with Appwrite
        let session = try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
        
        // Get user ID and save it
        let user = try await account.get()
        saveUserId(user.id)
        
        return session
    }
    
    public func onLogout() async throws {
        // Logout from Appwrite
        _ = try await account.deleteSession(sessionId: "current")
        
        // Clear stored ID
        clearUserId()
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
        saveUserId(user.id)
        return user
    }
    public func createUserProfile(
        userId: String,
        email: String,
        name: String,
        role: String
    ) async throws -> Document<[String: AnyCodable]> {
        // Create document in Appwrite database
        return try await databases.createDocument(
            databaseId: "680e57380037ef7f5b77",
            collectionId: "680e57bb000cc438803d", // Correct collection ID
            documentId: userId, // Using Appwrite user ID as document ID
            data: [
                "email": email,
                "name": name,
                "role": role,
                "createdAt": Date().timeIntervalSince1970
            ]
        )
    }
    public func getUserDocument(userId: String) async throws -> Document<[String: AnyCodable]> {
        return try await databases.getDocument(
            databaseId: "680e57380037ef7f5b77",
            collectionId: "680e57bb000cc438803d", // Correct collection ID
            documentId: userId
        )
    }
    
    public func getUserRole() async throws -> String {
        guard let userId = getUserId() else {
            throw NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user ID available"])
        }
        
        do {
            // Get user document from Appwrite
            let document = try await getUserDocument(userId: userId)
            DispatchQueue.main.async {
                print("Document data: \(document.data)")
            }
            
            if let roleValue = document.data["role"],
               let role = roleValue.value as? String {
                return role
            }
            throw NSError(domain: "Auth", code: 2, userInfo: [NSLocalizedDescriptionKey: "Role not found in document"])
        } catch {
            DispatchQueue.main.async {
                print("❌ ACTUAL ERROR FETCHING ROLE: \(error)")
            }
            
            // Check for permission error (most likely issue)
            if let appwriteError = error as? AppwriteError,
               appwriteError.message.contains("missing scope") {
                DispatchQueue.main.async {
                    print("⚠️ Permission error - user doesn't have access to read their document")
                }
            }
            
            throw error  // Re-throw instead of returning "unknown"
        }
    }

    
    // MARK: - User ID Management
    
    private func saveUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }
    
    public func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: userIdKey)
    }
    
    private func clearUserId() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}
