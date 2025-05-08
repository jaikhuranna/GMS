import SwiftUI
import MapKit
import Combine
import FirebaseFirestore

struct LocationAnnotation: Identifiable {
    let id: String // "pickup" or "dropoff"
    let coordinate: CLLocationCoordinate2D
    let tint: Color
}

struct TripAssignedView: View {
    @ObservedObject var bookingService: BookingService
    @ObservedObject var viewModel: AuthViewModel // Use AuthViewModel for Appwrite authentication
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showCompletedCard = false
    @State private var navigateToInspection = false
    @State private var navigateToProfile = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // MARK: - Map with pickup + dropoff pins
                NavigationLink(
                    destination: DriverProfile(viewModel: viewModel), // Use AuthViewModel
                    isActive: $navigateToProfile
                ) {
                    EmptyView()
                }

                Map(
                    coordinateRegion: $region,
                    annotationItems: annotations()
                ) { item in
                    MapMarker(coordinate: item.coordinate, tint: item.tint)
                }
                .ignoresSafeArea()
                // overlay our Profile button
                .overlay(alignment: .topTrailing) {
                    Button {
                        // any pre‑nav logic here, then…
                        navigateToProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    // inset from edges + notch/status bar
                    .padding(.trailing, 16)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0 + 8)
                }
                .onAppear { updateRegionIfNeeded() }
                .onChange(of: bookingService.booking) { _ in updateRegionIfNeeded() }

                // MARK: - Bottom sheet for trip info
                if let trip = bookingService.booking {
                    let displayKm = distanceKm(for: trip)
                    VStack(spacing: 0) {
                        TripHeader(trip: trip, distanceKm: displayKm)
                        TripDetails(
                            trip: trip,
                            distanceKm: displayKm,
                            onAccept: { accept(trip: trip) },
                            onReject: { reject(trip: trip) }
                        )
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .background(Color.white)

                    // navigation to inspection
                    NavigationLink(
                        destination: InspectionbeforeRide(
                            bookingRequestID: trip.id,
                            vehicleNumber: trip.vehicleNo,
                            phase: .pre,
                            driverId: trip.driverId, viewModel: viewModel
                        ),
                        isActive: $navigateToInspection
                    ) {
                        EmptyView()
                    }
                } else {
                    ProgressView("Waiting for trip assignment…")
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCompletedCard) {
                NavigationStack {
                    if let trip = bookingService.booking {
                        TripCompletedCard(
                            bookingRequestID: trip.id,
                            onHideOverlay: { complete() },
                            viewModel: viewModel // Pass AuthViewModel instead of driverId
                        )
                    }
                }
            }
        }
    }
    
    private func accept(trip: BookingRequest) {
        // navigate to inspection immediately
        navigateToInspection = true
        // update firestore status
        let ref = Firestore.firestore()
            .collection("bookingRequests")
            .document(trip.id)
        ref.updateData(["status": "accepted"]) { error in
            if let error = error {
                print("Accept error:", error)
            } else {
                print("Trip accepted")
            }
        }
    }
    
    private func reject(trip: BookingRequest) {
        let ref = Firestore.firestore()
            .collection("bookingRequests")
            .document(trip.id)
        ref.updateData(["status": "rejected"]) { error in
            if let error = error {
                print("Reject error:", error)
            } else {
                print("Trip rejected")
//                bookingService.clearBooking()
                DispatchQueue.main.async {
                    bookingService.booking = nil
                }

            }
        }
    }
    
    private func complete() {
        guard let trip = bookingService.booking else { return }
        let ref = Firestore.firestore()
            .collection("bookingRequests")
            .document(trip.id)
        ref.updateData(["status": "completed"]) { error in
            if let error = error {
                print("Complete error:", error)
            } else {
                print("Trip completed")
                showCompletedCard = false
//                bookingService.clearBooking()
                DispatchQueue.main.async {
                    bookingService.booking = nil
                }

            }
        }
    }
    
    private func safeAreaTopInset() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    
    private func annotations() -> [LocationAnnotation] {
        guard let trip = bookingService.booking else { return [] }
        return [
            LocationAnnotation(
                id: "pickup",
                coordinate: CLLocationCoordinate2D(
                    latitude: trip.pickupLatitude,
                    longitude: trip.pickupLongitude
                ),
                tint: .green
            ),
            LocationAnnotation(
                id: "dropoff",
                coordinate: CLLocationCoordinate2D(
                    latitude: trip.dropoffLatitude,
                    longitude: trip.dropoffLongitude
                ),
                tint: .red
            )
        ]
    }
    
    private func updateRegionIfNeeded() {
        guard let trip = bookingService.booking else { return }
        let lats = [trip.pickupLatitude, trip.dropoffLatitude]
        let lons = [trip.pickupLongitude, trip.dropoffLongitude]
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (lats.max()! - lats.min()!) * 1.5 + 0.01,
            longitudeDelta: (lons.max()! - lons.min()!) * 1.5 + 0.01
        )
        
        withAnimation { region = MKCoordinateRegion(center: center, span: span) }
    }
    
    private func distanceKm(for trip: BookingRequest) -> Double {
        let p1 = CLLocation(
            latitude: trip.pickupLatitude,
            longitude: trip.pickupLongitude
        )
        
        let p2 = CLLocation(
            latitude: trip.dropoffLatitude,
            longitude: trip.dropoffLongitude
        )
        
        return p1.distance(from: p2) / 1_000
    }
}

// MARK: - Trip Header & Details
private struct TripHeader: View {
    let trip: BookingRequest
    let distanceKm: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trip Assigned")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 14))
                Text("\(trip.vehicleNo) < \(Int(distanceKm)) km")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(20)
        .background(Color(red: 0.25, green: 0.44, blue: 0.7))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

private struct TripDetails: View {
    let trip: BookingRequest
    let distanceKm: Double
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Text("\(Int(distanceKm)) km")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            // Pickup & Dropoff rows
            VStack(alignment: .leading, spacing: 16) {
                // Pickup
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.pickupName)
                            .font(.system(size: 18, weight: .bold))
                        Text(trip.pickupAddress)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Dropoff
                HStack(spacing: 12) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.dropoffName)
                            .font(.system(size: 18, weight: .bold))
                        Text(trip.dropoffAddress)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Accept / Reject buttons
            HStack(spacing: 16) {
                Button(action: onReject) {
                    Text("Reject")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                
                Button(action: onAccept) {
                    Text("Accept")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.25, green: 0.44, blue: 0.7))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 20)
        }
        .padding(20)
        .background(Color.white)
        .frame(maxWidth: .infinity)
    }
}


// MARK: - Preview Support
final class MockBookingService: BookingService {
    override init(driverId: String) {
        super.init(driverId: driverId)
        // supply pickup & drop-off lat/lon here
        self.booking = BookingRequest(
            driverId: "PREVIEW_ID",
            id: "PREVIEW_ID",
            pickupName: "Infosys Gate 2",
            pickupAddress: "Meenakunte, Hebbal Industrial Area",
            pickupLatitude: 12.3111,
            pickupLongitude: 76.6492,
            dropoffName: "Mysuru Airport",
            dropoffAddress: "Mandakalli, Karnataka 571311",
            dropoffLatitude: 12.3052,
            dropoffLongitude: 76.6551,
            distanceKm: 25,
            createdAt: Date(),
            vehicleNo: "Tata ACE"
        )
    }
}

struct TripAssignedView_Previews: PreviewProvider {
    static var previews: some View {
        TripAssignedView(
            bookingService: MockBookingService(driverId: "PREVIEW"),
            viewModel: AuthViewModel()
        )
    }
}
