//
//  GeneratedBillView.swift
//  Fleet_Inventory_Screen
//
//  Created by user@89 on 01/05/25.
//

import SwiftUI

struct GeneratedBillView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Vehicle Info Box
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vehicle Number: GH 89 YG 2345\n")
                        .font(.body)
                        .foregroundColor(Color(hex: "#396BAF"))
                    
                    Text("Regular Check Up Task:")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#396BAF"))

                    Text("The tires need to be changed")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 144, alignment: .leading)
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // Table Box
                VStack(spacing: 8) {
                    HStack {
                        Text("S.No").bold()
                            .frame(width: 44, alignment: .leading)

                        Text("Name").bold()
                            .frame(width: 120, alignment: .leading)

                        Text("Quantity").bold()
                            .frame(width: 70, alignment: .center)

                        Text("Price").bold()
                            .frame(width: 70, alignment: .trailing)
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                
                    Divider()

                    ForEach(billItems) { item in
                        HStack {
                            Text("\(item.id)")
                                .frame(width: 44, alignment: .leading)

                            Text(item.name)
                                .frame(width: 120, alignment: .leading)

                            Text("\(item.quantity)")
                                .frame(width: 70, alignment: .center)

                            Text("₹\(item.price)")
                                .frame(width: 70, alignment: .trailing)
                        }
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // Charges Summary Box
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Service Charge")
                        Spacer()
                        Text("₹500")
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                
                    HStack {
                        Text("GST 18%")
                        Spacer()
                        Text("₹1512")
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                
                    Divider()
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("₹9912")
                            .font(.headline)
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)

                // Send for Approval Button
                Button(action: {
                    // Send for approval logic
                }) {
                    Text("Send For Approval")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Generated Bill")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct GeneratedBillView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GeneratedBillView()
        }
    }
}


