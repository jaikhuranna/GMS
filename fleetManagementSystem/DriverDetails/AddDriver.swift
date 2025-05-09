import SwiftUI

struct AddDriverView: View {
    @State private var driver = Driver(
        id: UUID().uuidString,
        driverName: "",
        driverImage: "",
        driverExperience: 0,
        driverAge: 0,
        driverContactNo: "",
        driverLicenseNo: "",
        driverLicenseType: "LMV"
    )
    
    @State private var licenseProofImage: UIImage?
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imagePickerType: ImagePickerType = .profile
    @State private var showingSaveAlert = false
    @State private var validationErrors: [String: String] = [:]
    @FocusState private var focusedField: Field?
    @State private var showingLicenseTypePicker = false
    @State private var showSuccessView = false
    @State private var firestoreError: String?
    @State private var isSaving = false
    
    enum ImagePickerType {
        case profile
        case license
    }
    
    enum Field {
        case name, age, experience, licenseNo, contactNo
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 10) {
                        profileUploadSection
                        driverDetailsContainer
                        licenseUploadSection
                        addDriverButton
                    }
                    .padding(.bottom, 4)
                    .padding(.horizontal, 16)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: imagePickerType == .profile ? $profileImage : $licenseProofImage)
                }
                .navigationDestination(isPresented: $showSuccessView) {
                    DriverAddedSuccessView(
                        driverName: driver.driverName,
                        driverExperience: "\(driver.driverExperience) years"
                    )
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
                            Image(systemName: "camera.viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.accentColor)
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
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                    )
                    .shadow(radius: 2)
            }
        }
        .padding(.top, 0)
        .padding(.bottom, 6)
    }
    
    private var driverDetailsContainer: some View {
        VStack(spacing: 6) {
            Text("Driver Details")
                .font(.headline)
                .foregroundColor(Color.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 2)
                .fontWeight(.bold)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                VStack(spacing: 16) {
                    inputRow(title: "Name", text: $driver.driverName, field: .name)
                    Divider()
                    
                    inputRow(title: "Age", text: Binding(
                        get: { String(driver.driverAge) },
                        set: { driver.driverAge = Int($0) ?? 0 }
                    ), field: .age, keyboard: .numberPad)
                    Divider()
                    
                    inputRow(title: "Licence No.", text: $driver.driverLicenseNo, field: .licenseNo)
                    Divider()
                    
                    inputRow(title: "Contact No.", text: $driver.driverContactNo, field: .contactNo, keyboard: .phonePad)
                    Divider()
                    
                    inputRow(title: "Experience", text: Binding(
                        get: { String(driver.driverExperience) },
                        set: { driver.driverExperience = Int($0) ?? 0 }
                    ), field: .experience, keyboard: .numberPad)
                    Divider()
                    
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
                .foregroundColor(.primary)
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
                        .lineLimit(nil) // Allow text to wrap
                        .fixedSize(horizontal: false, vertical: true) // Ensure it wraps instead of truncating
                }
            }
        }
    }
    
    private var licenseTypeRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Licence Type")
                .foregroundColor(.primary)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            Button(action: {
                showingLicenseTypePicker = true
            }) {
                HStack {
                    Text(driver.driverLicenseType)
                        .foregroundColor(.primary)
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
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
                .foregroundColor(Color.accentColor)
                .padding(.leading, 4)
            
            Button(action: {
                imagePickerType = .license
                showingImagePicker = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
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
                                .foregroundColor(Color.accentColor)
                            Text("Upload Licence Image")
                                .foregroundColor(Color.accentColor)
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
                    .lineLimit(nil) // Allow text to wrap
                    .fixedSize(horizontal: false, vertical: true) // Ensure it wraps instead of truncating
            }
        }
        .padding(.horizontal)
    }
    
    private var addDriverButton: some View {
        Button(action: validateAndSave) {
            if isSaving {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            } else {
                Text("Add Driver")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(12)
            }
        }
        .disabled(isSaving)
        .padding(.horizontal)
        .padding(.top, 0)
    }
    
    private func validateAndSave() {
        // Clear previous errors
        validationErrors.removeAll()
        firestoreError = nil
        
        // Name validation
        let nameTrimmed = driver.driverName.trimmingCharacters(in: .whitespaces)
        if nameTrimmed.isEmpty {
            validationErrors["Name"] = "Name is required."
        } else if nameTrimmed.rangeOfCharacter(from: .decimalDigits) != nil {
            validationErrors["Name"] = "Name cannot contain numbers."
        }
        
        // Age validation
        if driver.driverAge < 19 {
            validationErrors["Age"] = "Age must be at least 19."
        }
        
        // Experience validation
        if driver.driverExperience <= 0 {
            validationErrors["Experience"] = "Experience is required."
        } else if driver.driverAge >= 19 && driver.driverExperience > (driver.driverAge - 18) {
            validationErrors["Experience"] = "Experience cannot exceed age minus 18 years."
        }
        
        // License number validation (assuming format: 2 letters followed by 13 digits)
        let licenseTrimmed = driver.driverLicenseNo.trimmingCharacters(in: .whitespaces)
        if licenseTrimmed.isEmpty {
            validationErrors["Licence No."] = "Licence No. is required."
        } else {
            let licenseRegex = "^[A-Z]{2}[0-9]{13}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", licenseRegex)
            if !predicate.evaluate(with: licenseTrimmed) {
                validationErrors["Licence No."] = "Licence No. must be 2 letters followed by 13 digits."
            }
        }
        
        // Contact number validation
        let contactTrimmed = driver.driverContactNo.trimmingCharacters(in: .whitespaces)
        if contactTrimmed.isEmpty {
            validationErrors["Contact No."] = "Contact No. is required."
        } else {
            let phoneRegex = "^[0-9]{10}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            if !predicate.evaluate(with: contactTrimmed) {
                validationErrors["Contact No."] = "Contact No. must be exactly 10 digits."
            }
        }
        
        // Image validations
        if profileImage == nil {
            validationErrors["ProfileImage"] = "Profile image is required."
        }
        if licenseProofImage == nil {
            validationErrors["LicenseProof"] = "License proof is required."
        }
        
        // Exit if there are validation errors
        guard validationErrors.isEmpty else {
            return
        }
        
        // Proceed with saving
        let profile = profileImage!
        let licenseImg = licenseProofImage!
        
        isSaving = true
        
        FirebaseModules.shared.addDriver(
            driver,
            profileImage: profile,
            licenseImage: licenseImg
        ) { error in
            isSaving = false
            if let err = error {
                self.firestoreError = err.localizedDescription
            } else {
                self.showSuccessView = true
            }
        }
    }
}

struct AddDriverView_Previews: PreviewProvider {
    static var previews: some View {
        AddDriverView()
    }
}
