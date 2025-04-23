//
//  fleetManagementSystemApp.swift
//  fleetManagementSystem
//
//  Created by Jai Khurana on 18/04/25.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct fleetManagementSystemApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
//            AuthRootView()
            InspectionbeforeRide()
//            MainTabView()
        }
    }
}
