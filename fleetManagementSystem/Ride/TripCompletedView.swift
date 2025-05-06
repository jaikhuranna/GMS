//
//  TripCompletedView.swift
//  fleetManagementSystem
//
//  Created by user@61 on 04/05/25.
//


import SwiftUI

struct TripCompletedCard: View {
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)

            Text("Trip Completed!")
                .font(.title2).bold()

            Text("Thanks for driving safely.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Done") {
                onDone()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .shadow(radius: 6)
    }
}

