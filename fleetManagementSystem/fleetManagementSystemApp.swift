//
//  fleetManagementSystemApp.swift
//  fleetManagementSystem
//
//  Created by Jai Khurana on 18/04/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore


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

@main
struct fleetManagementSystemApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthRootView()
//            InspectionbeforeRide()
//            MainTabView()
        }
    }
}
