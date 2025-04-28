//
//  NewDriverPass.swift
//  fleetManagementSystem
//
//  Created by Steve on 27/04/25.
//

import SwiftUI

struct DriverAddedSuccessViewScreen: View {
    @Environment(\.presentationMode) private var presentation

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Success message
                Text("Driver Added Successfully!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Circle with custom driver image
                ZStack {
                    Image("driver") // your custom image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }

                // Email + Password inside a clear box
                VStack(spacing: 0) {
                    HStack {
                        Text("Email")
                            .foregroundColor(Color(hex: "396BAF"))
                        Spacer()
                        Text("John@gmail.com")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.clear)

                    Divider()
                        .background(Color(hex: "396BAF"))

                    HStack {
                        Text("Password")
                            .foregroundColor(Color(hex: "396BAF"))
                        Spacer()
                        Text("XXXXX")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.clear)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "396BAF").opacity(0.5), lineWidth: 1)
                )
                .background(Color.clear)
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()

                // Done button
                Button {
                    presentation.wrappedValue.dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "396BAF"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Add New Driver")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground)) // Light gray outside
        }
    }
}

#Preview {
    NavigationStack {
        DriverAddedSuccessViewScreen()
    }
}
