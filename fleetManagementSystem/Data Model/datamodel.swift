// Awnish Ranjan
// 2025-04-21

import Foundation

struct Inspection: Codable {
    var id: String
    var driverId: String
    var vehicleId: String
    var timestamp: Date
    var isPreTrip: Bool
    var checklist: [String: Bool]
    var notes: String?
    var flaggedIssues: [String]?
}

struct EmergencyRequest: Codable {
    var id: String
    var driverId: String
    var vehicleId: String
    var issueDescription: String
    var timestamp: Date
    var inspectionId: String?
}

struct UserProfile: Codable {
    var name: String?
    var email: String?
    var role: String?
    var phone: String?

    init(from data: [String: Any]) throws {
        self.name = data["name"] as? String
        self.email = data["email"] as? String
        self.role = data["role"] as? String
        self.phone = data["phone"] as? String
    }
}
