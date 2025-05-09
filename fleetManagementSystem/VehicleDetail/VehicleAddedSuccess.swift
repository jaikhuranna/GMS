//
//  VehicleAddedSuccess.swift
//  Fleet_Management
//
//  Created by user@89 on 25/04/25.
//

import SwiftUI

struct VehicleAddedSuccessView: View {
    @Environment(\.presentationMode) var presentationMode

    var vehicleNumber: String
    var distanceTravelled: String
    
    
    
    init(vehicleNumber: String, distanceTravelled: String) {
        self.vehicleNumber = vehicleNumber
        self.distanceTravelled = distanceTravelled
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Vehicle Added Successfully!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(Color.accentColor)

            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color.accentColor)
            }

            VStack(spacing: 0) {
                infoRow(title: "Vehicle No.", value: vehicleNumber)
                Divider()
                infoRow(title: "Distance Travelled", value: distanceTravelled)
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

            Spacer()

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGray6))
        .navigationBarBackButtonHidden(true)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
                .font(.body.bold())
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.body)
        }
        .padding()
    }
}

struct VehicleAddedSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VehicleAddedSuccessView(vehicleNumber: "MH 12 AB 1234", distanceTravelled: "1520 km")
        }
    }
}
