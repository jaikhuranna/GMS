import SwiftUI

struct EditDriverView: View {
    @Environment(\.dismiss) private var dismiss
    
    let original: Driver
    @State private var driver: Driver
    @State private var licenseProofImage: UIImage?
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imagePickerType: ImagePickerType = .profile
    @State private var validationErrors: [String: String] = [:]
    @FocusState private var focusedField: Field?
    @State private var showingLicenseTypePicker = false
    @State private var showSuccess = false
    @State private var firestoreError: String?
    @State private var isSaving = false
    
    let onSave: () -> Void
    
    enum ImagePickerType {
        case profile
        case license
    }
    
    enum Field {
        case name, age, experience, licenseNo, contactNo
    }
    
    init(driver: Driver, onSave: @escaping () -> Void) {
        self.original = driver
        self._driver = State(initialValue: driver)
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        profileUploadSection
                        driverDetailsContainer
                        licenseUploadSection
                        saveChangesButton
                    }
                    .padding(.bottom, 24)
                    .padding(.horizontal, 16)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: imagePickerType == .profile ? $profileImage : $licenseProofImage)
                }
                .alert("Success", isPresented: $showSuccess) {
                    Button("OK") {
                        onSave()
                        dismiss()
                    }
                } message: {
                    Text("Your changes have been saved.")
                }
            }
            
            if isSaving {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView("Saving…")
                    .padding(24)
                    .background(.regularMaterial)
                    .cornerRadius(12)
            }
        }
        .navigationTitle("Edit Driver")
    }
    
    private var profileUploadSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 120)
                .overlay(
                    Group {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            AsyncImage(url: URL(string: original.driverImage)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                default:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color(hex: "#396BAF"))
                                }
                            }
                        }
                    }
                )
            
            Button(action: {
                imagePickerType = .profile
                showingImagePicker = true
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "pencil")
                            .foregroundColor(Color(hex: "#396BAF"))
                            .font(.system(size: 16, weight: .medium))
                    )
                    .shadow(radius: 2)
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 16)
    }
    
    private var driverDetailsContainer: some View {
        VStack(spacing: 6) {
            Text("Driver Details")
                .font(.headline)
                .foregroundColor(Color(hex: "#396BAF"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 2)
                .fontWeight(.bold)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                VStack(spacing: 16) {
                    // Name row
                    inputRow(title: "Name", text: $driver.driverName, field: .name)
                    Divider()
                    
                    // Age row
                    inputRow(title: "Age", text: Binding(
                        get: { String(driver.driverAge) },
                        set: { driver.driverAge = Int($0) ?? 0 }
                    ), field: .age, keyboard: .numberPad)
                    Divider()
                    
                    // License No row
                    inputRow(title: "Licence No.", text: $driver.driverLicenseNo, field: .licenseNo)
                    Divider()
                    
                    // Contact No row
                    inputRow(title: "Contact No.", text: $driver.driverContactNo, field: .contactNo, keyboard: .phonePad)
                    
                    Divider()
                    
                    // Experience row
                    inputRow(title: "Experience", text: Binding(
                        get: { String(driver.driverExperience) },
                        set: { driver.driverExperience = Int($0) ?? 0 }
                    ), field: .experience, keyboard: .numberPad)
                    
                    Divider()
                    
                    // License Type row with dropdown
                    licenseTypeRow
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
        }
        .padding(.horizontal)
    }
    
    private func inputRow(title: String, text: Binding<String>, field: Field, keyboard: UIKeyboardType = .default) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(title)
                .foregroundColor(Color(hex: "#396BAF"))
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("Enter \(title.lowercased())", text: text)
                    .keyboardType(keyboard)
                    .focused($focusedField, equals: field)
                    .font(.body)
                
                if let error = validationErrors[title] {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .frame(height: 40)
    }
    
    private var licenseTypeRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Licence Type")
                .foregroundColor(Color(hex: "#396BAF"))
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            Button(action: {
                showingLicenseTypePicker = true
            }) {
                HStack {
                    Text(driver.driverLicenseType)
                        .foregroundColor(.black)
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .actionSheet(isPresented: $showingLicenseTypePicker) {
                ActionSheet(
                    title: Text("Select License Type"),
                    buttons: [
                        .default(Text("LMV")) { driver.driverLicenseType = "LMV" },
                        .default(Text("HMV")) { driver.driverLicenseType = "HMV" },
                        .cancel()
                    ]
                )
            }
        }
        .frame(minHeight: 40, alignment: .top)
    }
    
    private var licenseUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Licence Proof")
                .font(.headline)
                .foregroundColor(Color(hex: "#396BAF"))
                .padding(.leading, 4)
            
            Button(action: {
                imagePickerType = .license
                showingImagePicker = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .frame(height: 150)
                    
                    if let image = licenseProofImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .cornerRadius(8)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.up.doc")
                                .font(.system(size: 32))
                                .foregroundColor(Color(hex: "#396BAF"))
                            Text("Upload Licence Image")
                                .foregroundColor(Color(hex: "#396BAF"))
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            if let error = validationErrors["LicenseProof"] {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.leading, 4)
            }
        }
        .padding(.horizontal)
    }
    
    private var saveChangesButton: some View {
        Button(action: validateAndSave) {
            if isSaving {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#396BAF"))
                    .cornerRadius(12)
            } else {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#396BAF"))
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(12)
            }
        }
        .disabled(isSaving)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private func validateAndSave() {
        validationErrors.removeAll()
        firestoreError = nil
        
        if driver.driverName.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["Name"] = "Name is required."
        }
        if driver.driverAge <= 0 {
            validationErrors["Age"] = "Valid age is required."
        }
        if driver.driverLicenseNo.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["Licence No."] = "Licence No. is required."
        }
        if driver.driverContactNo.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["Contact No."] = "Contact No. is required."
        }
        if driver.driverExperience <= 0 {
            validationErrors["Experience"] = "Experience is required."
        }
        
        guard validationErrors.isEmpty else {
            return
        }
        
        isSaving = true
        
        FirebaseModules.shared.updateDriver(
            driver,
            profileImage: profileImage,
            licenseImage: licenseProofImage
        ) { error in
            isSaving = false
            if let err = error {
                self.firestoreError = err.localizedDescription
            } else {
                self.showSuccess = true
            }
        }
    }
}
