

//import SwiftUI
//import PhotosUI
//import FirebaseFirestore
//import FirebaseStorage
//
//struct ScheduledDetailsView: View {
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
//                                    print("✅ Status successfully updated to 'ongoing'")
//                                }
//                            }
//                    } label: {
//                        Text("Start Now")
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
//        .navigationTitle("Upcoming Tasks")
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
//struct BillItemRowView1: View {
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
//struct SummaryRow1: View {
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
//struct ScheduledDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ScheduledDetailsView(billId: "0C2A738B-FC4D-4AE0-8F53-CC8BD27B3361")
//        }
//    }
//}

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct ScheduledDetailsView: View {
    let billId: String
    @State private var request: BillRequest?
    @State private var imageURLs: [String] = []
    @State private var showTaskInProgressAlert: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let req = request {
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
                                SummaryRow1(label: "Service Charge", value: "₹\(req.summary.serviceCharge)")
                                SummaryRow1(label: "GST", value: "₹\(req.summary.gst)")
                                Divider().padding(.vertical, 4)
                                SummaryRow1(label: "Total", value: "₹\(req.summary.total)", isBold: true)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#F5F8FF"))
                    .cornerRadius(12)
                    
                    // Start Now Button
                    Button {
                        FirebaseModules.shared.uploadScheduledMaintenanceImages(billId: billId, images: []) { error in
                            if let error = error {
                                print("❌ Failed to update status:", error.localizedDescription)
                            } else {
                                print("✅ Status successfully updated to 'ongoing'")
                                showTaskInProgressAlert = true
                            }
                        }
                    } label: {
                        Text("Start Now")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "#55DA66"))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    .padding(.top, 16)
                    .alert(" Now the task is in progress.", isPresented: $showTaskInProgressAlert) {
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
        .navigationTitle("Upcoming Tasks")
        .onAppear {
            let db = Firestore.firestore()

            db.collection("pendingBills").document(billId).getDocument { snap, error in
                guard let doc = snap, doc.exists, let bill = BillRequest.from(doc) else {
                    print("❌ Could not load bill for ID: \(billId)")
                    return
                }

                self.request = bill

                db.collection("maintenanceTasks")
                    .whereField("vehicleNo", isEqualTo: bill.vehicleNo)
                    .whereField("taskName", isEqualTo: bill.taskName)
                    .getDocuments { snapshot, error in
                        if let docs = snapshot?.documents, let taskDoc = docs.first {
                            if let urls = taskDoc.data()["imageURLs"] as? [String] {
                                self.imageURLs = urls
                                print("✅ Found imageURLs:", urls)
                            } else {
                                print("⚠️ No imageURLs in maintenanceTasks")
                            }
                        } else {
                            print("❌ No matching maintenanceTasks for vehicle: \(bill.vehicleNo) and task: \(bill.taskName)")
                        }
                    }
            }
        }
    }
}

struct BillItemRowView1: View {
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

struct SummaryRow1: View {
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

struct ScheduledDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduledDetailsView(billId: "0C2A738B-FC4D-4AE0-8F53-CC8BD27B3361")
        }
    }
}
