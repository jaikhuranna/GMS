//
//  EmergencyHelpView.swift
//  fleetManagementSystem
//
//  Created by user@61 on 06/05/25.
//


import SwiftUI

struct EmergencyHelpView: View {
    @Environment(\.openURL) private var openURL
  

    // Hard‑coded numbers for demo
    private let fleetManagerNumber = "‭8310541255‬"
    private let policeNumber       = "100"
    private let ambulanceNumber    = "102"
    private let hospitalNumber     = "102"
    private let maintenanceNumber  = "9354883198"

    var body: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 20)

            // Title
            Text("Emergency help needed?")
                .font(.title2).bold()

            Text("Just tap the button to call Fleet Manager")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Big Red SOS Button
            Button(action: { dial(fleetManagerNumber) }) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 160, height: 160)
                        .shadow(radius: 8)
                    Image(systemName: "phone.fill.arrow.up.right")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
            }

            // “Not sure what to do?” line
            Text("Not sure what to do?")
                .font(.headline)
            Text("Pick a subject below")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Cards grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    SOSCard(
                        title: "Police",
                        systemImage: "shield.lefthalf.fill",
                        number: policeNumber,
                        action: dial(_:))
                    SOSCard(
                        title: "Ambulance",
                        systemImage: "cross.case.fill",
                        number: ambulanceNumber,
                        action: dial(_:))
                }

                HStack(spacing: 16) {
                    SOSCard(
                        title: "Hospital",
                        systemImage: "building.2.fill",
                        number: hospitalNumber,
                        action: dial(_:))
                    SOSCard(
                        title: "Maintenance",
                        systemImage: "wrench.fill",
                        number: maintenanceNumber,
                        action: dial(_:))
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("SOS")
    }

    private func dial(_ number: String) {
        guard let url = URL(string: "tel://\(number)"),
              UIApplication.shared.canOpenURL(url)
        else { return }
        openURL(url)
    }
}

// A reusable button‑card
struct SOSCard: View {
    let title: String
    let systemImage: String
    let number: String
    let action: (String) -> Void

    var body: some View {
        Button(action: { action(number) }) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                                   .font(.system(size: 32))
                                   .foregroundColor(Color(hex: "396BAF"))
                Text(title)
                                   .font(.headline)
                                   .foregroundColor(Color(hex: "396BAF"))
                           }
            .frame(width: 140, height: 100)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

