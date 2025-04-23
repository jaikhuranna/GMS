import SwiftUI
import MapKit

struct InspectionbeforeRide: View {
    // Location state
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    // Vehicle marker
    @State private var vehicleLocation = CLLocationCoordinate2D(latitude: 37.334_700, longitude: -122.008_800)
    
    // Timer for reject button
    @State private var rejectTimeRemaining: Int = 20
    
    // Navigation state
    @State private var navigateToInspection = false
    
    // Location annotation item
    struct MapLocation: Identifiable {
        let id = UUID()
        var coordinate: CLLocationCoordinate2D
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map view
                Map(coordinateRegion: $region, annotationItems: [MapLocation(coordinate: vehicleLocation)]) { item in
                    MapMarker(coordinate: item.coordinate, tint: .blue)
                }
                .ignoresSafeArea()
                
                // Top navigation
                HStack {
                    Button(action: {
                        // Handle back action
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Handle SOS action
                    }) {
                        Text("SOS")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Vehicle info sheet
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // Vehicle info header
                        VStack(spacing: 0) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Tata ACE")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Text("< 3km")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.top, 2)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.swap")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Text("87,041km")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                
                                Spacer()
                                
                                // Use a real truck image asset
                                Image("delivery_truck") // You'll need to add this asset to your project
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 60)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 15)
                        }
                        .background(Color(red: 0.25, green: 0.44, blue: 0.7))
                        .cornerRadius(24)
                        
                        // Quick actions section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Quick Actions")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Spacer()
                                
                                Text("KA05AK0434")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            // Quick action buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    // Fuel action
                                }) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "fuelpump.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(.black)
                                            
                                            Text("Fuel")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        
                                        Text("Log Current Fuel Level")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 18)
                                    .padding(.horizontal, 16)
                                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .cornerRadius(16)
                                }
                                
                                Button(action: {
                                    navigateToInspection = true
                                }) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.square.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(.black)
                                            
                                            Text("Inspect")
                                                .font(.system(size: 16, weight: .medium))
                                                .lineLimit(2)
                                        }
                                        
                                        Text("Start Checklist")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 18)
                                    .padding(.horizontal, 16)
                                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Action buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    // Handle reject action
                                }) {
                                    Text("Reject(20s)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(red: 0.9, green: 0.92, blue: 0.96))
                                        .cornerRadius(28)
                                }
                                
                                Button(action: {
                                    // Handle accept action
                                }) {
                                    Text("Accept")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(red: 0.25, green: 0.44, blue: 0.7))
                                        .cornerRadius(28)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .padding(.top, 10)
                        }
                        .background(Color.white)
                        .cornerRadius(24, corners: [.topLeft, .topRight])
                        .offset(y: -20)
                    }
                }

                
                // Hidden navigation link for inspection view
                NavigationLink(
                    destination: VehicleChecklistView(),
                    isActive: $navigateToInspection,
                    label: { EmptyView() }
                )
                .hidden()
            }
            .navigationBarHidden(true)
        }
    }
}

// Extension to apply different corner radius to different corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Preview
struct InspectionbeforeRide_Previews: PreviewProvider {
    static var previews: some View {
        InspectionbeforeRide()
    }
}
