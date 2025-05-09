import SwiftUI

struct AddFleetVehicleView: View {
    @State private var vehicle = FleetVehicle(
        vehicleNo: "",
        modelName: "",
        engineNo: "",
        licenseRenewalDate: Date(),
        distanceTravelled: 0.0,
        averageMileage: 0.0,
        vehicleType: .car,
        vehicleCategory: .LMV
    )

    @State private var showingImagePickerForVehicle = false
    @State private var showingImagePickerForInsurance = false
    @State private var showingVehicleTypePicker = false
    @State private var isSaving = false
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 4) {
                    profileUploadSection
                    vehicleDetailsContainer
                    insuranceUploadSection
                    addFleetButton
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
            .sheet(isPresented: $showingImagePickerForVehicle) {
                ImagePicker(selectedImage: $vehicle.vehiclePhoto)
            }
            .sheet(isPresented: $showingImagePickerForInsurance) {
                ImagePicker(selectedImage: $vehicle.insuranceProofImage)
            }
            .navigationDestination(for: String.self) { _ in
                VehicleAddedSuccessView(
                    vehicleNumber: vehicle.vehicleNo,
                    distanceTravelled: String(format: "%.1f km", vehicle.distanceTravelled)
                ) 
            }
            .alert(isPresented: $showValidationError) {
                Alert(title: Text("Validation Error"), message: Text(validationMessage), dismissButton: .default(Text("OK")))
            }
            .overlay {
                if isSaving {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 6) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Saving Vehicle...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    private var profileUploadSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if let photo = vehicle.vehiclePhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.accentColor)
                    )
            }

            Button(action: { showingImagePickerForVehicle = true }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "pencil")
                            .foregroundColor(.primary)
                    )
                    .shadow(radius: 2)
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 6)
    }

    private var vehicleDetailsContainer: some View {
        VStack(spacing: 6) {
            Text("Vehicle Details")
                .font(.headline)
                .foregroundColor(Color.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                VStack(spacing: 16) {
                    inputRow(title: "Vehicle No.", text: $vehicle.vehicleNo)
                    Divider()
                    inputRow(title: "Model Name", text: $vehicle.modelName)
                    Divider()
                    datePickerRow
                    Divider()
                    inputDoubleRow(title: "Distance Travelled", value: $vehicle.distanceTravelled)
                    Divider()
                    inputDoubleRow(title: "Avg. Mileage", value: $vehicle.averageMileage)
                    Divider()
                    vehicleCategoryPicker
                }
                .padding(10)
            }
        }
        .padding(.horizontal)
    }

    private func inputRow(title: String, text: Binding<String>) -> some View {
        HStack(spacing: 16) {
            Text(title)
                .foregroundColor(.primary)
                .frame(width: 120, alignment: .leading)
            TextField("Enter \(title)", text: text)
                .frame(minHeight: 30)
        }
    }

    private func inputDoubleRow(title: String, value: Binding<Double>) -> some View {
        HStack(spacing: 16) {
            Text(title)
                .foregroundColor(.primary)
                .frame(width: 120, alignment: .leading)
            TextField("Enter \(title)", value: value, format: .number)
                .keyboardType(.decimalPad)
                .frame(minHeight: 30)
        }
    }

    private var datePickerRow: some View {
        HStack(spacing: 16) {
            Text("License Date")
                .foregroundColor(.primary)
                .frame(width: 120, alignment: .leading)
            DatePicker("", selection: $vehicle.licenseRenewalDate, displayedComponents: .date)
                .labelsHidden()
        }
    }

    private var vehicleCategoryPicker: some View {
        HStack(spacing: 16) {
            Text("Vehicle Category")
                .foregroundColor(.primary)
                .frame(width: 120, alignment: .leading)
            Button(action: { showingVehicleTypePicker = true }) {
                HStack {
                    Text(vehicle.vehicleCategory == .HMV ? "HMV" : "LMV")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .actionSheet(isPresented: $showingVehicleTypePicker) {
                ActionSheet(
                    title: Text("Select Vehicle Category"),
                    buttons: [
                        .default(Text("LMV")) { vehicle.vehicleCategory = .LMV },
                        .default(Text("HMV")) { vehicle.vehicleCategory = .HMV },
                        .cancel()
                    ]
                )
            }
        }
        .frame(height: 40)
    }

    private var insuranceUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insurance Proof")
                .font(.headline)
                .foregroundColor(Color.accentColor)

            Button(action: { showingImagePickerForInsurance = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .shadow(color: .black.opacity(0.1), radius: 5)
                        .frame(height: 150)

                    VStack(spacing: 12) {
                        if let img = vehicle.insuranceProofImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        } else {
                            Image(systemName: "arrow.up.doc")
                                .font(.system(size: 32))
                                .foregroundColor(Color.accentColor)
                            Text("Upload Insurance Image")
                                .foregroundColor(Color.primary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var addFleetButton: some View {
        Button(action: saveVehicle) {
            Text(isSaving ? "Saving..." : "Add To Fleet")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSaving ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(12)
        }
        .disabled(isSaving)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func validateInputs() -> Bool {
        if vehicle.vehicleNo.isEmpty {
            validationMessage = "Please enter Vehicle Number."
            return false
        }
        if vehicle.modelName.isEmpty {
            validationMessage = "Please enter Model Name."
            return false
        }
        if vehicle.distanceTravelled <= 0 {
            validationMessage = "Please enter a valid Distance Travelled."
            return false
        }
        if vehicle.averageMileage <= 0 {
            validationMessage = "Please enter a valid Average Mileage."
            return false
        }
        return true
    }

    private func saveVehicle() {
        guard validateInputs() else {
            showValidationError = true
            return
        }

        isSaving = true

        Task {
            do {
                try await FirebaseModules.shared.addFleetVehicle(vehicle)
                isSaving = false
                path.append("Success")
            } catch {
                isSaving = false
                validationMessage = "Failed to save vehicle. Try again."
                showValidationError = true
            }
        }
    }
}

struct AddFleetVehicleView_Preview: PreviewProvider {
    static var previews: some View {
        AddFleetVehicleView()
    }
}
