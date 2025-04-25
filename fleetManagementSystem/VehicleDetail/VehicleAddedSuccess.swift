//
//  VehicleAddedSuccess.swift
//  Fleet_Management
//
//  Created by user@89 on 25/04/25.
//

import SwiftUI

struct VehicleAddedSuccessView: View {
    @Environment(\.presentationMode) var presentationMode

    var vehicleNumber: String = "MH 12 AB 1234" // Example Vehicle No
    var distanceTravelled: String = "1520 km"    // Example Distance Travelled

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Vehicle Added Successfully!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(Color(hex: "396BAF"))

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color(hex: "396BAF"))
            }
            
            VStack(spacing: 0) {
                infoRow(title: "Vehicle No.", value: vehicleNumber)
                Divider()
                infoRow(title: "Distance Travelled", value: distanceTravelled)
            }
            .background(Color.white)
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
                    .background(Color(hex: "396BAF"))
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .background(Color(red: 237/255, green: 242/255, blue: 252/255))
        .navigationBarBackButtonHidden(true)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(Color(hex: "396BAF"))
                .font(.body.bold())
            Spacer()
            Text(value)
                .foregroundColor(.gray)
                .font(.body)
        }
        .padding()
    }
}

struct VehicleAddedSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VehicleAddedSuccessView()
        }
    }
}
