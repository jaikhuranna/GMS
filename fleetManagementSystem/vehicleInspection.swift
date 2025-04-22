//Awnish Ranjan
//2025-04-21

import Foundation

class VehicleInspectionViewModel: ObservableObject {
    @Published var checklist: [String: Bool] = [
        "Oil Levels": false,
        "Brake": false,
        "Engine": false,
        "Exhaust System": false,
        "Transmission": false,
        "Tires & Wheels": false
    ]
    @Published var notes: String = ""
    @Published var vehicleId: String = ""
    @Published var isPreTrip: Bool = true
    @Published var isSubmitting: Bool = false
    @Published var showSuccess: Bool = false
    @Published var showError: String?

    func submitInspection() {
        isSubmitting = true
        showError = nil
        showSuccess = false

        let flaggedIssues = checklist.filter { !$0.value }.map { $0.key }

        FirebaseManager.shared.submitInspection(
            vehicleId: vehicleId,
            isPreTrip: isPreTrip,
            checklist: checklist,
            notes: notes,
            flaggedIssues: flaggedIssues
        ) { result in
            DispatchQueue.main.async {
                self.isSubmitting = false
                switch result {
                case .success:
                    self.showSuccess = true
                case .failure(let error):
                    self.showError = error.localizedDescription
                }
            }
        }
    }

    func raiseEmergencyIfNeeded(description: String) {
        let majorIssues = ["Engine", "Brake"]
        let flaggedMajor = checklist.filter { !$0.value && majorIssues.contains($0.key) }

        guard !flaggedMajor.isEmpty else { return }

        FirebaseManager.shared.raiseEmergency(
            vehicleId: vehicleId,
            issueDescription: description
        ) { result in
            switch result {
            case .success():
                print("Emergency Raised")
            case .failure(let error):
                print("Failed to raise emergency: \(error.localizedDescription)")
            }
        }
    }
}
