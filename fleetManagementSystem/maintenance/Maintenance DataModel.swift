//
//  Maintenance DataModel.swift
//  fleetManagementSystem
//
//  Created by Steve on 30/04/25.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import Combine

// MARK: – Inventory Model
struct InventoryItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: Int
    let price: Double
    let type: ItemType
    let partID: String?  // Only relevant for parts
    
    enum ItemType: String, CaseIterable {
        case part
        case fluid
    }
    
    // Part-specific initializer
    init(name: String, quantity: Int, price: Double, partID: String) {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.type = .part
        self.partID = partID
    }
    
    // Fluid-specific initializer
    init(name: String, quantity: Int, price: Double) {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.type = .fluid
        self.partID = nil
    }
}

// MARK: – inventory Card Model
struct InventoryCard: View {
    let item: InventoryItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .bold()
                    .foregroundColor(Color(hex: "396BAF"))
                    .font(.headline)
                
                if let partID = item.partID {
                    Text("Part ID: \(partID)")
                        .font(.subheadline)
                }
                
                Text("Quantity: \(item.quantity)")
                    .font(.subheadline)
                
                Text(String(format: "Price: %.2f", item.price))
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Restock")
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// MARK: – Maintenance Card Model
struct MaintenanceCard: View {
    var carNumber: String
    var serviceDetail: String
    var totalBill: Int
    var buttonTitle: String
    var buttonColor: Color
    var icon: String
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Car Number: \(carNumber)")
                .font(.headline)
                .foregroundColor(Color(hex: "#396BAF"))

            Text("Service Detail: \(serviceDetail)")
                .font(.subheadline)
                .foregroundColor(Color(hex: "#396BAF"))

            Text("Total Bill: ₹\(totalBill)")
                .font(.subheadline)
                .foregroundColor(Color(hex: "#396BAF"))

            Divider()

            Button(action: action) {
                Label(buttonTitle, systemImage: icon)
                    .font(.headline.bold())
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    //.background(buttonColor.opacity(0.2))
                    .foregroundColor(buttonColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
        .cornerRadius(16)
    }
}

// MARK: - Bill Data Model

struct BillItem: Identifiable {
    let id: Int
    let name: String
    let quantity: Int
    let price: Int
}

// Sample static data
let billItems: [BillItem] = [
    BillItem(id: 1, name: "Tires", quantity: 4, price: 2000),
    BillItem(id: 2, name: "Steering Wheel", quantity: 1, price: 5000),
    BillItem(id: 3, name: "Engine Oil", quantity: 1, price: 400),
    BillItem(id: 4, name: "Engine Oil", quantity: 1, price: 500),
]

// MARK: – Fluid Card Model
struct FluidCard: View {
    let item: InventoryItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .bold()
                    .foregroundColor(Color(hex: "396BAF"))
                    .font(.headline)
                
                    Text("Quantity: \(item.quantity)")
                    Text(String(format: "Price: %.2f", item.price))
                }
                .font(.subheadline)
                .foregroundColor(.black)

            Spacer()

            Button(action: {
                // Action for restocking, e.g., show restock UI or update inventory
                print("Restock button tapped for \(item.name)")
            }) {
                Text("Restock")
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

struct FluidsView: View {
    let searchText: String
    @Binding var items: [InventoryItem]
    
    var filteredItems: [InventoryItem] {
        items.filter { item in
            guard item.type == .fluid else { return false }
            return searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(filteredItems) { item in
            InventoryCard(item: item)
                .listRowBackground(Color(hex: "E5E5EA")) // Gray8 background for rows
                .listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 8, trailing: 6)) // Add some padding
        }
        .background(Color(hex: "E5E5EA")) // Gray8 background for the list
        .scrollContentBackground(.hidden) // Hide default background on iOS 16+
    }
}
