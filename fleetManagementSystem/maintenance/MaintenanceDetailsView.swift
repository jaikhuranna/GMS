//
//  MaintenanceDetailsView.swift
//  Fleet_Inventory_Screen
//
//  Created by user@89 on 02/05/25.
//

import SwiftUI
import PhotosUI


struct MaintenanceDetailsView: View {
    @State private var preMaintenanceImage: UIImage?
    @State private var postMaintenanceImage: UIImage?
    @State private var preImageItem: PhotosPickerItem?
    @State private var postImageItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Pre Maintenance Image
                Text("Pre Maintenance Images")
                    .font(.headline)
                    .foregroundColor(.black)

                ImageUploadView(selectedImage: $preMaintenanceImage, selectedItem: $preImageItem)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Bill And Details")
                        .font(.headline)
                        .foregroundColor(.black)

                    VStack(alignment: .leading, spacing: 16) { // Increased spacing here
                        Text("Vehicle Number : GH 89 YG 2345")
                            .font(.body)
                            .foregroundColor(Color(hex: "#396BAF"))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Regular Check Up Task")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#396BAF"))
                            Text("The tires need to be changed ")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }

                        VStack(spacing: 12) { // Spaced table section
                            HStack {
                                Text("S.No").bold().frame(width: 44, alignment: .leading)
                                Text("Name").bold().frame(width: 110, alignment: .leading)
                                Text("Quantity").bold().frame(width: 70)
                                Text("Price").bold().frame(width: 60, alignment: .trailing)
                            }
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#396BAF"))

                            Divider()

                            ForEach(billItems) { item in
                                BillItemRowView(item: item)
                            }
                        }

                        VStack(spacing: 8) { // Spaced summary section
                            SummaryRow(label: "Service Charge", value: "₹500")
                            SummaryRow(label: "GST 18%", value: "₹1512")
                            Divider()
                            SummaryRow(label: "Total", value: "₹9912", isBold: true)
                        }
                    }
                    .padding()
                    .background(Color(hex: "#EDF2FC"))
                    .cornerRadius(10)
                }


                // Post Maintenance Image
                Text("Post Maintenance Images")
                    .font(.headline)
                    .foregroundColor(.black)

                ImageUploadView(selectedImage: $postMaintenanceImage, selectedItem: $postImageItem)

                // Submit Button
                Button(action: {
                    // Send for review logic
                }) {
                    Text("Send For Review")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Maintenance Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BillItemRowView: View {
    let item: BillItem

    var body: some View {
        HStack {
            Text("\(item.id)").frame(width: 44, alignment: .leading)
            Text(item.name).frame(width: 100, alignment: .leading)
            Text("\(item.quantity)").frame(width: 60)
            Text("₹\(item.price)").frame(width: 60, alignment: .trailing)
        }
        .font(.subheadline)
        .foregroundColor(Color(hex: "#396BAF"))
    }
}

struct SummaryRow: View {
    var label: String
    var value: String
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(label).font(isBold ? .headline : .subheadline)
            Spacer()
            Text(value).font(isBold ? .headline : .subheadline)
        }
        .foregroundColor(Color(hex: "#396BAF"))
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
            }

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

struct MaintenanceDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MaintenanceDetailsView()
        }
    }
}

//import SwiftUI
//import PhotosUI
//import FirebaseFirestore
//import FirebaseStorage
//
//struct OngoingBillView: View {
//    let billId: String
//    @State private var request: BillRequest?
//    @State private var imageURLs: [String] = []
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                if let req = request {
//                    Text("Pre Maintenance Images")
//                        .font(.title3)
//                        .foregroundColor(Color(hex: "#396BAF"))
//
//                    let cleanedImageURLs = imageURLs.map { $0.replacingOccurrences(of: ":443", with: "") }
//
//                                       LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//                                           ForEach(cleanedImageURLs, id: \.self) { urlString in
//                                               if let url = URL(string: urlString) {
//                                                   AsyncImage(url: url) { phase in
//                                                       switch phase {
//                                                       case .empty:
//                                                           ProgressView().frame(height: 100)
//                                                       case .success(let image):
//                                                           image
//                                                               .resizable()
//                                                               .scaledToFill()
//                                                               .frame(height: 100)
//                                                               .clipped()
//                                                               .cornerRadius(8)
//                                                       case .failure:
//                                                           Color.red.frame(height: 100).cornerRadius(8)
//                                                       @unknown default:
//                                                           Color.gray.frame(height: 100)
//                                                       }
//                                                   }
//                                               } else {
//                                                   Color.red.frame(height: 100).cornerRadius(8)
//                                               }
//                                           }
//                                       }
//
//
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
//                                SummaryRow1(label: "Service Charge", value: "₹\(req.summary.serviceCharge)")
//                                SummaryRow1(label: "GST", value: "₹\(req.summary.gst)")
//                                Divider().padding(.vertical, 4)
//                                SummaryRow1(label: "Total", value: "₹\(req.summary.total)", isBold: true)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color(hex: "#F5F8FF"))
//                    .cornerRadius(12)
//                    
//                    // Start Now Button
//                    Button {
//                        // Action can be implemented here
////                        print("Start Now tapped")
//                        FirebaseModules.shared.uploadScheduledMaintenanceImages(billId: billId, images: []) { error in
//                                if let error = error {
//                                    print("❌ Failed to update status:", error.localizedDescription)
//                                } else {
//                                    print("✅ Status successfully updated to 'in review'")
//                                }
//                            }
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
//
//                } else {
//                    ProgressView("Loading task...")
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("On Going Tasks")
//        .onAppear {
//            let db = Firestore.firestore()
//
//            db.collection("pendingBills").document(billId).getDocument { snap, error in
//                guard let doc = snap, doc.exists, let bill = BillRequest.from(doc) else {
//                    print("❌ Could not load bill for ID: \(billId)")
//                    return
//                }
//
//                self.request = bill
//
//                db.collection("maintenanceTasks")
//                    .whereField("vehicleNo", isEqualTo: bill.vehicleNo)
//                    .whereField("taskName", isEqualTo: bill.taskName)
//                    .getDocuments { snapshot, error in
//                        if let docs = snapshot?.documents, let taskDoc = docs.first {
//                            if let urls = taskDoc.data()["imageURLs"] as? [String] {
//                                self.imageURLs = urls
//                                print("✅ Found imageURLs:", urls)
//                            } else {
//                                print("⚠️ No imageURLs in maintenanceTasks")
//                            }
//                        } else {
//                            print("❌ No matching maintenanceTasks for vehicle: \(bill.vehicleNo) and task: \(bill.taskName)")
//                        }
//                    }
//            }
//        }
//
//    }
//}
//
//struct BillItemRowView3: View {
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
//struct SummaryRow3: View {
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
//struct OnGoingDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            OngoingBillView(billId: "0C2A738B-FC4D-4AE0-8F53-CC8BD27B3361")
//        }
//    }
//}
//
