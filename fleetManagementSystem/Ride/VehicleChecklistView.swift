


import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

struct VehicleChecklistView: View {
    let vehicleNumber:    String
    let bookingRequestID: String
    let phase:            InspectionPhase
    let driverId: String

    private let db = Firestore.firestore()

    @State private var navigateToMap   = false
    @State private var selectedItems   = Set<String>()
    @State private var showCompleted = false
    @Environment(\.presentationMode) var presentationMode

    private let items = [
        "Engine",
        "Tires & Wheels",
        "Oil Levels",
        "Brake",
        "Transmission",
        "Exhaust System"
    ]


        var body: some View {
            ZStack(alignment: .bottom) {
                // ── Main Checklist UI ──
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.trailing, 16)
                        }
                        Spacer()
                        Text(phase == .pre ? "Pre-Trip Checklist" : "Post-Trip Checklist")
                            .font(.system(size: 24, weight: .semibold))
                        Spacer()
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding()
                    .background(Color.white)

                    // Truck image & number
                    VStack(spacing: 8) {
                        Image("Truck")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                        Text(vehicleNumber)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.vertical)

                    // Checklist grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(items, id: \.self) { item in
                            ChecklistButton(
                                icon: iconName(for: item),
                                title: item,
                                isSelected: selectedItems.contains(item)
                            ) {
                                toggleSelection(item)
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    // Save / Continue button
                    Button {
                        let data: [String:Any] = [
                            "tripId":        bookingRequestID,
                            "vehicleNumber": vehicleNumber,
                            "checklist":     Array(selectedItems),
                            "timestamp":     Timestamp(date: Date())
                        ]
                        db.collection(phase.collectionName)
                          .addDocument(data: data) { error in
                            if let error = error {
                                print("Firestore save error:", error.localizedDescription)
                            } else {
                                if phase == .pre {
                                    navigateToMap = true
                                } else {
                                    showCompleted = true
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: selectedItems.count == items.count
                                  ? "checkmark.seal.fill"
                                  : "wrench.and.screwdriver")
                                .foregroundColor(.white)
                            Text(selectedItems.count == items.count
                                 ? (phase == .pre ? "Vehicle Ready!" : "All Good!")
                                 : "Report Maintenance Issue!")
                                .foregroundColor(.white)
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            selectedItems.count == items.count
                            ? Color(red: 63/255, green: 98/255, blue: 163/255)
                            : Color.red.opacity(0.85)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .disabled(selectedItems.count != items.count)
                    .padding(.bottom)

                    // Hidden nav back to map (pre‑trip)
                    NavigationLink(
                        destination: NavigationMapView(
                            driverId: driverId  ,
                            bookingRequestID: bookingRequestID,
                            vehicleNumber:   vehicleNumber
                        ),
                        isActive: $navigateToMap
                    ) {
                        EmptyView()
                    }
                    .hidden()

                    // Home indicator
                    Rectangle()
                        .frame(width: 134, height: 5)
                        .cornerRadius(2.5)
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                }
                .disabled(showCompleted)              // disable interactions under overlay
                .blur(radius: showCompleted ? 2 : 0)  // optional blur when overlay is up

                // ── Custom “Popover” Overlay ──
                if showCompleted {
                    // Dimmed backdrop
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    // Completed card
                    TripCompletedCard(
                      bookingRequestID: bookingRequestID,
                      onDone: {
                       
                        withAnimation { showCompleted = false }
                      
                        presentationMode.wrappedValue.dismiss()
                      },
                      driverId: driverId,
                    )
                    .frame(maxWidth: 350)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(radius: 8)
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut, value: showCompleted)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(true)
        }

        // MARK: Helpers

        private func toggleSelection(_ item: String) {
            if selectedItems.contains(item) {
                selectedItems.remove(item)
            } else {
                selectedItems.insert(item)
            }
        }

        private func iconName(for item: String) -> String {
            switch item {
            case "Engine":         return "car.fill"
            case "Oil Levels":     return "drop.fill"
            case "Brake":          return "circle.dashed"
            case "Transmission":   return "gearshape"
            case "Exhaust System": return "arrow.up.forward"
            case "Tires & Wheels": return "circle.grid.cross"
            default:               return "checkmark"
            }
        }
    }

    private struct ChecklistButton: View {
        let icon: String
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 16) {
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
                .shadow(color: Color.gray.opacity(0.1), radius: 2, x: 0, y: 1)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 1))
                .overlay {
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 50, y: -50)
                    }
                }
            }
        }
    }



    struct VehicleChecklistView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                VehicleChecklistView(
                    vehicleNumber:    "KA05AK0434",
                    bookingRequestID: "PREVIEW_ID",
                    phase:            .post,
                    driverId: "PREVIEW_ID"
                )
            }
        }
    }
