import SwiftUI

struct VehicleChecklistView: View {
    let vehicleNumber = "KA05AK0434"
    @State private var navigateToMap = false
    @State private var selectedItems: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.trailing, 16)
                }
                
                Spacer()
                
                Text("Vehicle Checklist")
                    .font(.system(size: 24, weight: .semibold))
                
                Spacer()
                
                // Empty view to balance the HStack
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.clear)
                    .padding(.trailing, 16)
            }
            .padding()
            .background(Color.white)
            
            // Vehicle image and number
            VStack(spacing: 8) {
                Image("truck")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                Text(vehicleNumber)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.top, 4)
            }
            .padding(.vertical)
            
            // Grid of options
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ChecklistButton(icon: "drop.fill", title: "Oil Levels", isSelected: selectedItems.contains("Oil Levels")) {
                    toggleSelection("Oil Levels")
                }
                ChecklistButton(icon: "circle.dashed", title: "Brake", isSelected: selectedItems.contains("Brake")) {
                    toggleSelection("Brake")
                }
                ChecklistButton(icon: "car.fill", title: "Engine", isSelected: selectedItems.contains("Engine")) {
                    toggleSelection("Engine")
                }
                ChecklistButton(icon: "arrow.up.forward", title: "Exhaust\nSystem", isSelected: selectedItems.contains("Exhaust System"), multiline: true) {
                    toggleSelection("Exhaust System")
                }
                ChecklistButton(icon: "gearshape", title: "Transmission", isSelected: selectedItems.contains("Transmission")) {
                    toggleSelection("Transmission")
                }
                ChecklistButton(icon: "circle.grid.cross", title: "Tires &\nWheels", isSelected: selectedItems.contains("Tires & Wheels"), multiline: true) {
                    toggleSelection("Tires & Wheels")
                }
            }
            .padding()
            
            Spacer()
            
            // Dynamic bottom action button with NavigationLink trigger
            Button(action: {
                if selectedItems.count == 6 {
                    navigateToMap = true
                }
            }) {
                HStack {
                    Image(systemName: selectedItems.count == 6 ? "wrench" : "wrench.and.screwdriver")
                        .foregroundColor(.white)
                    Text(selectedItems.count == 6 ? "Vehicle Ready!" : "Report Maintenance Issue!")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                }
                .padding()
                .background(selectedItems.count == 6
                            ? Color(red: 63/255, green: 98/255, blue: 163/255)
                            : Color.red.opacity(0.85))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            // Hidden NavigationLink for programmatic navigation
            NavigationLink(
                destination: NavigationMapView(from: "Start Location", to: "Destination Location")
                    .navigationBarBackButtonHidden(true),
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
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
    
    func toggleSelection(_ item: String) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
}

struct ChecklistButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var multiline: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.blue)
                
                if multiline {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                } else {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
            }
            .frame(width: 140, height: 140)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.gray.opacity(0.1), radius: 2, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .overlay(
                ZStack {
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
            )
        }
    }
}

struct VehicleChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VehicleChecklistView()
        }
    }
}
