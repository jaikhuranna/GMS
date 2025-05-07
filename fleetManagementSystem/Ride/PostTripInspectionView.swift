//
//  PostTripInspectionView.swift
//  fleetManagementSystem
//
//  Created by user@61 on 02/05/25.
//


// PostTripInspectionView.swift

import SwiftUI
import FirebaseFirestore
import Combine
import _MapKit_SwiftUI

struct PostTripInspectionView: View {
    let bookingRequestID: String
    let vehicleNumber:    String

    @State private var selectedItems = Set<String>()
    @Environment(\.presentationMode) var presentation
    private let db = Firestore.firestore()
    
    private func toggle(_ item: String) {
       if selectedItems.contains(item) {
         selectedItems.remove(item)
       } else {
         selectedItems.insert(item)
       }
     }
    private let items = [
        "Engine",
        "Tires & Wheels",
        "Oil Levels",
        "Brake",
        "Transmission",
        "Exhaust System"
      ]


    var body: some View {
        VStack(spacing: 0) {
            // — Header —
            HStack {
                Button {
                    presentation.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .padding()
                }
                Spacer()
                Text("Post-Trip Inspection")
                    .font(.title2).bold()
                Spacer()
                // balance space
                Color.clear.frame(width: 44, height: 44)
            }
            .background(Color.white)
            
            // — Checklist Grid —
            ScrollView {
                    // ② Build the columns array correctly
                    LazyVGrid(
                      columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                      ],
                      spacing: 20
                    ) {
                      ForEach(items, id: \.self) { item in
                        PostripInspectionViewcard(
                          icon: iconName(for: item),
                          title: item,
                          isSelected: selectedItems.contains(item)
                        ) {
                          // ③ Now toggle(_:) exists
                          toggle(item)
                        }
                      }
                    }
                    .padding()
                  }

                  Spacer()


            // — Save Button —
            Button {
             
                db.collection("postTripInspections")         // ← new collection name
                  .addDocument(data: [
                    "tripId":        bookingRequestID,
                    "vehicleNumber": vehicleNumber,
                    "checklist":     Array(selectedItems),
                    "completedAt":   Timestamp(date: Date())
                  ]) { error in
                    if let error = error {
                      print("Post-trip inspection save failed:", error.localizedDescription)
                    } else {
                      presentation.wrappedValue.dismiss()
                    }
                }
            } label: {
                Text("Finish Inspection")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedItems.count == 6 ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding()
            }
            .disabled(selectedItems.count < 6)
        }
        .navigationBarHidden(true)
    }

    private func iconName(for item: String) -> String {
        switch item {
        case "Engine":           return "car.fill"
        case "Tires & Wheels":   return "circle.grid.cross"
        case "Oil Levels":       return "drop.fill"
        case "Brake":            return "circle.dashed"
        case "Transmission":     return "gearshape"
        case "Exhaust System":   return "arrow.up.forward"
        default:                 return "checkmark"
        }
    }
}
struct PostripInspectionViewcard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var multiline: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: multiline ? 8 : 16) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.blue)
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 140, height: 140)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 1))
            .overlay(
                Group {
                    if isSelected {
                        ZStack(alignment: .topTrailing) {
                            Color.clear
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: -8, y: 8)
                        }
                    }
                }
            )
        }
    }
}

struct RouteCompleteView: View {
    let bookingRequestID: String
    let vehicleNumber:    String

    @State private var showFuelLog  = false
    @State private var showPostTrip = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Your live map (replace with your real region / annotations)
            Map(coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                 )
            )
            .ignoresSafeArea()

            // Bottom “Route Complete” sheet
            VStack(spacing: 16) {
                Text("Route Complete!")
                    .font(.title2).bold()
                    .foregroundColor(.white)

                HStack(spacing: 20) {
                    // 1) Fuel button
                    Button {
                        showFuelLog = true
                    } label: {
                        Label("Fuel", systemImage: "fuelpump")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }

                    // 2) Inspection button
                    Button {
                        showPostTrip = true
                    } label: {
                        Label("Begin Inspection", systemImage: "checkmark.shield")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(24, corners: [.topLeft, .topRight])
        }
        // FuelLogScreen sheet
        .sheet(isPresented: $showFuelLog) {
            FuelLogScreen(
                bookingRequestID: bookingRequestID,
                vehicleNumber:   vehicleNumber
            )
        }
        // Post-Trip checklist sheet
        .sheet(isPresented: $showPostTrip) {
            PostTripInspectionView(
                bookingRequestID: bookingRequestID,
                vehicleNumber:   vehicleNumber
            )
        }
    }
}
