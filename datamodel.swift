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
