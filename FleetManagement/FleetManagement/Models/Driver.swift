//
//  Driver.swift
//  FleetManagement
//
//  Created by user@89 on 22/04/25.
//

import Foundation

struct Driver: Identifiable {
    let id = UUID()
    let driverName: String
    let driverExperience: Int
    let driverImage: String

    enum DriverType {
        case HMV
        case LMV
    }
}

