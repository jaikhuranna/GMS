import SwiftUI
import MapKit
import FirebaseFirestore

/// Flip this between `.pre` (before trip) and `.post` (after trip)
enum InspectionPhase {
  case pre, post

  var headerText: String {
    switch self {
    case .pre:  return "Pre-Trip Actions"
    case .post: return "Post-Trip Actions"
    }
  }

  var inspectionButtonText: String {
    switch self {
    case .pre:  return "Begin Inspection"
    case .post: return "Finish Inspection"
    }
  }

  /// where we write the checklist
  var collectionName: String {
    switch self {
    case .pre:  return "preTripInspections"
    case .post: return "postTripInspections"
    }
  }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
   @Published var location: CLLocation?
   private let manager = CLLocationManager()

   override init() {
     super.init()
     manager.delegate = self
     manager.desiredAccuracy = kCLLocationAccuracyBest
     manager.startUpdatingLocation()
   }

   func requestWhenInUseAuthorization() {
     manager.requestWhenInUseAuthorization()
   }

   func locationManager(_ mgr: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
     location = locs.last
   }
 }

struct InspectionbeforeRide: View {
  let bookingRequestID: String
  let vehicleNumber:    String
  let phase:            InspectionPhase
  let driverId: String
  
    @ObservedObject var viewModel: AuthViewModel

  @State private var trackingMode: MapUserTrackingMode = .follow

  @Environment(\.presentationMode) var presentationMode
  @State private var navigateToInspection = false

  // map region & marker
  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 37.3347, longitude: -122.0090),
    span:   MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
  )
  @State private var vehicleLocation = CLLocationCoordinate2D(
    latitude: 37.3347, longitude: -122.0088
  )

  // fuel‐log state
  @State private var showFuelPicker    = false
  @State private var selectedFuelLevel = 50
  @State private var fuelLogged        = false
   @StateObject private var locationManager = LocationManager()
    @State private var navigateToSOS = false

  private let db = Firestore.firestore()
    private var distanceToVehicleKm: Double {
      guard let userLoc = locationManager.location else { return 0 }
      let me      = CLLocation(latitude: userLoc.coordinate.latitude,
                                 longitude: userLoc.coordinate.longitude)
      let vehicle = CLLocation(latitude: vehicleLocation.latitude,
                                 longitude: vehicleLocation.longitude)
      return me.distance(from: vehicle) / 1_000
    }


  var body: some View {
    ZStack(alignment: .top) {
      // — Map —
        Map(
          coordinateRegion:    $region,
          showsUserLocation:   true,
          userTrackingMode:    $trackingMode,
          annotationItems:     [ MapLocation(coordinate: vehicleLocation) ]
        ) { item in
          MapMarker(coordinate: item.coordinate, tint: Color(red: 57/255, green: 107/255, blue: 175/255))
        }
        .ignoresSafeArea()
        .onAppear {
          locationManager.requestWhenInUseAuthorization()
          
          // as soon as we have a location, center the region there
          if let loc = locationManager.location {
            region.center = loc.coordinate
          }
        }
        NavigationLink(
            destination: EmergencyHelpView(),
            isActive: $navigateToSOS
        ) {
            EmptyView()
        }


      // — Top controls —
      HStack {
        Button { presentationMode.wrappedValue.dismiss() } label: {
          Image(systemName: "arrow.left")
            .font(.system(size: 18, weight: .bold))
            .padding(10)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(radius: 2)
        }
        Spacer()
          Button(action: {
              navigateToSOS = true
          }) {
              Text("SOS")
                  .font(.system(size: 18, weight: .bold))
                  .foregroundColor(.white)
                  .frame(width: 60, height: 60)
                  .background(Color.red)
                  .clipShape(Circle())
                  .shadow(radius: 2)
          }
      }
      .padding()
      .padding(.top, 8)

      // — Bottom card (blue + white sheet) —
      VStack(spacing: 0) {
        Spacer()

        VStack(spacing: 4) {
          // Blue Section
          VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
              VStack(alignment: .leading, spacing: 2) {
                Text("Tata ACE")
                  .font(.system(size: 26, weight: .bold))
                  .foregroundColor(.white)
                                }
                                Spacer()
                              }
              Text(vehicleNumber)
              .font(.system(size: 15))
              .foregroundColor(.white.opacity(0.8))
              .padding(.top, 2)
          }
          .padding(26)
          .frame(maxWidth: .infinity)
          .background(Color(red: 0.25, green: 0.44, blue: 0.7))
          .cornerRadius(24, corners: [.topLeft, .topRight])
          .zIndex(1)

          ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
              Text(phase.headerText)
                .font(.system(size: 22, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.top, 40)

              HStack(spacing: 12) {
                Button(action: { withAnimation { showFuelPicker.toggle() } }) {
                  fuelCard
                }
                .frame(maxWidth: .infinity)

                Button(action: { saveInspectionAndNavigate() }) {
                  inspectionCard
                }
                .frame(maxWidth: .infinity)
                .disabled(!fuelLogged)
              }
              .padding(.horizontal, 20)

              if showFuelPicker {
                VStack(spacing: 12) {
                  Picker("", selection: $selectedFuelLevel) {
                    ForEach(0..<101) { n in Text("\(n)%").tag(n) }
                  }
                  .pickerStyle(WheelPickerStyle())
                  .frame(height: 120)

                  Button("SET FUEL") {
                    saveFuelLog()
                  }
                  .font(.system(size: 14, weight: .bold))
                  .foregroundColor(.white)
                  .padding(.vertical, 10)
                  .frame(maxWidth: .infinity)
                  .background(Color.green)
                  .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
              }
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .offset(y: -24)
            .zIndex(0)

            Image("truck")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 200, height: 110)
              .offset(x: -20, y: -90)
              .zIndex(2)
          }
          .zIndex(1)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
      }

      .navigationBarHidden(true)
      .background(
        NavigationLink(
          destination: VehicleChecklistView(
            vehicleNumber: vehicleNumber,
            bookingRequestID: bookingRequestID,
            phase: phase,
            driverId: driverId, viewModel: viewModel
          ),
          isActive: $navigateToInspection
        ) { EmptyView() }
        .hidden()
      )
    }
  }

  // MARK: — Subviews

  private var fuelCard: some View {
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
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
    .overlay(
      Group {
        if fuelLogged {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.green)
            .offset(x: 12, y: -12)
        }
      }
    )
  }

  private var inspectionCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Image(systemName: "checkmark.square.fill")
        .font(.system(size: 24))
        .foregroundColor(.black)
      Text(phase.inspectionButtonText)
        .font(.system(size: 16, weight: .medium))
      Text(phase == .pre
           ? "Start Pre-Trip Checklist"
           : "Start Post-Trip Checklist")
        .font(.system(size: 12))
        .foregroundColor(.secondary)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  // MARK: — Actions

  private func saveFuelLog() {
    let data: [String:Any] = [
      "tripId":        bookingRequestID,
      "vehicleNumber": vehicleNumber,
      "fuelLevel":     selectedFuelLevel,
      "timestamp":     Timestamp(date: Date())
    ]
    db.collection("fuelLogs").addDocument(data: data) { err in
      if let err = err {
        print("Fuel log error:", err.localizedDescription)
      } else {
        fuelLogged = true
        withAnimation { showFuelPicker = false }
      }
    }
  }

  private func saveInspectionAndNavigate() {
    let doc: [String:Any] = [
      "tripId":        bookingRequestID,
      "vehicleNumber": vehicleNumber,
      "timestamp":     Timestamp(date: Date())
    ]
    db.collection(phase.collectionName)
      .addDocument(data: doc) { err in
        if let err = err {
          print("Inspection save error:", err.localizedDescription)
        } else {
          navigateToInspection = true
        }
      }
  }

  struct MapLocation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
  }
}

// MARK: — CornerRadius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
//
//// MARK: — Preview
//
//struct InspectionbeforeRide_Previews: PreviewProvider {
//  static var previews: some View {
//    NavigationView {
//      InspectionbeforeRide(
//        bookingRequestID: "PREVIEW_ID",
//        vehicleNumber:   "KA05AK0434",
//        phase:           .post,
//        driverId: "PREVIEW_ID"
//       
//      )
//    }
//  }
//}
