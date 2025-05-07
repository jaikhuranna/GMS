import Foundation
import MapKit
import CoreLocation

struct IdentifiablePointAnnotation: Identifiable {
    let id = UUID()
    var annotation: MKPointAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        annotation.coordinate
    }
}

struct StaticRouteStep {
    let coordinate: CLLocationCoordinate2D
    let instruction: String
    let distance: Double // Distance in meters to the next step
}

class NavigationViewModelDirections: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), // Zoomed to starting point in Bangalore
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.3) // Adjusted zoom level
    )
    @Published var annotations: [IdentifiablePointAnnotation] = []
    @Published var currentInstruction: String = "Starting navigation..."
    @Published var remainingDistance: String = "--"
    @Published var arrivalTime: String = "--:--"
    @Published var eta: String = "--"
    @Published var route: MKPolyline?
    @Published var showSOSAlert = false
    @Published var userHeading: Double = 0.0
    
    private let locationManager = CLLocationManager()
    private var staticSteps: [StaticRouteStep] = []
    private var currentStepIndex = 0
    private let destinationCoordinate = CLLocationCoordinate2D(latitude: 12.2300, longitude: 76.6558) // Mysore Airport
    private var timer: Timer?
    private var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946) // Starting in Bangalore
    private let totalDistance: Double = 130000 // Total distance in meters (130 km)
    private let totalTravelTime: Double = 7800 // Total travel time in seconds (130 minutes)
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        setupStaticRoute()
    }
    
    private func setupStaticRoute() {
        // Define static route waypoints and instructions
        staticSteps = [
            StaticRouteStep(
                coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
                instruction: "Head west on NH 275 towards Ramanagara",
                distance: 45000 // 45 km to Ramanagara
            ),
            StaticRouteStep(
                coordinate: CLLocationCoordinate2D(latitude: 12.7200, longitude: 77.2800),
                instruction: "Continue on NH 275 towards Mandya",
                distance: 55000 // 55 km to Mandya
            ),
            StaticRouteStep(
                coordinate: CLLocationCoordinate2D(latitude: 12.5200, longitude: 76.9000),
                instruction: "Turn right towards Mysore Airport",
                distance: 30000 // 30 km to Mysore Airport
            ),
            StaticRouteStep(
                coordinate: destinationCoordinate,
                instruction: "You have arrived at Mysore Airport",
                distance: 0 // Final destination
            )
        ]
        
        // Create MKPolyline for the route
        let coordinates = staticSteps.map { $0.coordinate }
        route = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        // Initialize annotations for the destination and route steps
        addRouteAnnotations()
        
        // Initialize navigation details
        updateETAAndDistance()
        updateCurrentInstruction()
        startNavigationUpdates()
    }
    
    func checkLocationAuthorization() {
        // Not needed for static data, but kept for compatibility
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location access denied")
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location authorized, but using static data")
        @unknown default:
            break
        }
    }
    
    func startHeadingUpdates() {
        // Not needed for static data, but kept for compatibility
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func triggerSOS() {
        showSOSAlert = true
    }
    
    private func updateETAAndDistance() {
        // Calculate remaining distance and ETA based on static data
        let remainingSteps = staticSteps[currentStepIndex...]
        let remainingDistanceMeters = remainingSteps.reduce(0) { $0 + $1.distance }
        let remainingDistanceKm = remainingDistanceMeters / 1000
        
        // Calculate remaining time based on proportion of distance
        let remainingTime = (remainingDistanceMeters / totalDistance) * totalTravelTime
        let remainingMinutes = Int(remainingTime / 60)
        
        eta = "\(remainingMinutes)"
        self.remainingDistance = remainingDistanceMeters > 1000 ?
            String(format: "%.1f km", remainingDistanceKm) :
            "\(Int(remainingDistanceMeters)) m"
        
        let arrivalDate = Date().addingTimeInterval(remainingTime)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        arrivalTime = formatter.string(from: arrivalDate)
    }
    
    private func startNavigationUpdates() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.simulateUserPosition()
        }
    }
    
    private func simulateUserPosition() {
        // Simulate moving to the next step
        if currentStepIndex < staticSteps.count - 1 {
            currentStepIndex += 1
            currentLocation = staticSteps[currentStepIndex].coordinate
            region.center = currentLocation
            updateCurrentInstruction()
            updateETAAndDistance()
            updateRouteAnnotations()
            
            // Check if arrived at destination
            if currentStepIndex == staticSteps.count - 1 {
                currentInstruction = "You have arrived at Mysore Airport"
                timer?.invalidate()
            }
        }
    }
    
    private func updateCurrentInstruction() {
        currentInstruction = staticSteps[currentStepIndex].instruction
    }
    
    private func addRouteAnnotations() {
        DispatchQueue.main.async {
            self.annotations.removeAll(keepingCapacity: true)
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = self.destinationCoordinate
            destinationAnnotation.title = "Mysore Airport"
            self.annotations.append(IdentifiablePointAnnotation(annotation: destinationAnnotation))
            
            for step in self.staticSteps {
                let roadName = self.extractRoadName(from: step.instruction) ?? "Unknown Road"
                let annotation = MKPointAnnotation()
                annotation.coordinate = step.coordinate
                annotation.title = roadName
                self.annotations.append(IdentifiablePointAnnotation(annotation: annotation))
            }
        }
    }
    
    private func updateRouteAnnotations() {
        DispatchQueue.main.async {
            self.annotations.removeAll(keepingCapacity: true)

            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = self.destinationCoordinate
            destinationAnnotation.title = "Mysore Airport"
            self.annotations.append(IdentifiablePointAnnotation(annotation: destinationAnnotation))

            for index in self.currentStepIndex..<self.staticSteps.count {
                let step = self.staticSteps[index]
                let roadName = self.extractRoadName(from: step.instruction) ?? "Unknown Road"
                let stepAnnotation = MKPointAnnotation()
                stepAnnotation.coordinate = step.coordinate
                stepAnnotation.title = roadName
                self.annotations.append(IdentifiablePointAnnotation(annotation: stepAnnotation))
            }
        }
    }

    private func extractRoadName(from instruction: String) -> String? {
        let patterns = [
            "on ([A-Za-z0-9 ]+)",
            "onto ([A-Za-z0-9 ]+)",
            "via ([A-Za-z0-9 ]+)",
            "towards ([A-Za-z0-9 ]+)"
        ]
        
        for pattern in patterns {
            if let range = instruction.range(of: pattern, options: .regularExpression) {
                let fullMatch = String(instruction[range])
                if let nameRange = fullMatch.range(of: #"(?<=on |onto |via |towards )\w+(?: \w+)*"#, options: .regularExpression) {
                    return String(instruction[nameRange])
                }
            }
        }
        return nil
    }
    
    // MARK: - Location Manager Delegate (Unused for static data)
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Not used for static data
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeading = newHeading.trueHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    deinit {
        timer?.invalidate()
        locationManager.stopUpdatingHeading()
    }
}
