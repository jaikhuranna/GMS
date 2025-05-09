import SwiftUI
import MapKit

struct MoveToDirections: View {
    @StateObject private var viewModel = NavigationViewModelDirections()
    @Environment(\.presentationMode) private var presentationMode // Add this line to get the presentation mode
    @State private var navigateToSOS = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {  // Wrap the view inside NavigationView
            ZStack {
                // Map View
                Map(
                    coordinateRegion: $viewModel.region,
                    showsUserLocation: false, // Disabled for static data
                    userTrackingMode: .constant(.none),
                    annotationItems: viewModel.annotations
                ) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        VStack {
                            Image(systemName: "airplane")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text(item.annotation.title ?? "")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                        }
                    }
                }
                .overlay(RouteOverlayView(route: viewModel.route).ignoresSafeArea())
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    viewModel.checkLocationAuthorization()
                    viewModel.startHeadingUpdates()
                }

                // Navigation UI Overlay
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss() // This will go back to the previous view
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                        }

                        Spacer()

                        VStack(alignment: .center) {
                            Text("Proceed to")
                                .foregroundColor(.white)
                                .font(.caption)
                            Text("Mysore Airport")
                                .foregroundColor(.white)
                                .font(.headline)
                                .bold()
                        }

                        Spacer()
                        NavigationLink(
                          destination: EmergencyHelpView(),
                          isActive: $navigateToSOS
                        ) { EmptyView() }

                        Button{ navigateToSOS = true } label: {
                            Text("SOS")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(red: 57/255, green: 107/255, blue: 175/255))

                    // Current Instruction
                    HStack {
                        Image(systemName: directionIcon(for: viewModel.currentInstruction))
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 30)

                        Text(viewModel.currentInstruction)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)

                        Spacer()

                        Text(viewModel.remainingDistance)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))

                    Spacer()

                    // ETA Panel
                    HStack {
                        VStack {
                            Text(viewModel.arrivalTime)
                                .font(.title2)
                                .bold()
                            Text("Arrival")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .background(Color.white)
                            .frame(height: 40)

                        VStack {
                            Text(viewModel.eta)
                                .font(.title2)
                                .bold()
                            Text("mins")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .background(Color.white)
                            .frame(height: 40)

                        VStack {
                            Text(viewModel.remainingDistance)
                                .font(.title2)
                                .bold()
                            Text("left")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(red: 57/255, green: 107/255, blue: 175/255).opacity(0.9))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .ignoresSafeArea(.container, edges: .bottom)
                }
            }
            .alert("SOS Activated", isPresented: $viewModel.showSOSAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm", role: .destructive) {
                    // Handle emergency call
                }
            } message: {
                Text("Emergency services will be notified with your current location")
            }
        }
        .navigationBarBackButtonHidden(true) // Hide the default back button if needed
    }

    private func directionIcon(for instruction: String) -> String {
        let lowerInstruction = instruction.lowercased()
        if lowerInstruction.contains("left") { return "arrow.turn.up.left" }
        else if lowerInstruction.contains("right") { return "arrow.turn.up.right" }
        else if lowerInstruction.contains("u-turn") { return "arrow.uturn.left" }
        else if lowerInstruction.contains("merge") { return "arrow.merge" }
        else if lowerInstruction.contains("arrived") { return "mappin.circle.fill" }
        else { return "arrow.up" }
    }
}


// Custom UIViewRepresentable for rendering the route overlay
struct RouteOverlayView: UIViewRepresentable {
    let route: MKPolyline?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        if let route = route {
            mapView.addOverlay(route)
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        if let route = route {
            uiView.addOverlay(route)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(red: 57/255, green: 107/255, blue: 175/255, alpha: 1)
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MoveToDirections()
    }
}
