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
    @State private var validationErrors: [String: String] = [:]
    @State private var showingVehicleTypePicker = false
    @State private var showSuccessView = false
    @FocusState private var focusedField: Field?
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    enum Field {
        case vehicleNo, modelName, engineNo, distanceTravelled, averageMileage
    }
    
    var body: some View {
        NavigationStack {
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
            .navigationDestination(isPresented: $showSuccessView) {
                VehicleAddedSuccessView(
                    vehicleNumber: vehicle.vehicleNo,
                    distanceTravelled: String(format: "%.1f km", vehicle.distanceTravelled)
                )
            }
            .overlay(
                Group {
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
                            .padding(0)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                        }
                    }
                }
            )
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
                    .clipped()
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(hex: "#396BAF"))
                    )
            }
            
            Button(action: { showingImagePickerForVehicle = true }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "pencil")
                            .foregroundColor(Color(hex: "#396BAF"))
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
                .foregroundColor(Color(hex: "#396BAF"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 2)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                VStack(spacing: 16) {
                    inputRow(title: "Vehicle No.", text: $vehicle.vehicleNo, field: .vehicleNo)
                    Divider()
                    inputRow(title: "Model Name", text: $vehicle.modelName, field: .modelName)
//                    Divider()
//                    inputRow(title: "Chasis No.", text: $vehicle.engineNo, field: .engineNo)
                    Divider()
                    datePickerRow
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    inputDoubleRow(title: "Distance Travelled", value: $vehicle.distanceTravelled, field: .distanceTravelled)
                    Divider()
                    inputDoubleRow(title: "Avg. Mileage", value: $vehicle.averageMileage, field: .averageMileage)
                    Divider()
                    vehicleCategoryPicker
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
            }
        }
        .padding(.horizontal)
    }
    
    private func inputRow(title: String, text: Binding<String>, field: Field) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(title)
                .foregroundColor(Color(hex: "#396BAF"))
                .frame(width: 120, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                if title == "Vehicle No." {
                    TextField("AB11AC0000", text: text)
                        .focused($focusedField, equals: field)
                        .frame(minHeight: 30)
                } else if title == "Model Name" {
                    TextField("Swift Dzire", text: text)
                        .focused($focusedField, equals: field)
                        .frame(minHeight: 30)
                } else if title == "Chasis No." {
                    TextField("1A2BCDE34F5678901", text: text)
                        .focused($focusedField, equals: field)
                        .frame(minHeight: 30)
                } else {
                    TextField("Enter \(title.lowercased())", text: text)
                        .focused($focusedField, equals: field)
                        .frame(minHeight: 30)
                }
                
                if let error = validationErrors[title] {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    private func inputDoubleRow(title: String, value: Binding<Double>, field: Field) -> some View {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return HStack(alignment: .center, spacing: 16) {
            Text(title)
                .foregroundColor(Color(hex: "#396BAF"))
                .frame(width: 120, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("Enter \(title.lowercased())", value: value, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: field)
                    .frame(minHeight: 30)
                
                if let error = validationErrors[title] {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    private var datePickerRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("License Date")
                .foregroundColor(Color(hex: "#396BAF"))
                .frame(width: 100, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                DatePicker("", selection: $vehicle.licenseRenewalDate, displayedComponents: .date)
                    .labelsHidden()
                    .frame(minHeight: 30)
                
                if let error = validationErrors["License Date"] {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    private var vehicleCategoryPicker: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Vehicle Category")
                .foregroundColor(Color(hex: "#396BAF"))
                .font(.subheadline)
                .frame(width: 120, alignment: .leading)
            
            Button(action: {
                showingVehicleTypePicker = true
            }) {
                HStack {
                    Text(vehicle.vehicleCategory == .HMV ? "HMV" : "LMV")
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
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
                .foregroundColor(Color(hex: "#396BAF"))
                .padding(.leading, 4)
            
            Button(action: { showingImagePickerForInsurance = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
                                .foregroundColor(Color(hex: "#396BAF"))
                            Text("Upload Insurance Image")
                                .foregroundColor(Color(hex: "#396BAF"))
                        }
                    }
                }
            }
            
            if let error = validationErrors["InsuranceProof"] {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.leading, 4)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal)
    }
    
    private var addFleetButton: some View {
        Button(action: validateAndSave) {
            Text(isSaving ? "Saving..." : "Add To Fleet")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSaving ? Color.gray : Color(hex: "#396BAF"))
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(12)
        }
        .disabled(isSaving)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private func validateAndSave() {
        validationErrors.removeAll()
        errorMessage = ""
        showError = false
        
        // Vehicle No. validation (format: 2 letters, 2 digits, 2 letters, 4 digits, e.g., MH12AB1234)
        let vehicleNoTrimmed = vehicle.vehicleNo.trimmingCharacters(in: .whitespaces)
        if vehicleNoTrimmed.isEmpty {
            validationErrors["Vehicle No."] = "Vehicle No. is required."
        } else {
            let vehicleNoRegex = "^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", vehicleNoRegex)
            if !predicate.evaluate(with: vehicleNoTrimmed) {
                validationErrors["Vehicle No."] = "Vehicle No. must be in format AB11AC0000 (2 letters, 2 digits, 2 letters, 4 digits)."
            }
        }
        
        // Model Name validation
        let modelNameTrimmed = vehicle.modelName.trimmingCharacters(in: .whitespaces)
        if modelNameTrimmed.isEmpty {
            validationErrors["Model Name"] = "Model Name is required."
        } else if modelNameTrimmed.rangeOfCharacter(from: .decimalDigits) != nil {
            validationErrors["Model Name"] = "Model Name cannot contain numbers."
        }
        
        // Chassis No. validation (exactly 17 alphanumeric characters, e.g., 1A2BCDE34F5678901)
        let chassisNoTrimmed = vehicle.engineNo.trimmingCharacters(in: .whitespaces)
        if chassisNoTrimmed.isEmpty {
            validationErrors["Chasis No."] = "Chassis No. is required."
        } else {
            let chassisNoRegex = "^[A-Z0-9]{17}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", chassisNoRegex)
            if !predicate.evaluate(with: chassisNoTrimmed) {
                validationErrors["Chasis No."] = "Chassis No. must be exactly 17 alphanumeric characters (e.g., 1A2BCDE34F5678901)."
            }
        }
        
        // License Renewal Date validation
        let currentDate = Date()
        if vehicle.licenseRenewalDate < currentDate {
            validationErrors["License Date"] = "License renewal date cannot be in the past."
        }
        
        // Distance Travelled validation
        if vehicle.distanceTravelled <= 0 {
            validationErrors["Distance Travelled"] = "Distance Travelled must be greater than 0."
        }
        
        // Average Mileage validation
        if vehicle.averageMileage <= 0 {
            validationErrors["Avg. Mileage"] = "Average Mileage must be greater than 0."
        } else if vehicle.averageMileage > 50 {
            validationErrors["Avg. Mileage"] = "Average Mileage must be less than or equal to 50 km/l."
        }
        
        // Image validations
        if vehicle.vehiclePhoto == nil {
            validationErrors["VehiclePhoto"] = "Vehicle photo is required."
        }
        if vehicle.insuranceProofImage == nil {
            validationErrors["InsuranceProof"] = "Insurance proof is required."
        }
        
        guard validationErrors.isEmpty else { return }
        
        // Show saving state
        isSaving = true
        errorMessage = ""
        showError = false
        
        // Upload data
        Task {
            do {
                try await FirebaseModules.shared.addFleetVehicle(vehicle)
                isSaving = false
                showSuccessView = true
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct AddFleetVehicleView_Preview: PreviewProvider {
    static var previews: some View {
        AddFleetVehicleView()
    }
}
