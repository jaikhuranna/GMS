

import SwiftUI
//import PhotosUI
//import FirebaseFirestore
//import FirebaseStorage
//
//
//
//struct OngoingDetailsView: View {
//    let billId: String
//    @State private var request: BillRequest?
//    @State private var imageURLs: [String] = []
//    @State private var postMaintenanceImages: [UIImage] = []
//    @State private var postImageItems: [PhotosPickerItem] = []
//    @State private var errorMessage: String?
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                if let error = errorMessage {
//                    // Display error message if fetching fails
//                    Text(error)
//                        .foregroundColor(.red)
//                        .font(.subheadline)
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .cornerRadius(10)
//                } else if let req = request {
//                    // Pre Maintenance Images
//                    Text("Pre Maintenance Images")
//                        .font(.title3)
//                        .foregroundColor(Color(hex: "#396BAF"))
//
//                    let cleanedImageURLs = imageURLs.map { $0.replacingOccurrences(of: ":443", with: "") }
//
//                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//                        ForEach(cleanedImageURLs, id: \.self) { urlString in
//                            if let url = URL(string: urlString) {
//                                AsyncImage(url: url) { phase in
//                                    switch phase {
//                                    case .empty:
//                                        ProgressView().frame(height: 100)
//                                    case .success(let image):
//                                        image
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(height: 100)
//                                            .clipped()
//                                            .cornerRadius(8)
//                                    case .failure:
//                                        Color.red.frame(height: 100).cornerRadius(8)
//                                    @unknown default:
//                                        Color.gray.frame(height: 100)
//                                    }
//                                }
//                            } else {
//                                Color.red.frame(height: 100).cornerRadius(8)
//                            }
//                        }
//                    }
//
//                    // Bill And Details
//                    Text("Bill And Details")
//                        .font(.title3)
//                        .foregroundColor(Color(hex: "#396BAF"))
//
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Vehicle Number: \(req.vehicleNo)")
//                            .font(.body)
//                            .foregroundColor(Color(hex: "#396BAF"))
//
//                        Text(req.taskName)
//                            .font(.body)
//                            .foregroundColor(Color(hex: "#396BAF"))
//
//                        Text(req.description)
//                            .font(.body)
//                            .foregroundColor(.red)
//
//                        VStack(spacing: 0) {
//                            HStack {
//                                Text("S.No").frame(width: 60)
//                                Text("Name").frame(minWidth: 100, alignment: .leading)
//                                Text("Quantity").frame(width: 80)
//                                Text("Price").frame(width: 60, alignment: .trailing)
//                            }
//                            .font(.subheadline)
//                            .foregroundColor(Color(hex: "#396BAF"))
//
//                            ForEach(req.summary.billItems) { item in
//                                HStack {
//                                    Text("\(item.id).").frame(width: 60)
//                                    Text(item.name).frame(minWidth: 100, alignment: .leading)
//                                    Text("\(item.quantity)").frame(width: 80)
//                                    Text("₹\(item.price)").frame(width: 60, alignment: .trailing)
//                                }
//                                .font(.body)
//                                .foregroundColor(Color(hex: "#396BAF"))
//                            }
//
//                            Divider().padding(.vertical, 8)
//
//                            VStack(spacing: 8) {
//                                SummaryRow(label: "Service Charge", value: "₹\(req.summary.serviceCharge)")
//                                SummaryRow(label: "GST", value: "₹\(req.summary.gst)")
//                                Divider().padding(.vertical, 4)
//                                SummaryRow(label: "Total", value: "₹\(req.summary.total)", isBold: true)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color(hex: "#F5F8FF"))
//                    .cornerRadius(12)
//
//                    // Post Maintenance Images
//                    Text("Post Maintenance Images")
//                        .font(.title3)
//                        .foregroundColor(Color(hex: "#396BAF"))
//
//                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
//                        ForEach(postMaintenanceImages.indices, id: \.self) { i in
//                            ZStack(alignment: .topTrailing) {
//                                Image(uiImage: postMaintenanceImages[i])
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(height: 100)
//                                    .clipped()
//                                    .cornerRadius(8)
//
//                                Button {
//                                    postMaintenanceImages.remove(at: i)
//                                } label: {
//                                    Image(systemName: "xmark.circle.fill")
//                                        .foregroundColor(.red)
//                                        .padding(4)
//                                }
//                            }
//                        }
//
//                        if postMaintenanceImages.count < 4 {
//                            PhotosPicker(selection: $postImageItems, maxSelectionCount: 1, matching: .images) {
//                                ZStack {
//                                    Rectangle()
//                                        .fill(Color(hex: "#EDF2FC"))
//                                        .frame(height: 100)
//                                        .cornerRadius(8)
//                                    VStack {
//                                        Image(systemName: "plus.circle")
//                                            .font(.title)
//                                        Text("Upload")
//                                            .font(.caption)
//                                    }
//                                    .foregroundColor(Color(hex: "#396BAF"))
//                                }
//                            }
//                            .onChange(of: postImageItems) { items in
//                                guard let item = items.first else { return }
//                                Task {
//                                    if let data = try? await item.loadTransferable(type: Data.self),
//                                       let image = UIImage(data: data) {
//                                        postMaintenanceImages.append(image)
//                                        postImageItems = [] // Clear selection to allow new uploads
//                                    }
//                                }
//                            }
//                        }
//                    }
//
//                    // Send for Review Button
//                    Button {
//                        FirebaseModules.shared.uploadPostMaintenanceImages(billId: billId, images: postMaintenanceImages) { error in
//                            if let error = error {
//                                print("❌ Failed to update status:", error.localizedDescription)
//                                self.errorMessage = "Failed to send for review: \(error.localizedDescription)"
//                            } else {
//                                print("✅ Status successfully updated to 'in Review'")
//                            }
//                        }
//                    } label: {
//                        Text("Send for Review")
//                            .font(.headline)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 18)
//                            .background(Color(hex: "#55DA66"))
//                            .foregroundColor(.white)
//                            .cornerRadius(30)
//                    }
//                    .padding(.top, 16)
//                    .disabled(postMaintenanceImages.count != 4) // Disable unless exactly 4 images
//                } else {
//                    ProgressView("Loading task...")
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Ongoing Tasks")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            fetchBillDetails()
//        }
//    }
//
//    private func fetchBillDetails() {
//        print("🔍 Fetching document with ID: \(billId)")
//        let db = Firestore.firestore()
//
//        db.collection("pendingBills").document(billId).getDocument { snap, error in
//            if let error = error {
//                print("❌ Error fetching document: \(error.localizedDescription)")
//                self.errorMessage = "Failed to load task: \(error.localizedDescription)"
//                return
//            }
//
//            guard let doc = snap, doc.exists, let bill = BillRequest.from(doc) else {
//                print("❌ Could not load bill for ID: \(billId)")
//                self.errorMessage = "Task not found."
//                return
//            }
//
//            self.request = bill
//
//            db.collection("maintenanceTasks")
//                .whereField("vehicleNo", isEqualTo: bill.vehicleNo)
//                .whereField("taskName", isEqualTo: bill.taskName)
//                .getDocuments { snapshot, error in
//                    if let error = error {
//                        print("❌ Error fetching maintenanceTasks: \(error.localizedDescription)")
//                        self.errorMessage = "Failed to load images: \(error.localizedDescription)"
//                        return
//                    }
//
//                    if let docs = snapshot?.documents, let taskDoc = docs.first {
//                        if let urls = taskDoc.data()["imageURLs"] as? [String] {
//                            self.imageURLs = urls
//                            print("✅ Found imageURLs:", urls)
//                        } else {
//                            print("⚠️ No imageURLs in maintenanceTasks")
//                            self.imageURLs = []
//                        }
//                    } else {
//                        print("❌ No matching maintenanceTasks for vehicle: \(bill.vehicleNo) and task: \(bill.taskName)")
//                        self.imageURLs = []
//                    }
//                }
//        }
//    }
//}
//
//struct BillItemRowView: View {
//    let item: BillItem
//
//    var body: some View {
//        HStack {
//            Text("\(item.id).")
//                .frame(width: 60, alignment: .leading)
//                .foregroundColor(Color(hex: "#396BAF"))
//                .font(.body)
//            
//            Text(item.name)
//                .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
//                .foregroundColor(Color(hex: "#396BAF"))
//                .font(.body)
//            
//            Text("\(item.quantity)")
//                .frame(width: 80, alignment: .center)
//                .foregroundColor(Color(hex: "#396BAF"))
//                .font(.body)
//            
//            Text("₹\(item.price)")
//                .frame(width: 60, alignment: .trailing)
//                .foregroundColor(Color(hex: "#396BAF"))
//                .font(.body)
//        }
//    }
//}
//
//struct SummaryRow: View {
//    var label: String
//    var value: String
//    var isBold: Bool = false
//
//    var body: some View {
//        HStack {
//            Text(label)
//                .font(isBold ? .headline : .body)
//                .foregroundColor(Color(hex: "#396BAF"))
//            
//            Spacer()
//            
//            Text(value)
//                .font(isBold ? .headline : .body)
//                .foregroundColor(Color(hex: "#396BAF"))
//        }
//    }
//}
//
//struct ImageUploadView: View {
//    @Binding var selectedImage: UIImage?
//    @Binding var selectedItem: PhotosPickerItem?
//
//    var body: some View {
//        VStack {
//            if let image = selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 120)
//                    .cornerRadius(12)
//                    .overlay(
//                        Button(action: {
//                            selectedImage = nil
//                            selectedItem = nil
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .font(.title)
//                                .foregroundColor(.red)
//                                .padding(6)
//                        },
//                        alignment: .topTrailing
//                    )
//            } else {
//                PhotosPicker(selection: $selectedItem, matching: .images) {
//                    VStack {
//                        Image(systemName: "square.and.arrow.up")
//                            .font(.largeTitle)
//                        Text("Upload")
//                            .font(.subheadline)
//                    }
//                    .foregroundColor(Color(hex: "#396BAF"))
//                    .frame(maxWidth: .infinity, minHeight: 100)
//                    .background(Color(hex: "#EDF2FC"))
//                    .cornerRadius(12)
//                }
//                .onChange(of: selectedItem) { newItem in
//                    Task {
//                        if let data = try? await newItem?.loadTransferable(type: Data.self),
//                           let uiImage = UIImage(data: data) {
//                            selectedImage = uiImage
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct OngoingDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            OngoingDetailsView(billId: "0C2A738B-FC4D-4AE0-8F53-CC8BD27B3361")
//        }
//    }
//}
//
//


import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct OngoingDetailsView: View {
    let billId: String
    @State private var request: BillRequest?
    @State private var imageURLs: [String] = []
    @State private var postMaintenanceImages: [UIImage] = []
    @State private var postImageItems: [PhotosPickerItem] = []
    @State private var errorMessage: String?
    @State private var showReviewSentAlert: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let error = errorMessage {
                    // Display error message if fetching fails
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                } else if let req = request {
                    // Pre Maintenance Images
                    Text("Pre Maintenance Images")
                        .font(.title3)
                        .foregroundColor(Color(hex: "#396BAF"))

                    let cleanedImageURLs = imageURLs.map { $0.replacingOccurrences(of: ":443", with: "") }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(cleanedImageURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView().frame(height: 100)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                    case .failure:
                                        Color.red.frame(height: 100).cornerRadius(8)
                                    @unknown default:
                                        Color.gray.frame(height: 100)
                                    }
                                }
                            } else {
                                Color.red.frame(height: 100).cornerRadius(8)
                            }
                        }
                    }

                    // Bill And Details
                    Text("Bill And Details")
                        .font(.title3)
                        .foregroundColor(Color(hex: "#396BAF"))

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Vehicle Number: \(req.vehicleNo)")
                            .font(.body)
                            .foregroundColor(Color(hex: "#396BAF"))

                        Text(req.taskName)
                            .font(.body)
                            .foregroundColor(Color(hex: "#396BAF"))

                        Text(req.description)
                            .font(.body)
                            .foregroundColor(.red)

                        VStack(spacing: 0) {
                            HStack {
                                Text("S.No").frame(width: 60)
                                Text("Name").frame(minWidth: 100, alignment: .leading)
                                Text("Quantity").frame(width: 80)
                                Text("Price").frame(width: 60, alignment: .trailing)
                            }
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#396BAF"))

                            ForEach(req.summary.billItems) { item in
                                HStack {
                                    Text("\(item.id).").frame(width: 60)
                                    Text(item.name).frame(minWidth: 100, alignment: .leading)
                                    Text("\(item.quantity)").frame(width: 80)
                                    Text("₹\(item.price)").frame(width: 60, alignment: .trailing)
                                }
                                .font(.body)
                                .foregroundColor(Color(hex: "#396BAF"))
                            }

                            Divider().padding(.vertical, 8)

                            VStack(spacing: 8) {
                                SummaryRow(label: "Service Charge", value: "₹\(req.summary.serviceCharge)")
                                SummaryRow(label: "GST", value: "₹\(req.summary.gst)")
                                Divider().padding(.vertical, 4)
                                SummaryRow(label: "Total", value: "₹\(req.summary.total)", isBold: true)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#F5F8FF"))
                    .cornerRadius(12)

                    // Post Maintenance Images
                    Text("Post Maintenance Images")
                        .font(.title3)
                        .foregroundColor(Color(hex: "#396BAF"))

                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(postMaintenanceImages.indices, id: \.self) { i in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: postMaintenanceImages[i])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 100)
                                    .clipped()
                                    .cornerRadius(8)

                                Button {
                                    postMaintenanceImages.remove(at: i)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .padding(4)
                                }
                            }
                        }

                        if postMaintenanceImages.count < 4 {
                            PhotosPicker(selection: $postImageItems, maxSelectionCount: 1, matching: .images) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(hex: "#EDF2FC"))
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                    VStack {
                                        Image(systemName: "plus.circle")
                                            .font(.title)
                                        Text("Upload")
                                            .font(.caption)
                                    }
                                    .foregroundColor(Color(hex: "#396BAF"))
                                }
                            }
                            .onChange(of: postImageItems) { items in
                                guard let item = items.first else { return }
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        postMaintenanceImages.append(image)
                                        postImageItems = [] // Clear selection to allow new uploads
                                    }
                                }
                            }
                        }
                    }

                    // Send for Review Button
                    Button {
                        FirebaseModules.shared.uploadPostMaintenanceImages(billId: billId, images: postMaintenanceImages) { error in
                            if let error = error {
                                print("❌ Failed to update status:", error.localizedDescription)
                                self.errorMessage = "Failed to send for review: \(error.localizedDescription)"
                            } else {
                                print("✅ Status successfully updated to 'in Review'")
                                showReviewSentAlert = true
                            }
                        }
                    } label: {
                        Text("Send for Review")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "#55DA66"))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .padding(.top, 16)
                    .disabled(postMaintenanceImages.count != 4) // Disable unless exactly 4 images
                    .alert("Your task has been sent for review", isPresented: $showReviewSentAlert) {
                        Button("OK") {
                            dismiss()
                        }
                    }
                } else {
                    ProgressView("Loading task...")
                }
            }
            .padding()
        }
        .navigationTitle("Ongoing Tasks")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchBillDetails()
        }
    }

    private func fetchBillDetails() {
        print("🔍 Fetching document with ID: \(billId)")
        let db = Firestore.firestore()

        db.collection("pendingBills").document(billId).getDocument { snap, error in
            if let error = error {
                print("❌ Error fetching document: \(error.localizedDescription)")
                self.errorMessage = "Failed to load task: \(error.localizedDescription)"
                return
            }

            guard let doc = snap, doc.exists, let bill = BillRequest.from(doc) else {
                print("❌ Could not load bill for ID: \(billId)")
                self.errorMessage = "Task not found."
                return
            }

            self.request = bill

            db.collection("maintenanceTasks")
                .whereField("vehicleNo", isEqualTo: bill.vehicleNo)
                .whereField("taskName", isEqualTo: bill.taskName)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ Error fetching maintenanceTasks: \(error.localizedDescription)")
                        self.errorMessage = "Failed to load images: \(error.localizedDescription)"
                        return
                    }

                    if let docs = snapshot?.documents, let taskDoc = docs.first {
                        if let urls = taskDoc.data()["imageURLs"] as? [String] {
                            self.imageURLs = urls
                            print("✅ Found imageURLs:", urls)
                        } else {
                            print("⚠️ No imageURLs in maintenanceTasks")
                            self.imageURLs = []
                        }
                    } else {
                        print("❌ No matching maintenanceTasks for vehicle: \(bill.vehicleNo) and task: \(bill.taskName)")
                        self.imageURLs = []
                    }
                }
        }
    }
}

struct BillItemRowView: View {
    let item: BillItem

    var body: some View {
        HStack {
            Text("\(item.id).")
                .frame(width: 60, alignment: .leading)
                .foregroundColor(Color(hex: "#396BAF"))
                .font(.body)
            
            Text(item.name)
                .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color(hex: "#396BAF"))
                .font(.body)
            
            Text("\(item.quantity)")
                .frame(width: 80, alignment: .center)
                .foregroundColor(Color(hex: "#396BAF"))
                .font(.body)
            
            Text("₹\(item.price)")
                .frame(width: 60, alignment: .trailing)
                .foregroundColor(Color(hex: "#396BAF"))
                .font(.body)
        }
    }
}

struct SummaryRow: View {
    var label: String
    var value: String
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(isBold ? .headline : .body)
                .foregroundColor(Color(hex: "#396BAF"))
            
            Spacer()
            
            Text(value)
                .font(isBold ? .headline : .body)
                .foregroundColor(Color(hex: "#396BAF"))
        }
    }
}

struct ImageUploadView: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .cornerRadius(12)
                    .overlay(
                        Button(action: {
                            selectedImage = nil
                            selectedItem = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                                .padding(6)
                        },
                        alignment: .topTrailing
                    )
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.largeTitle)
                        Text("Upload")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color(hex: "#396BAF"))
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(Color(hex: "#EDF2FC"))
                    .cornerRadius(12)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }
            }
        }
    }
}

struct OngoingDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OngoingDetailsView(billId: "0C2A738B-FC4D-4AE0-8F53-CC8BD27B3361")
        }
    }
}
