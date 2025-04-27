// Appwrite.swift
// fleetManagementSystem
//
// Created by Jai Khurana on 27/04/25.
//

import Foundation
import Appwrite
import AppwriteEnums
import JSONCodable

class Appwrite {
    var client: Client
    var account: Account
    var databases: Databases
    
    // Store userId for later reference
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
    ) async throws -> User<[String: AnyCodable]> {
        let user = try await account.create(
            userId: ID.unique(),
            email: email,
            password: password
        )
        saveUserId(user.id)
        return user
    }
    
    public func onLogin(
        _ email: String,
        _ password: String
    ) async throws -> Session {
        let session = try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
        try await refreshUserIdFromSession()
        return session
    }
    
    public func onLogout() async throws {
        _ = try await account.deleteSession(
            sessionId: "current"
        )
        clearUserId()
    }
    
    // MARK: - MFA Methods
    
    public func updateMFA(enable: Bool) async throws {
        _ = try await account.updateMFA(
            mfa: enable
        )
    }
    
    public func listMFAFactors() async throws -> MfaFactors {
        return try await account.listMfaFactors()
    }
    
    public func createEmailChallenge() async throws -> MfaChallenge {
        return try await account.createMfaChallenge(
            factor: AuthenticationFactor.email  // Use the enum instead of string
        )
    }
    
    public func verifyEmailChallenge(
        challengeId: String,
        otp: String
    ) async throws -> Any {  // Change return type to Any
        // Return the result without forcing it to be a Session
        return try await account.updateMfaChallenge(
            challengeId: challengeId,
            otp: otp
        )
    }
    // MARK: - User Management
    
    public func getCurrentUser() async throws -> User<[String: AnyCodable]> {
        let user = try await account.get()
        saveUserId(user.id)
        return user
    }
    
    public func createUserProfile(
        userId: String,
        role: String
    ) async throws -> Document<[String: AnyCodable]> {
        return try await databases.createDocument(
            databaseId: "680e57380037ef7f5b77",
            collectionId: "users",
            documentId: userId,
            data: [
                "userId": userId,
                "role": role,
                "createdAt": Date().timeIntervalSince1970
            ]
        )
    }
    
    public func getUserRole(userId: String) async throws -> Document<[String: AnyCodable]> {
        return try await databases.getDocument(
            databaseId: "680e57380037ef7f5b77",
            collectionId: "users",
            documentId: userId
        )
    }
    
    // MARK: - User ID Management
    
    private func saveUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }
    
    public func getSavedUserId() -> String? {
        return UserDefaults.standard.string(forKey: userIdKey)
    }
    
    private func clearUserId() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
    
    private func refreshUserIdFromSession() async throws {
        let user = try await account.get()
        saveUserId(user.id)
    }
}
