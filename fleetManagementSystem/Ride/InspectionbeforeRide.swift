import SwiftUI
import MapKit

struct InspectionbeforeRide: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    @State private var vehicleLocation = CLLocationCoordinate2D(latitude: 37.334_700, longitude: -122.008_800)
    @State private var rejectTimeRemaining: Int = 20
    @State private var navigateToInspection = false
    @Environment(\.presentationMode) var presentationMode

    struct MapLocation: Identifiable {
        let id = UUID()
        var coordinate: CLLocationCoordinate2D
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Map
            Map(coordinateRegion: $region, annotationItems: [MapLocation(coordinate: vehicleLocation)]) { item in
                MapMarker(coordinate: item.coordinate, tint: .blue)
            }
            .ignoresSafeArea()
            
            // Top controls
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                
                Spacer()
                
                Button(action: {
                    // SOS action
                }) {
                    Text("SOS")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding()
            .padding(.top, 8)
            
            // Bottom Card
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 4) {
                    // Top Vehicle Info (Blue Section)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
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
                        }
                        
                        Text("KA05AK0434")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 2)
                    }
                    .padding(26)
                    .background(Color(red: 0.25, green: 0.44, blue: 0.7))
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                    .zIndex(0)
                    
                    // White Card with Truck Image
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pre-Trip Actions")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.horizontal, 20)
                                .padding(.top, 60)
                            
                            HStack(spacing: 12) {
                                // Fuel Button
                                Button(action: {
                                    // Log Fuel action
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Image(systemName: "fuelpump.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.black)
                                        
                                        Text("Fuel")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Text("Log Current Fuel Level")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .cornerRadius(16)
                                }
                                
                                // Inspection Button
                                Button(action: {
                                    navigateToInspection = true
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Image(systemName: "checkmark.square.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.black)
                                        
                                        Text("Begin Inspection")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Text("Start Pre-Trip Checklist")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .frame(height: 180)
                        .background(Color.white)
                        .cornerRadius(24, corners: [.topLeft, .topRight])
                        .offset(y: -24)
                        
                        // Truck Image
                        Image("truck")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 60)
                            .offset(x: -20, y: -50)
                            .zIndex(2)
                    }
                    .zIndex(1)
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.bottom)
            }
            
            // Hidden Navigation
            NavigationLink(
                destination: VehicleChecklistView(),
                isActive: $navigateToInspection,
                label: { EmptyView() }
            )
            .hidden()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct InspectionbeforeRide_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InspectionbeforeRide()
        }
    }
}

// Extension for rounded corners
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
