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

struct MaintenanceTask: Identifiable {
    let id: String
    let taskTitle: String
    let vehicleNumber: String
    let dateRange: String?

    // Firestore init
    init(id: String, taskTitle: String, vehicleNumber: String, dateRange: String?) {
        self.id = id
        self.taskTitle = taskTitle
        self.vehicleNumber = vehicleNumber
        self.dateRange = dateRange
    }

//    // UUID default init for previews/static use
//    init(taskTitle: String, vehicleNumber: String, dateRange: String?) {
//        self.id = UUID().uuidString
//        self.taskTitle = taskTitle
//        self.vehicleNumber = vehicleNumber
//        self.dateRange = dateRange
//    }
}



struct MaintenanceCardView: View {
    let task: MaintenanceTask
    let showDate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(hex: "#396BAF"))

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.taskTitle)
                        .font(.headline)
                    .foregroundColor(.red)

                    Text(task.vehicleNumber)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#396BAF"))
                    
                    if showDate, let range = task.dateRange {
                        Text(range)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#396BAF"))
                    } else if !showDate {
                        Text("In Progress")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#396BAF"))
                    }
                }
            }
            Divider()
        }
        .padding()
        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


//MARK: Creating Bill
struct BillSummary {
    let billItems: [BillItem]
    let subtotal: Int
    let serviceCharge: Int
    let gst: Int
    let total: Int

    // Use this in Fleet Manager screen
    init(billItems: [BillItem], subtotal: Int, serviceCharge: Int, gst: Int, total: Int) {
        self.billItems = billItems
        self.subtotal = subtotal
        self.serviceCharge = serviceCharge
        self.gst = gst
        self.total = total
    }

    // Use this in Maintenance screen during live calculation
    init(parts: [Part], fluids: [Part], inventory: [InventoryItem]) {
        var items: [BillItem] = []
        var subtotal = 0
        var id = 1

        let all = parts + fluids
        for entry in all {
            guard let match = inventory.first(where: { $0.name == entry.name }) else { continue }
            let qty = Int(entry.quantity) ?? 1
            let price = Int(Double(qty) * match.price)
            items.append(BillItem(id: id, name: entry.name, quantity: qty, price: price))
            subtotal += price
            id += 1
        }

        self.billItems = items
        self.subtotal = subtotal
        self.serviceCharge = 500
        self.gst = Int(Double(subtotal + serviceCharge) * 0.18)
        self.total = subtotal + serviceCharge + gst
    }
}


// MARK: - Bill Request Model for Fleet Manager

struct BillRequest: Identifiable {
    let id: String
    let vehicleNo: String
    let taskName: String
    let description: String
    let summary: BillSummary

    static func from(_ doc: DocumentSnapshot) -> BillRequest? {
        let data = doc.data() ?? [:]

        guard
            let vehicleNo = data["vehicleNo"] as? String,
            let taskName = data["taskName"] as? String,
            let description = data["description"] as? String,
            let items = data["parts"] as? [[String: Any]]
        else {
            return nil
        }


        let billItems: [BillItem] = items.enumerated().compactMap { (i, dict) in
            guard
                let name = dict["name"] as? String,
                let qty = dict["quantity"] as? Int,
                let price = dict["price"] as? Int
            else { return nil }

            return BillItem(id: i + 1, name: name, quantity: qty, price: price)
        }


        let subtotal = data["subtotal"] as? Int ?? 0
        let serviceCharge = data["serviceCharge"] as? Int ?? 500
        let gst = data["gst"] as? Int ?? Int(Double(subtotal + serviceCharge) * 0.18)
        let total = data["total"] as? Int ?? subtotal + serviceCharge + gst

        let summary = BillSummary(billItems: billItems, subtotal: subtotal, serviceCharge: serviceCharge, gst: gst, total: total)

        return BillRequest(
            id: doc.documentID,
            vehicleNo: vehicleNo,
            taskName: taskName,
            description: description,
            summary: summary
        )
    }

}

struct PendingBill: Identifiable {
    let id: String
    let task: String
    let vehicle: String
    let amount: Double
}


