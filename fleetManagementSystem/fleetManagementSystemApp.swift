//
//  fleetManagementSystemApp.swift
//  fleetManagementSystem
//
//  Created by Jai Khurana on 18/04/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // let dbService = FleetDriverDBService()
        // dbService.uploadSampleFleetDrivers(sampleDrivers)

        return true

    }
}

func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if Auth.auth().canHandleNotification(notification) {
        completionHandler(.noData)
        return
    }
    completionHandler(.newData)
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if Auth.auth().canHandle(url) {
        return true
    }
    return false
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
