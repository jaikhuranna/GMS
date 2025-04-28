import SwiftUI
import MapKit

struct TripAssignedView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var isConfirmed = false
    
    var body: some View {
        NavigationStack {   // <<<<< Add NavigationStack here
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Blue Top Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Trip Assigned")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                // Close action
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                        
                        HStack(spacing: 0) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 14))
                            Text("Tata ACE  < 3km")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(20)
                    .background(Color(red: 0.25, green: 0.44, blue: 0.7))
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                    
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Text("25 kms")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        VStack(spacing: 16) {
                            // Pickup
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Infosys Gate 2")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Meenakunte, Hebbal Industrial Area")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Drop
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Mysuru Airport")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Mandakalli, Karnataka 571311")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Slide Button
                        SlideToConfirm {
                            isConfirmed = true
                        }
                        .padding(.horizontal)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                    .frame(height: 220)
                }
                
                // NavigationLink OUTSIDE background
                NavigationLink(destination: InspectionbeforeRide(), isActive: $isConfirmed) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SlideToConfirm: View {
    var action: () -> Void
    
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isConfirmed = false
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color(red: 0.25, green: 0.44, blue: 0.7))
                .frame(height: 60)
            
            Text(isConfirmed ? "Confirmed" : "Slide To Confirm")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
            
            HStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(red: 0.25, green: 0.44, blue: 0.7))
                            .font(.system(size: 24, weight: .bold))
                    )
                    .offset(x: dragOffset.width)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                if value.translation.width > 0 && value.translation.width < 220 {
                                    state = value.translation
                                }
                            }
                            .onEnded { value in
                                if value.translation.width > 180 {
                                    isConfirmed = true
                                    action()
                                }
                            }
                    )
                
                Spacer()
            }
            .padding(.leading, 5)
        }
    }
}

struct TripAssignedView_Previews: PreviewProvider {
    static var previews: some View {
        TripAssignedView()
    }
}
