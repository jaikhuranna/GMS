import SwiftUI

struct AddDriverView: View {
    @State private var driver = Driver(
        driverName: "",
        driverExperience: "",
        driverImage: "",
        driverAge: "",
        licenseNo: "",
        contactNo: "",
        licenseType: .LMV
    )
    
    @State private var licenseProofImage: UIImage?
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingSaveAlert = false
    @State private var validationErrors: [String: String] = [:]
    @FocusState private var focusedField: Field?
    @State private var showingLicenseTypePicker = false

    enum Field {
        case name, age, experience, licenseNo, contactNo
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileUploadSection
                    driverDetailsContainer
                    licenseUploadSection
                    addDriverButton
                }
                .padding(.bottom, 24)
                .padding(.horizontal, 16)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .alert(isPresented: $showingSaveAlert) {
                Alert(
                    title: Text("Driver Added"),
                    message: Text("\(driver.driverName) has been added to the fleet."),
                    dismissButton: .default(Text("OK"))
                )
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
                                .foregroundColor(Color(hex: "#396BAF"))
                        }
                    }
                )
            
            Button(action: { showingImagePicker = true }) {
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
                    inputRow(title: "Age", text: $driver.driverAge, field: .age, keyboard: .numberPad)
                    Divider()
                    
                    // License No row
                    inputRow(title: "Licence No.", text: $driver.licenseNo, field: .licenseNo)
                    Divider()
                    
                    // Contact No row
                    inputRow(title: "Contact No.", text: $driver.contactNo, field: .contactNo, keyboard: .phonePad)
                    Divider()
                    
                    // Experience row
                    inputRow(title: "Experience", text: $driver.driverExperience, field: .experience)
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
                    Text(driver.licenseType == .HMV ? "HMV" : "LMV")
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
                        .default(Text("LMV")) { driver.licenseType = .LMV },
                        .default(Text("HMV")) { driver.licenseType = .HMV },
                        .cancel()
                    ]
                )
            }
        }
        .frame(height: 40)
    }

    private var licenseUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Licence Proof")
                .font(.headline)
                .foregroundColor(Color(hex: "#396BAF"))
                .padding(.leading, 4)
            
            
            Button(action: { showingImagePicker = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .frame(height: 150)
                    
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
        .padding(.horizontal)
    }

    private var addDriverButton: some View {
        Button(action: validateAndSave) {
            Text("Add Driver")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#396BAF"))
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func validateAndSave() {
        validationErrors.removeAll()

        if driver.driverName.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["Name"] = "Name is required."
        }
        if driver.driverAge.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["Age"] = "Age is required."
        }
        if driver.licenseNo.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["Licence No."] = "Licence No. is required."
        }
        if driver.contactNo.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["Contact No."] = "Contact No. is required."
        }
        if driver.driverExperience.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["Experience"] = "Experience is required."
        }

        if validationErrors.isEmpty {
            showingSaveAlert = true
        }
    }
}

struct AddDriverView_Previews: PreviewProvider {
    static var previews: some View {
        AddDriverView()
    }
}
