import XCTest

// Mock Vehicle Inspection model for testing
class MockVehicleInspectionViewModel {
    // Inspection state
    var checklist: [String: Bool] = [
        "Oil Levels": false,
        "Brake": false,
        "Engine": false,
        "Exhaust System": false,
        "Transmission": false,
        "Tires & Wheels": false
    ]
    var notes: String = ""
    var vehicleId: String = ""
    var rideId: String = ""
    var isPreTrip: Bool = true
    var isSubmitting: Bool = false
    var showSuccess: Bool = false
    var showError: String?
    
    // Tracking method calls
    var submitInspectionCalled = false
    var raiseEmergencyCalled = false
    var fetchLatestInspectionCalled = false
    var emergencyDescription: String?
    
    // Track multiple validations
    var validationCalled = false
    var validationPassed = false
    
    func submitInspection() {
        submitInspectionCalled = true
        isSubmitting = true
        
        // Validate inputs before proceeding
        if validateInputs() {
            // Simulate success response
            isSubmitting = false
            showSuccess = true
        } else {
            isSubmitting = false
            showError = "Invalid input data"
        }
    }
    
    func submitInspectionWithError() {
        submitInspectionCalled = true
        isSubmitting = true
        
        // Simulate error response
        isSubmitting = false
        showError = "Mock error message"
    }
    
    func raiseEmergencyIfNeeded(description: String) {
        let majorIssues = ["Engine", "Brake"]
        let flaggedMajor = checklist.filter { !$0.value && majorIssues.contains($0.key) }
        
        if !flaggedMajor.isEmpty {
            raiseEmergencyCalled = true
            emergencyDescription = description
        }
    }
    
    func fetchLatestInspection() {
        fetchLatestInspectionCalled = true
    }
    
    // Validation logic for input data
    func validateInputs() -> Bool {
        validationCalled = true
        
        // Check for required fields
        guard !vehicleId.isEmpty, !rideId.isEmpty else {
            validationPassed = false
            return false
        }
        
        // Checklist should have at least one item checked
        let hasCheckedItem = checklist.values.contains(true)
        
        validationPassed = hasCheckedItem
        return hasCheckedItem
    }
    
    // Count major issues
    func countMajorIssues() -> Int {
        let majorIssues = ["Engine", "Brake"]
        return checklist.filter { !$0.value && majorIssues.contains($0.key) }.count
    }
    
    // Reset all checklist items to a specific state
    func resetChecklist(to value: Bool) {
        for key in checklist.keys {
            checklist[key] = value
        }
    }
}

final class FleetSystemTests: XCTestCase {
    var viewModel: MockVehicleInspectionViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = MockVehicleInspectionViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testSubmitInspection() {
        // Set up test data
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.isPreTrip = true
        viewModel.checklist["Oil Levels"] = true
        viewModel.checklist["Brake"] = false
        viewModel.notes = "Brake needs inspection."
        
        // Call method to test
        viewModel.submitInspection()
        
        // Verify the method was called
        XCTAssertTrue(viewModel.submitInspectionCalled, "submitInspection should be called")
        
        // Verify UI state updated correctly
        XCTAssertFalse(viewModel.isSubmitting, "isSubmitting should be false after completion")
        XCTAssertTrue(viewModel.showSuccess, "showSuccess should be true after successful submission")
        XCTAssertNil(viewModel.showError, "showError should be nil after successful submission")
    }
    
    func testSubmitInspectionFailure() {
        // Set up test data
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        
        // Call method to test with error simulation
        viewModel.submitInspectionWithError()
        
        // Verify the method was called
        XCTAssertTrue(viewModel.submitInspectionCalled, "submitInspection should be called")
        
        // Verify UI state updated correctly
        XCTAssertFalse(viewModel.isSubmitting, "isSubmitting should be false after completion")
        XCTAssertFalse(viewModel.showSuccess, "showSuccess should be false after failure")
        XCTAssertEqual(viewModel.showError, "Mock error message", "showError should contain the error message")
    }
    
    func testRaiseEmergencyWithMajorIssue() {
        // Set up test data with a major issue (Brake)
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.checklist["Brake"] = false
        
        // Call method to test
        viewModel.raiseEmergencyIfNeeded(description: "Brake issue detected")
        
        // Verify emergency was raised
        XCTAssertTrue(viewModel.raiseEmergencyCalled, "Emergency should be raised for Brake issue")
    }
    
    func testRaiseEmergencyWithoutMajorIssue() {
        // Set up test data without any major issues
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.checklist["Oil Levels"] = false
        viewModel.checklist["Brake"] = true   // Not flagged
        viewModel.checklist["Engine"] = true  // Not flagged
        
        // Call method to test
        viewModel.raiseEmergencyIfNeeded(description: "Minor issue detected")
        
        // Verify emergency was not raised
        XCTAssertFalse(viewModel.raiseEmergencyCalled, "Emergency should not be raised for non-major issues")
    }
    
    func testFetchLatestInspection() {
        // Set up test data
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        
        // Call method to test
        viewModel.fetchLatestInspection()
        
        // Verify the method was called
        XCTAssertTrue(viewModel.fetchLatestInspectionCalled, "fetchLatestInspection should be called")
    }
    
    // MARK: - Additional Test Cases
    
    func testSubmitInspectionWithEmptyVehicleId() {
        // Set up test data with empty vehicle ID
        viewModel.vehicleId = ""
        viewModel.rideId = "ride456"
        viewModel.checklist["Oil Levels"] = true
        
        // Call method to test
        viewModel.submitInspection()
        
        // Verify validation was called
        XCTAssertTrue(viewModel.validationCalled, "Validation should be called")
        XCTAssertFalse(viewModel.validationPassed, "Validation should fail with empty vehicleId")
        
        // Verify submission failed
        XCTAssertFalse(viewModel.showSuccess, "Submission should not succeed")
        XCTAssertEqual(viewModel.showError, "Invalid input data", "Error message should indicate invalid data")
    }
    
    func testSubmitInspectionWithEmptyRideId() {
        // Set up test data with empty ride ID
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = ""
        viewModel.checklist["Oil Levels"] = true
        
        // Call method to test
        viewModel.submitInspection()
        
        // Verify validation failed
        XCTAssertFalse(viewModel.validationPassed, "Validation should fail with empty rideId")
        
        // Verify submission failed
        XCTAssertFalse(viewModel.showSuccess, "Submission should not succeed")
        XCTAssertEqual(viewModel.showError, "Invalid input data", "Error message should indicate invalid data")
    }
    
    func testSubmitInspectionWithNoCheckedItems() {
        // Set up test data with no checked items
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.resetChecklist(to: false)
        
        // Call method to test
        viewModel.submitInspection()
        
        // Verify validation failed
        XCTAssertFalse(viewModel.validationPassed, "Validation should fail with no checked items")
        
        // Verify submission failed
        XCTAssertFalse(viewModel.showSuccess, "Submission should not succeed")
        XCTAssertEqual(viewModel.showError, "Invalid input data", "Error message should indicate invalid data")
    }
    
    func testSubmitInspectionWithAllItemsChecked() {
        // Set up test data with all items checked
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.resetChecklist(to: true)
        
        // Call method to test
        viewModel.submitInspection()
        
        // Verify validation passed
        XCTAssertTrue(viewModel.validationPassed, "Validation should pass with all items checked")
        
        // Verify submission succeeded
        XCTAssertTrue(viewModel.showSuccess, "Submission should succeed")
        XCTAssertNil(viewModel.showError, "No error should be shown")
    }
    
    func testRaiseEmergencyWithMultipleMajorIssues() {
        // Set up test data with multiple major issues
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.checklist["Brake"] = false
        viewModel.checklist["Engine"] = false
        
        // Call method to test
        viewModel.raiseEmergencyIfNeeded(description: "Multiple critical issues detected")
        
        // Verify emergency was raised
        XCTAssertTrue(viewModel.raiseEmergencyCalled, "Emergency should be raised for multiple major issues")
        
        // Verify the number of major issues
        XCTAssertEqual(viewModel.countMajorIssues(), 2, "Should detect 2 major issues")
        
        // Verify the emergency description
        XCTAssertEqual(viewModel.emergencyDescription, "Multiple critical issues detected", "Emergency description should be correct")
    }
    
    func testLongNotes() {
        // Set up test data with a very long notes string
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.checklist["Oil Levels"] = true
        
        // Create a 1000 character notes string
        let longNotes = String(repeating: "This is a test of a very long note. ", count: 25)
        viewModel.notes = longNotes
        
        // Call method to test
        viewModel.submitInspection()
        
        // Verify submission succeeded despite long notes
        XCTAssertTrue(viewModel.showSuccess, "Submission should succeed with long notes")
        XCTAssertNil(viewModel.showError, "No error should be shown")
    }
    
    func testEmptyNotes() {
        // Set up test data with empty notes
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.checklist["Oil Levels"] = true
        viewModel.notes = ""
        
        // Call method to test
        viewModel.submitInspection()
        
        // Verify submission succeeded with empty notes
        XCTAssertTrue(viewModel.showSuccess, "Submission should succeed with empty notes")
        XCTAssertNil(viewModel.showError, "No error should be shown")
    }
    
    func testTogglePreTrip() {
        // Test with pre-trip inspection
        viewModel.vehicleId = "vehicle123"
        viewModel.rideId = "ride456"
        viewModel.isPreTrip = true
        viewModel.checklist["Oil Levels"] = true
        
        // Submit pre-trip inspection
        viewModel.submitInspection()
        XCTAssertTrue(viewModel.showSuccess, "Pre-trip inspection submission should succeed")
        
        // Reset
        viewModel = MockVehicleInspectionViewModel()
        
        // Test with post-trip inspection
        viewModel.vehicleId = "vehicle123" 
        viewModel.rideId = "ride456"
        viewModel.isPreTrip = false
        viewModel.checklist["Oil Levels"] = true
        
        // Submit post-trip inspection
        viewModel.submitInspection()
        XCTAssertTrue(viewModel.showSuccess, "Post-trip inspection submission should succeed")
    }
} 