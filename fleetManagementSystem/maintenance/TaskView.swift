import SwiftUI
import PhotosUI
import FirebaseCore



struct TaskView: View {
    @State private var vehicleNumber = ""
    @State private var taskName = ""
    @State private var description = ""
    @State private var parts: [Part] = [Part()]
    @State private var fluids: [Part] = [Part()]
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isSaving = false
    @State private var showGeneratedBill = false
    @State private var inventoryItems: [InventoryItem] = []
    @State private var shouldClearForm = false
    @State private var navigateToRoot = false
    
    // Add environment object to access parent navigation
    @Environment(\.presentationMode) var presentationMode
    
    // Vehicle number validation
    private var isVehicleNumberValid: Bool {
        let pattern = "^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(vehicleNumber.startIndex..., in: vehicleNumber)
        return regex?.firstMatch(in: vehicleNumber, range: range) != nil
    }
    
    private var isFormValid: Bool {
        return isVehicleNumberValid && !taskName.isEmpty
    }
    
    // Clear form function
    private func clearForm() {
        vehicleNumber = ""
        taskName = ""
        description = ""
        parts = [Part()]
        fluids = [Part()]
        selectedItems = []
        selectedImages = []
        shouldClearForm = false
    }

    @ViewBuilder
    private func generateBillSection() -> some View {
        VStack(spacing: 8) {
            Button(action: saveTaskToFirebase) {
                Text(isSaving ? "Saving..." : "Generate Bill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color(hex: "#396BAF") : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isSaving || !isFormValid)
            
        }
        .padding(.top, 20)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    CenteredHeader(title: "Maintenance Card")
                    
                    // Vehicle Number field with validation
                    VStack(alignment: .leading, spacing: 4) {
                        CustomTextField(title: "Vehicle Number", text: $vehicleNumber)
                            .onChange(of: vehicleNumber) { newValue in
                                // Convert input to uppercase
                                vehicleNumber = newValue.uppercased()
                            }
                        
                        if !vehicleNumber.isEmpty && !isVehicleNumberValid {
                            Text("Format: AA11BB1234 (2 letters, 2 numbers, 2 letters, 4 numbers)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                        }
                    }
                    
                    CustomTextField(title: "Task Name", text: $taskName)

                    sectionDivider()

                    // Parts Section
                    Group {
                        SectionTitle("Log Parts Needed")
                        ForEach(parts.indices, id: \.self) { index in
                            VStack(spacing: 12) {
                                //MARK: Adding dropdown
                                Menu {
                                    ForEach(inventoryItems.filter { $0.type == .part }, id: \.name) { item in
                                        Button(item.name) {
                                            parts[index].name = item.name
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(parts[index].name.isEmpty ? "Select Part" : parts[index].name)
                                            .foregroundColor(parts[index].name.isEmpty ? .gray : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }

                                quantityControl(index: index, isPart: true)
                                
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(10)
                        }
                        CenteredAddMoreButton {
                            parts.append(Part())
                        }
                    }

                    sectionDivider()

                    // Fluids Section
                    Group {
                        SectionTitle("Log Fluids Needed")
                        ForEach(fluids.indices, id: \.self) { index in
                            VStack(spacing: 12) {
                                //MARK: Adding dropdown
                                Menu {
                                    ForEach(inventoryItems.filter { $0.type == .fluid }, id: \.name) { item in
                                        Button(item.name) {
                                            fluids[index].name = item.name
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(fluids[index].name.isEmpty ? "Select Fluid" : fluids[index].name)
                                            .foregroundColor(fluids[index].name.isEmpty ? .gray : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }

                                quantityControl(index: index, isPart: false)
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.2))
                            .cornerRadius(10)
                        }
                        CenteredAddMoreButton {
                            fluids.append(Part())
                        }
                    }

                    sectionDivider()

                    // Description
                    descriptionSection()

                    // Images
                    imageUploadSection()

                    // Generate Bill
                    generateBillSection()
                    .padding(.top, 20)
                }
                
                .padding()
            }
            .blur(radius: isSaving ? 3 : 0)
            .allowsHitTesting(!isSaving)
            
            // Loading overlay
            if isSaving {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Generating bill...")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground).opacity(0.9))
                        .shadow(radius: 10)
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            FirebaseModules.shared.fetchInventoryItems { items in
                self.inventoryItems = items
            }
        }
        .onChange(of: shouldClearForm) { newValue in
            if newValue {
                clearForm()
            }
        }
        .onChange(of: navigateToRoot) { newValue in
            if newValue {
                // Pop to root view
                presentationMode.wrappedValue.dismiss()
                navigateToRoot = false
            }
        }
        .navigationDestination(isPresented: $showGeneratedBill) {
            let bill = BillSummary(parts: parts, fluids: fluids, inventory: inventoryItems)
            GeneratedBillView(
                vehicleNo: vehicleNumber,
                taskName: taskName,
                description: description,
                bill: bill,
                shouldClearForm: $shouldClearForm,
                navigateToRoot: $navigateToRoot
            )
        }
        .navigationTitle("Add New Task")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Quantity Control with Buttons
    private func quantityControl(index: Int, isPart: Bool) -> some View {
        let binding = isPart ? $parts[index].quantity : $fluids[index].quantity
        return HStack(spacing: 10) {
            Text("Quantity")
                .font(.system(size: 16))
            Spacer()
            HStack(spacing: 8) {
                Button(action: {
                    let current = Int(binding.wrappedValue) ?? 0
                    if current > 0 {
                        binding.wrappedValue = String(current - 1)
                    }
                }) {
                    Text("-")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                }

                Text(binding.wrappedValue.isEmpty ? "1" : binding.wrappedValue)
                    .frame(minWidth: 20, alignment: .center)

                Button(action: {
                    let current = Int(binding.wrappedValue) ?? 0
                    binding.wrappedValue = String(current + 1)
                }) {
                    Text("+")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    // MARK: - Description Section
    private func descriptionSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Short Description")
                .font(.headline)
                .foregroundColor(Color(hex: "#396BAF"))

            TextEditor(text: $description)
                .frame(height: 120)
                .padding()
                .font(.system(size: 16))
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - Image Upload
    private func imageUploadSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionTitle("Pre Maintenance Images")

            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            imagePreviewCell(image: selectedImages[index], index: index)
                        }

                        if selectedImages.count < 4 {
                            multiUploadButton()
                        }
                    }
                }
            } else {
                multiUploadButton()
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#EDF2FC"))
                    .cornerRadius(10)
            }
        }
    }

    private func multiUploadButton() -> some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 4 - selectedImages.count,
            matching: .images
        ) {
            VStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 28))
                Text("Upload")
                    .font(.subheadline)
            }
            .frame(width: 80, height: 80)
            .foregroundColor(Color(hex: "#396BAF"))
            .background(Color(hex: "#EDF2FC"))
            .cornerRadius(10)
        }
        .onChange(of: selectedItems) { newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        if selectedImages.count < 4 {
                            selectedImages.append(uiImage)
                        }
                    }
                }
                selectedItems.removeAll()
            }
        }
    }

    private func imagePreviewCell(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .clipped()

            Button(action: {
                selectedImages.remove(at: index)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 1)
            }
            .padding(6) // gives spacing from top and trailing edge
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private func sectionDivider() -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 1)
    }
    
    //MARK: Saving details to firebase
    private func saveTaskToFirebase() {
        isSaving = true
        let taskId = UUID().uuidString

        FirebaseModules.shared.uploadMaintenanceImages(taskId: taskId, images: selectedImages) { urls, error in
            if let error = error {
                print("❌ Image upload failed: \(error.localizedDescription)")
                isSaving = false
                return
            }

            let partsData = parts
                .filter { !$0.name.isEmpty }
                .map { ["name": $0.name, "quantity": Int($0.quantity) ?? 1] }

            let fluidsData = fluids
                .filter { !$0.name.isEmpty }
                .map { ["name": $0.name, "quantity": Int($0.quantity) ?? 1] }

            let taskData: [String: Any] = [
                "taskId": taskId,
                "vehicleNo": vehicleNumber,
                "taskName": taskName,
                "description": description,
                "timestamp": Timestamp(date: Date()),
                "parts": partsData,
                "fluids": fluidsData,
                "imageURLs": urls
            ]

            FirebaseModules.shared.addMaintenanceTask(taskData, taskId: taskId) { error in
                isSaving = false
                if let error = error {
                    print("Failed to save task: \(error.localizedDescription)")
                } else {
                    print("Maintenance task saved.")
                    showGeneratedBill = true
                }
            }
        }
    }
}

// MARK: - Models

struct Part {
    var name: String = ""
    var quantity: String = "1"
    
}

// MARK: - Reusable Components

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        TextField(title, text: $text)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .keyboardType(keyboard)
            .font(.system(size: 16))
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

struct CenteredAddMoreButton: View {
    var action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Text("Add More +")
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#396BAF"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer()
        }
    }
}

struct CenteredHeader: View {
    var title: String
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "#396BAF"))
            Spacer()
        }
    }
}

struct SectionTitle: View {
    var text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color(hex: "#396BAF"))
    }
}

// MARK: - Preview
struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
//        NavigationView {
            TaskView()
        }
    }
}
