import SwiftUI

struct OrderFormView: View {
    @State private var newItem: OrderItem
    let itemType: String
    @Binding var inventoryItems: [InventoryItem]
    @Binding var showSheet: Bool
    
    init(itemType: String, inventoryItems: Binding<[InventoryItem]>, showSheet: Binding<Bool>) {
        _newItem = State(initialValue: OrderItem(name: "", quantity: 1, partID: "", price: ""))
        self.itemType = itemType
        self._inventoryItems = inventoryItems
        self._showSheet = showSheet
    }
    
    var body: some View {
        // Added: Wrapped the content in a ScrollView to handle overflow and ensure the button is accessible
        ScrollView {
            VStack(spacing: 20) {
                Text("Order New \(itemType)")
                    .font(.title2)
                    .foregroundColor(Color(hex: "396BAF"))
                    .padding(.top)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Name").foregroundColor(Color(hex: "396BAF"))
                        Spacer()
                        TextField("Enter Name", text: $newItem.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Quantity").foregroundColor(Color(hex: "396BAF"))
                        Spacer()
                        TextField("Enter Quantity", value: $newItem.quantity, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                    }
                    
                    if itemType == "Parts" {
                        HStack {
                            Text("Part ID").foregroundColor(Color(hex: "396BAF"))
                            Spacer()
                            TextField("Enter Part ID", text: $newItem.partID)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                    }
                    
                    HStack {
                        Text("Price").foregroundColor(Color(hex: "396BAF"))
                        Spacer()
                        TextField("Enter Price", text: $newItem.price)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .padding(.horizontal)
                    }
                }
                .padding()
                
                Button(action: placeOrder) {
                    Text("Place Order")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "396BAF"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Added: Spacer to push the button up and ensure space at the bottom
                Spacer(minLength: 50) // Adjusted: Added minimum length to ensure space for the tab bar
            }
            .padding(.bottom) // Added: Padding to ensure the content doesn't overlap with the tab bar
        }
        .background(Color(hex: "E5E5EA").ignoresSafeArea()) // Modified: Ensure background color extends behind the tab bar
    }
    
    private func placeOrder() {
        guard !newItem.name.isEmpty else { return }
        guard let price = Double(newItem.price) else { return }

        withAnimation {
            if itemType == "Parts" {
                let item = InventoryItem(
                    name: newItem.name,
                    quantity: newItem.quantity,
                    price: price,
                    partID: newItem.partID
                )
                inventoryItems.append(item)

                FirebaseModules.shared.addInventoryItem(item)
            } else {
                let item = InventoryItem(
                    name: newItem.name,
                    quantity: newItem.quantity,
                    price: price
                )
                inventoryItems.append(item)

                FirebaseModules.shared.addInventoryItem(item)
            }

            newItem = OrderItem(name: "", quantity: 1, partID: "", price: "")
            showSheet = false
        }
    }
}

struct OrderItem {
    var name: String
    var quantity: Int
    var partID: String
    var price: String
}
