import SwiftUI
import MapKit

struct ArrivalScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var rating: Int = 0
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.3072, longitude: 76.6497),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Interactive Map
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.all)

            // Top overlay gradient for visual effect (non-interactive)
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.3), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false) // So touches go through to the map

            // Bottom Sheet (interactive)
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("Arrived")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("On your left: Mysuru Airport")
                        .font(.subheadline)
                        .foregroundColor(.blue.opacity(0.8))
                }

                Divider().background(Color.white.opacity(0.6))

                // Rating Section
                VStack(spacing: 12) {
                    Text("Rate your route")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 4) {
                        ForEach(1..<6) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(index <= rating ? .yellow : .blue.opacity(0.6))
                                .onTapGesture {
                                    withAnimation {
                                        rating = index
                                    }
                                }
                        }
                    }
                }

                Divider().background(Color.white.opacity(0.6))

                // End Navigation Button
                Button(action: {
                    dismiss()
                }) {
                    Text("End Navigation")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .foregroundColor(Color(hex: "#F2F2F2"))
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(
                Color(hex: "#F2F2F2")
                    .edgesIgnoringSafeArea(.bottom)
            )
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }
}


// Preview
struct ArrivalScreen_Previews: PreviewProvider {
    static var previews: some View {
        ArrivalScreen()
    }
}
