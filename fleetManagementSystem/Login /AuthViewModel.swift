//
//  AuthViewModel.swift
//  fleetManagementSystem
//
//  Created by Steve on 22/04/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func signInWithEmail(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }

                self?.currentUser = authResult?.user
                self?.isAuthenticated = true

                if let uid = authResult?.user.uid {
                    self?.fetchUserData(uid: uid)
                }

                completion(true)
            }
        }
    }

    private func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                print("User data retrieved: \(document.data() ?? [:])")
            } else {
                print("No user data found in Firestore")
            }
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func checkAuthStatus() {
        if let user = auth.currentUser {
            currentUser = user
            isAuthenticated = true
            fetchUserData(uid: user.uid)
        }
    }
}

