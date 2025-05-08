import SwiftUI

struct OrderFormView: View {
    @State private var newItem: OrderItem
    @State private var showAlert = false
    @State private var alertMessage = ""
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
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showSheet = false
                }
            
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
                .padding(.bottom)
            }
            .frame(maxWidth: 320)
            .background(Color(hex: "E5E5EA"))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
                )
        }
    }
    
    private func placeOrder() {
        // Validate inputs
        guard !newItem.name.isEmpty else {
            showAlert(message: "Please enter a name for the item")
            return
        }
        
        guard let price = Double(newItem.price), price > 0 else {
            showAlert(message: "Please enter a valid price")
            return
        }
        
        guard newItem.quantity > 0 else {
            showAlert(message: "Please enter a valid quantity")
            return
        }
        
        // Create and add the new item
        withAnimation {
            let item = InventoryItem(
                name: newItem.name,
                quantity: newItem.quantity,
                price: price,
                partID: itemType == "Parts" ? newItem.partID : ""
            )
            
            inventoryItems.append(item)
            FirebaseModules.shared.addInventoryItem(item)
            
            // Reset form and close sheet
            newItem = OrderItem(name: "", quantity: 1, partID: "", price: "")
            showSheet = false
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct OrderItem {
    var name: String
    var quantity: Int
    var partID: String
    var price: String
}
