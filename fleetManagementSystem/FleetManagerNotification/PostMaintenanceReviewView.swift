//
//  PostMaintenanceReviewView.swift
//  fleetManagementSystem
//
//  Created by Steve on 07/05/25.
//

import SwiftUI
import PhotosUI

struct PostMaintenanceReviewView: View {
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
                
//                Text("Bill And Details")
//                    .font(.headline)
//                    .foregroundColor(.black)

                // Vehicle Number and Description
                // Bill and Vehicle Info
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
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        // Needs Review logic
                    }) {
                        Text("Needs Review")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        // Approved logic
                    }) {
                        Text("Approved")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Post Maintenance Review")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct BillItemRowView: View {
//    let item: BillItem
//
//    var body: some View {
//        HStack {
//            Text("\(item.id)").frame(width: 44, alignment: .leading)
//            Text(item.name).frame(width: 100, alignment: .leading)
//            Text("\(item.quantity)").frame(width: 60)
//            Text("₹\(item.price)").frame(width: 60, alignment: .trailing)
//        }
//        .font(.subheadline)
//        .foregroundColor(Color(hex: "#396BAF"))
//    }
//}

//struct SummaryRow: View {
//    var label: String
//    var value: String
//    var isBold: Bool = false
//
//    var body: some View {
//        HStack {
//            Text(label).font(isBold ? .headline : .subheadline)
//            Spacer()
//            Text(value).font(isBold ? .headline : .subheadline)
//        }
//        .foregroundColor(Color(hex: "#396BAF"))
//    }
//}

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
//            }
//
//            PhotosPicker(selection: $selectedItem, matching: .images) {
//                VStack {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.largeTitle)
//                    Text("Upload")
//                        .font(.subheadline)
//                }
//                .foregroundColor(Color(hex: "#396BAF"))
//                .frame(maxWidth: .infinity, minHeight: 100)
//                .background(Color(hex: "#EDF2FC"))
//                .cornerRadius(12)
//            }
//            .onChange(of: selectedItem) { newItem in
//                Task {
//                    if let data = try? await newItem?.loadTransferable(type: Data.self),
//                       let uiImage = UIImage(data: data) {
//                        selectedImage = uiImage
//                    }
//                }
//            }
//        }
//    }
//}

struct PostMaintenanceReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostMaintenanceReviewView()
        }
    }
}


