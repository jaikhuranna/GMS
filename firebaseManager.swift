// Awnish Ranjan
// 2025-04-21

import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

final class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func submitInspection(
        vehicleId: String,
        isPreTrip: Bool,
        checklist: [String: Bool],
        notes: String?,
        flaggedIssues: [String]?,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        let inspectionRef = db
            .collection("vehicles")
            .document(vehicleId)
            .collection("inspections")
            .document()

        let inspection = Inspection(
            id: inspectionRef.documentID,
            driverId: userId,
            vehicleId: vehicleId,
            timestamp: Date(),
            isPreTrip: isPreTrip,
            checklist: checklist,
            notes: notes,
            flaggedIssues: flaggedIssues
        )

        do {
            try inspectionRef.setData(from: inspection) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(inspectionRef.documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func raiseEmergency(
        vehicleId: String,
        issueDescription: String,
        inspectionId: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        let emergencyRef = db.collection("emergencyRequests").document()

        let request = EmergencyRequest(
            id: emergencyRef.documentID,
            driverId: userId,
            vehicleId: vehicleId,
            issueDescription: issueDescription,
            timestamp: Date(),
            inspectionId: inspectionId
        )

        do {
            try emergencyRef.setData(from: request) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
