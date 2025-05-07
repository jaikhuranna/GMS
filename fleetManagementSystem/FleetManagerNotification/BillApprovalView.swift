//
//  BillApprovalView.swift
//  fleetManagementSystem
//
//  Created by Steve on 07/05/25.
//

import SwiftUI

struct BillApprovalView: View {
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

                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        // Needs Review logic
                    }) {
                        Text("Reject")
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
                        Text("Accept")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Maintenance Request Approval")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct BillApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BillApprovalView()
        }
    }
}

