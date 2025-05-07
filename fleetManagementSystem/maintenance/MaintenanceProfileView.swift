//
//  MaintenanceProfileView.swift
//  fleetManagementSystem
//
//  Created by Steve on 07/05/25.
//

import SwiftUI

struct MaintenanceProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showEditProfile = false
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
            // Static Blue Header
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(hex: "#396BAF"))
                        .frame(height: 150)
                        .edgesIgnoringSafeArea(.top)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.white)
                                    .padding()
                            }

                            Text("Maintenance Profile")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)

                            Spacer()

                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
                    }
                }

                Spacer()
                ZStack(alignment: .bottom) {
                     // This ensures it goes under the status bar

                    // Profile Image with edit button
                    ZStack(alignment: .bottomTrailing) {
                        Image("PP")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .offset(x: 0, y: 40)
                    }
                }
                .padding(.bottom, 45)

                // The rest of your content
                VStack(spacing: 24) {
                    // Name and Contact Info
                    VStack(spacing: 1) {
                        Text("Alex Johnson")
                            .font(.title)
                            .bold()
                            .foregroundColor(.primary)


                        HStack(spacing: 0) {
                            ContactInfoView(icon: "envelope.fill", text: "manager@fleet.com")
                        }
                        .padding(.top, 8)
                    }

                    Divider()
                        .padding(.horizontal)

                    // Performance Metrics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Performance Metrics")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)

                        HStack(spacing: 16) {
                            MaintenanceProfileStatCard(
                                title: "Tasks Completed",
                                value: "52",
                                icon: "checkmark.circle.fill",
                                color: Color.green
                            )

                            MaintenanceProfileStatCard(
                                title: "Pending Requests",
                                value: "8",
                                icon: "clock.fill",
                                color: Color.orange
                            )
                        }

                        HStack(spacing: 16) {
                            MaintenanceProfileStatCard(
                                title: "Vehicles Serviced",
                                value: "34",
                                icon: "car.fill",
                                color: Color.blue
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Sign Out Button
                    Button(action: {
                        viewModel.logout()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer()
                }
                .padding(.bottom)
                
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .edgesIgnoringSafeArea(.top)
        }
       // This ensures the header can extend to top edge
}
        


// Rest of your structs remain the same...
struct MaintenanceProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ContactInfoView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#396BAF"))
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = AuthViewModel()
        MaintenanceProfileView(viewModel: mockViewModel)
    }
}

