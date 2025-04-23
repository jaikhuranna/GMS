//
//  Vehicle.swift
//  FleetManagement
//
//  Created by user@89 on 22/04/25.
//

import Foundation

struct Vehicle: Identifiable {
    let id = UUID()
    let vehicleNo: String
    let distanceTravelled: Int
    let carImage: String

    enum VehicleType {
        case HMV
        case LMV
    }
}


