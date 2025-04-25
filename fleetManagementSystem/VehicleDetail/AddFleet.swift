//
//  AddFleet.swift
//  Fleet_Management
//
//  Created by user@89 on 24/04/25.
//

//import SwiftUI
//
//struct AddFleetVehicleView: View {
//    @State private var vehicle = FleetVehicle(
//        vehicleNo: "",
//        modelName: "",
//        engineNo: "",
//        licenseRenewalDate: "",
//        distanceTravelled: "",
//        averageMileage: "",
//        vehicleCategory: .LMV
//    )
//    
//    @State private var insuranceProofImage: UIImage?
//    @State private var profileImage: UIImage?
//    @State private var selectedImage: UIImage?
//    @State private var showingImagePicker = false
//    @State private var showingVehicleTypePicker = false
//    @State private var showingSaveAlert = false
//    @State private var validationErrors: [String: String] = [:]
//    @FocusState private var focusedField: Field?
//
//    enum Field {
//        case vehicleNo, modelName, engineNo, licenceRenewedDate, distanceTravelled, averageMileage
//    }
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 24) {
//                    profileUploadSection
//                    vehicleDetailsContainer
//                    insuranceUploadSection
//                    addFleetButton
//                }
//                .padding(.horizontal, 16)
//                .padding(.bottom, 24)
//            }
//            .sheet(isPresented: $showingImagePicker) {
//                ImagePicker(image: $selectedImage)
//            }
//            .alert(isPresented: $showingSaveAlert) {
//                Alert(
//                    title: Text("Vehicle Added"),
//                    message: Text("\(vehicle.vehicleNo) has been added to the fleet."),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//        }
//    }
//
//    private var profileUploadSection: some View {
//        ZStack(alignment: .bottomTrailing) {
//            Circle()
//                .fill(Color.gray.opacity(0.2))
//                .frame(width: 120, height: 120)
//                .overlay(
//                    Image(systemName: "camera.viewfinder")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(Color(hex: "#396BAF"))
//                )
//
//            Button(action: { showingImagePicker = true }) {
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 32, height: 32)
//                    .overlay(
//                        Image(systemName: "pencil")
//                            .foregroundColor(Color(hex: "#396BAF"))
//                    )
//                    .shadow(radius: 2)
//            }
//        }
//        .padding(.top, 32)
//        .padding(.bottom, 16)
//    }
//
//    private var vehicleDetailsContainer: some View {
//        VStack(spacing: 6) {
//            Text("Vehicle Details")
//                .font(.headline)
//                .foregroundColor(Color(hex: "#396BAF"))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.leading, 2)
//                .fontWeight(.bold)
//
//            ZStack {
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.white)
//                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//
//                VStack(spacing: 16) {
//                    inputRow(title: "Vehicle No.", text: $vehicle.vehicleNo, field: .vehicleNo)
//                    Divider()
//                    inputRow(title: "Model Name", text: $vehicle.modelName, field: .modelName)
//                    Divider()
//                    inputRow(title: "Engine No.", text: $vehicle.engineNo, field: .engineNo)
//                    Divider()
//                    inputRow(title: "Licence Renewed Date", text: $vehicle.licenceRenewedDate, field: .licenceRenewedDate)
//                    Divider()
//                    inputRow(title: "Distance Travelled", text: $vehicle.distanceTravelled, field: .distanceTravelled)
//                    Divider()
//                    inputRow(title: "Avg. Mileage", text: $vehicle.averageMileage, field: .averageMileage)
//                    Divider()
//                    vehicleTypeRow
//                }
//                .padding(.vertical, 12)
//                .padding(.horizontal, 16)
//            }
//        }
//        .padding(.horizontal)
//    }
//
//    private func inputRow(title: String, text: Binding<String>, field: Field, keyboard: UIKeyboardType = .default) -> some View {
//        HStack(alignment: .top, spacing: 16) {
//            Text(title)
//                .foregroundColor(Color(hex: "#396BAF"))
//                .font(.subheadline)
//                .frame(width: 120, alignment: .leading)
//
//            VStack(alignment: .leading, spacing: 4) {
//                TextField("Enter \(title.lowercased())", text: text)
//                    .keyboardType(keyboard)
//                    .focused($focusedField, equals: field)
//                    .font(.body)
//
//                if let error = validationErrors[title] {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//            }
//        }
//        .frame(height: 40)
//    }
//
//    private var vehicleTypeRow: some View {
//        HStack(spacing: 16) {
//            Text("Vehicle Type")
//                .foregroundColor(Color(hex: "#396BAF"))
//                .font(.subheadline)
//                .frame(width: 120, alignment: .leading)
//
//            Button(action: {
//                showingVehicleTypePicker = true
//            }) {
//                HStack {
//                    Text(vehicle.vehicleCategory == .HMV ? "HMV" : "LMV")
//                        .foregroundColor(.black)
//                    Spacer()
//                    Image(systemName: "chevron.down")
//                        .foregroundColor(.gray)
//                }
//                .padding(.vertical, 8)
//                .padding(.horizontal, 12)
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//            }
//            .actionSheet(isPresented: $showingVehicleTypePicker) {
//                ActionSheet(
//                    title: Text("Select Vehicle Type"),
//                    buttons: [
//                        .default(Text("LMV")) { vehicle.vehicleCategory = .LMV },
//                        .default(Text("HMV")) { vehicle.vehicleCategory = .HMV },
//                        .cancel()
//                    ]
//                )
//            }
//        }
//        .frame(height: 40)
//    }
//
//    private var insuranceUploadSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Insurance Proof")
//                .font(.headline)
//                .foregroundColor(Color(hex: "#396BAF"))
//                .padding(.leading, 4)
//
//            Button(action: { showingImagePicker = true }) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color.white)
//                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                        .frame(height: 150)
//
//                    VStack(spacing: 12) {
//                        Image(systemName: "arrow.up.doc")
//                            .font(.system(size: 32))
//                            .foregroundColor(Color(hex: "#396BAF"))
//                        Text("Upload Insurance Image")
//                            .foregroundColor(Color(hex: "#396BAF"))
//                            .font(.subheadline)
//                    }
//                }
//            }
//        }
//        .padding(.horizontal)
//    }
//
//    private var addFleetButton: some View {
//        Button(action: validateAndSave) {
//            Text("Add To Fleet")
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color(hex: "#396BAF"))
//                .foregroundColor(.white)
//                .font(.headline)
//                .cornerRadius(12)
//        }
//        .padding(.horizontal)
//        .padding(.top, 8)
//    }
//
//    private func validateAndSave() {
//        validationErrors.removeAll()
//
//        if vehicle.vehicleNo.isEmpty { validationErrors["Vehicle No."] = "Required" }
//        if vehicle.modelName.isEmpty { validationErrors["Model Name"] = "Required" }
//        if vehicle.engineNo.isEmpty { validationErrors["Engine No."] = "Required" }
//        if vehicle.licenceRenewedDate.isEmpty { validationErrors["Licence Renewed Date"] = "Required" }
//        if vehicle.distanceTravelled.isEmpty { validationErrors["Distance Travelled"] = "Required" }
//        if vehicle.averageMileage.isEmpty { validationErrors["Avg. Mileage"] = "Required" }
//
//        if validationErrors.isEmpty {
//            showingSaveAlert = true
//        }
//    }
//    
//    
//}
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//    @Environment(\.presentationMode) private var presentationMode
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController,
//                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let uiImage = info[.originalImage] as? UIImage {
//                parent.image = uiImage
//            }
//
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//}
//
//
//
//// Preview
//struct AddFleetVehicleView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddFleetVehicleView()
//    }
//}


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
    @State private var showingSaveAlert = false
    @State private var validationErrors: [String: String] = [:]
    @State private var showingVehicleTypePicker = false

    @FocusState private var focusedField: Field?
    
    enum Field {
        case vehicleNo, modelName, engineNo, distanceTravelled, averageMileage
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileUploadSection
                    vehicleDetailsContainer
                    insuranceUploadSection
                    addFleetButton
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .sheet(isPresented: $showingImagePickerForVehicle) {
                ImagePicker(selectedImage: $vehicle.vehiclePhoto)
            }
            .sheet(isPresented: $showingImagePickerForInsurance) {
                ImagePicker(selectedImage: $vehicle.insuranceProofImage)
            }
            .alert(isPresented: $showingSaveAlert) {
                Alert(
                    title: Text("Vehicle Added"),
                    message: Text("\(vehicle.vehicleNo) has been added to the fleet."),
                    dismissButton: .default(Text("OK"))
                )
            }
           
        }
    }

    private var profileUploadSection: some View {
        ZStack(alignment: .bottomTrailing) {
            if let photo = vehicle.vehiclePhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
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
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "pencil")
                            .foregroundColor(Color(hex: "#396BAF"))
                    )
                    .shadow(radius: 2)
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 16)
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
                    Divider()
                    inputRow(title: "Engine No.", text: $vehicle.engineNo, field: .engineNo)
                    Divider()
                    datePickerRow
                    Divider()
                    inputDoubleRow(title: "Distance Travelled", value: $vehicle.distanceTravelled, field: .distanceTravelled)
                    Divider()
                    inputDoubleRow(title: "Avg. Mileage", value: $vehicle.averageMileage, field: .averageMileage)
                    Divider()
                    vehicleCategoryPicker
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
        }
        .padding(.horizontal)
    }

    private func inputRow(title: String, text: Binding<String>, field: Field) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(title)
                .foregroundColor(Color(hex: "#396BAF"))
                .frame(width: 120, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                TextField("Enter \(title.lowercased())", text: text)
                    .focused($focusedField, equals: field)

                if let error = validationErrors[title] {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .frame(height: 40)
    }

    private func inputDoubleRow(title: String, value: Binding<Double>, field: Field) -> some View {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        return HStack(alignment: .top, spacing: 16) {
            Text(title)
                .foregroundColor(Color(hex: "#396BAF"))
                .frame(width: 120, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                TextField("Enter \(title.lowercased())", value: value, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: field)

                if let error = validationErrors[title] {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .frame(height: 40)
    }

    private var datePickerRow: some View {
        HStack(spacing: 16) {
            Text("License Date")
                .foregroundColor(Color(hex: "#396BAF"))
                .frame(width: 120, alignment: .leading)

            DatePicker("", selection: $vehicle.licenseRenewalDate, displayedComponents: .date)
                .labelsHidden()
        }
        .frame(height: 40)
    }

    private var vehicleCategoryPicker: some View {
        HStack(spacing: 16) {
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
        }
        .padding(.horizontal)
    }

    private var addFleetButton: some View {
        Button(action: validateAndSave) {
            Text("Add To Fleet")
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

        if vehicle.vehicleNo.isEmpty { validationErrors["Vehicle No."] = "Required" }
        if vehicle.modelName.isEmpty { validationErrors["Model Name"] = "Required" }
        if vehicle.engineNo.isEmpty { validationErrors["Engine No."] = "Required" }
        if vehicle.distanceTravelled == 0 { validationErrors["Distance Travelled"] = "Required" }
        if vehicle.averageMileage == 0 { validationErrors["Avg. Mileage"] = "Required" }

        if validationErrors.isEmpty {
            showingSaveAlert = true
        }
    }
    
}


struct AddFleetVehicleView_Preview: PreviewProvider {
    static var previews: some View {
       AddFleetVehicleView()
    }
}

