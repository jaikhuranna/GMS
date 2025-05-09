import SwiftUI
import MapKit
import FirebaseFirestore

struct FuelLogScreen: View {
  let bookingRequestID: String
  let vehicleNumber:   String
  @Environment(\.dismiss) var dismiss
  @State private var selectedFuelLevel = 50
  @State private var showPicker        = false
  @State private var showConfirm       = false
  private let db = Firestore.firestore()
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    ZStack(alignment: .bottom) {
      // 1) Your Map background
      Map(coordinateRegion: .constant(
            MKCoordinateRegion(
              center: CLLocationCoordinate2D(latitude:13.0827, longitude:80.2707),
              span: MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta:0.01)
            )
          )
      )
      .ignoresSafeArea()

      // 2) Bottom sheet
      VStack(spacing: 0) {
        // — Blue header with vehicle info —
        HStack {
          Text(vehicleNumber)
            .font(.title2).bold().foregroundColor(.primary)
          Spacer()
          // optionally show mileage
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color.accentColor)
        .cornerRadius(24, corners: [.topLeft, .topRight])

        // Large, nice truck image
        HStack {
          Spacer()
          Image("truck")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 400, height: 204)
            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
          Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)

        // — Card with fuel controls —
        VStack(spacing: 16) {
          Text("Log Fuel Level")
            .font(.headline)
            .padding(.top, 16)

          HStack(spacing: 16) {
            Image(systemName: "fuelpump.fill")
              .font(.system(size: 24))
              .foregroundColor(.primary)

            Text("\(selectedFuelLevel)%")
              .padding(.vertical, 8)
              .padding(.horizontal, 12)
              .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
              .cornerRadius(8)
              .onTapGesture { showPicker.toggle() }

            Spacer()

            Button("SET") {
              saveFuelLog()
            }
            .font(.subheadline).bold()
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.accentColor)
            .cornerRadius(8)
          }

          if showPicker {
            Picker("", selection: $selectedFuelLevel) {
              ForEach(0..<101) { n in Text("\(n)%").tag(n) }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 120)
          }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
        .cornerRadius(24, corners: [.topLeft, .topRight])
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom)
    }
    .frame(maxWidth: .infinity)
    .alert("Fuel Level Logged",
           isPresented: $showConfirm,
           actions: { Button("OK", role: .cancel) { dismiss() } },
           message: { Text("Set to \(selectedFuelLevel)%") }
    )
  }

  private func saveFuelLog() {
    let payload: [String:Any] = [
      "tripId":        bookingRequestID,
      "vehicleNumber": vehicleNumber,
      "fuelLevel":     selectedFuelLevel,
      "timestamp":     Timestamp(date: Date())
    ]
    db.collection("fuelLogs")
      .addDocument(data: payload) { err in
        if let err = err {
          print("Fuel log error:", err)
        } else {
          showConfirm = true
        }
      }
  }
}

struct FuelLogScreen_Previews: PreviewProvider {
    static var previews: some View {
        FuelLogScreen(
            bookingRequestID: "PREVIEW_TRIP_ID",
            vehicleNumber:    "KA05AK0434"
        )
    }
}
