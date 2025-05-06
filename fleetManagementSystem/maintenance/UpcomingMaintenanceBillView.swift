import SwiftUI
import PhotosUI

struct UpcomingMaintenanceBillView: View {
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

                ImageUploadView1(selectedImage: $preMaintenanceImage, selectedItem: $preImageItem)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bill And Details")
                        .font(.headline)
                        .foregroundColor(.black)

                    VStack(alignment: .leading, spacing: 16) { // Increased spacing here
                        Text("Vehicle Number : GH 89 YG 2345")
                            .font(.body.bold())
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


//                // Post Maintenance Image
//                Text("Post Maintenance Images")
//                    .font(.headline)
//                    .foregroundColor(.black)
//
//                ImageUploadView(selectedImage: $postMaintenanceImage, selectedItem: $postImageItem)

                // Submit Button
                Button(action: {
                    // Send for review logic
                }) {
                    Text("Start Now")
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
        .navigationTitle("Upcoming Maintenance Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BillItemRowView1: View {
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

struct SummaryRow1: View {
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

struct ImageUploadView1: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            if let image = selectedImage {
                // Show uploaded image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
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
                // Show upload placeholder
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.largeTitle)
                        Text("Upload")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color(hex: "#396BAF"))
                    .frame(maxWidth: .infinity, minHeight: 120)
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

struct UpcomingMaintenanceBillView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UpcomingMaintenanceBillView()
        }
    }
}


