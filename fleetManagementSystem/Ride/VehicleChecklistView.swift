import SwiftUI

struct VehicleChecklistView: View {
    let vehicleNumber = "KA05AK0434"
    @State private var selectedItems: Set<String> = [] // Empty set - nothing selected by default
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
                
                Spacer()
                
                Text("Vehicle Checklist")
                    .font(.system(size: 24, weight: .semibold))
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "camera")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
            }
            .padding()
            .background(Color.white)
            
            // Vehicle image and number
            VStack(spacing: 8) {
                Image("chevron")
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
            
            // Dynamic bottom action button
            Button(action: {
                if selectedItems.isEmpty {
                    // No action or show alert
                } else {
                    // Confirm vehicle ready action
                }
            }) {
                HStack {
                    Image(systemName: selectedItems.isEmpty ? "wrench.and.screwdriver" : "wrench")
                        .foregroundColor(.white)
                    
                    Text(selectedItems.isEmpty ? "Report Maintenance Issue!" : "Vehicle Ready!")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                }
                .padding()
                .background(selectedItems.isEmpty ? Color.red.opacity(0.85) : Color(red: 63/255, green: 98/255, blue: 163/255))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.bottom)

            
            // Home indicator
            Rectangle()
                .frame(width: 134, height: 5)
                .cornerRadius(2.5)
                .foregroundColor(.black)
                .padding(.bottom, 8)
        }
        .edgesIgnoringSafeArea(.bottom)
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

// Preview
struct VehicleChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleChecklistView()
        
    }
}
