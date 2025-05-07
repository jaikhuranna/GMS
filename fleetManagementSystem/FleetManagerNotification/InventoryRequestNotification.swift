//
//  InventoryRequestNotification.swift
//  fleetManagementSystem
//
//  Created by Steve on 07/05/25.
//

import SwiftUI

struct InventoryRequestNotification: View {
    
    // Sample static data; assume BillItem model is already defined elsewhere
    let billItems: [BillItem] = [
        BillItem(id: 1, name: "Tires", quantity: 4, price: 2000)
    ]
    
    var totalPrice: Int {
        billItems.reduce(0) { $0 + ($1.quantity * $1.price) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
//                Text("Inventory Order Request")
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.red)
                
                Text("Generated Bill")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#396BAF"))
                
                // Table View
                VStack(spacing: 12) {
                    HStack {
                        Text("S.No").bold().frame(width: 60, alignment: .leading)
                        Text("Name").bold().frame(width: 100, alignment: .leading)
                        Text("Quantity").bold().frame(width: 70, alignment: .center)
                        Text("Price").bold().frame(width: 74, alignment: .trailing)
                    }
                    .font(.body)
                    .foregroundColor(Color(hex: "#396BAF"))

                    Divider()
                    
                    ForEach(billItems) { item in
                        HStack {
                            Text("\(item.id)").frame(width: 60, alignment: .leading)
                            Text(item.name).frame(width: 100, alignment: .leading)
                            Text("\(item.quantity)").frame(width: 70, alignment: .center)
                            Text("₹\(item.price)").frame(width: 74, alignment: .trailing)
                        }
                        .foregroundColor(Color(hex: "#396BAF"))
                    }
                    
                    Divider()
                    
                    HStack {
                        Spacer()
                        Text("Total")
                            .bold()
                        Text("₹\(totalPrice)")
                            .bold()
                            .frame(width: 72, alignment: .trailing)
                    }
                    .foregroundColor(Color(hex: "#396BAF"))
                }
                .padding()
                .background(Color(hex: "#EDF2FC"))
                .cornerRadius(10)
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        // Reject action
                    }) {
                        Text("Decline")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        // Order action
                    }) {
                        Text("Order")
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
        .navigationTitle("Inventory Order Request")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct InventoryRequestNotification_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InventoryRequestNotification()
        }
    }
}


