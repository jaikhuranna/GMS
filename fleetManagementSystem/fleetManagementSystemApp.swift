//
//  fleetManagementSystemApp.swift
//  fleetManagementSystem
//
//  Created by Jai Khurana on 18/04/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // In your AppDelegate.swift or where you initialize Firebase
        
        
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings(garbageCollectorSettings: MemoryLRUGCSettings())
        Firestore.firestore().settings = settings
        
        // let dbService = FleetDriverDBService()
        // dbService.uploadSampleFleetDrivers(sampleDrivers)
        
        return true
        
    }
}

struct ApplicationSwitcher: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        switch viewModel.screen {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .login, .setupMFA, .verifyMFA:
            AuthRootView()
        case .home:
            HomeScreenRouter(viewModel: viewModel)
        }
    }
}

@main
struct fleetManagementSystemApp: App {
    @StateObject private var authVM = AuthViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var geofence = GeofenceManager.shared
    
    var body: some Scene {
        WindowGroup {
            ApplicationSwitcher().environmentObject(authVM).sheet(isPresented: $geofence.didEnterRegion) {
                    // wrap in a NavigationStack if you want a nav‐bar hidden
                    NavigationStack {
                        InspectionbeforeRide(
                            bookingRequestID: geofence.bookingRequestID!,
                            vehicleNumber:    geofence.vehicleNumber!,
                            phase:             .post,
                            driverId: Auth.auth().currentUser?.uid ?? "", viewModel: authVM
                            // ← use .post here
                            // vehicleOdometerKm: geofence.odometerKm  // if you still need to supply it
                        )
                        .navigationBarHidden(true)
                    }
                }
        }
    }
}
