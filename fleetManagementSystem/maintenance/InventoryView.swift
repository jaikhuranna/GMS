import SwiftUI

struct InventoryView: View {
    @State private var selectedTab = "Parts"
    @State private var searchText = ""
    @State private var showOrderSheet = false
    @State private var inventoryItems: [InventoryItem] = []
    @State private var isLoading = true
    
    // Computed properties for filtered items
    private var parts: [InventoryItem] {
        inventoryItems.filter { $0.type == .part }
    }
    
    private var fluids: [InventoryItem] {
        inventoryItems.filter { $0.type == .fluid }
    }
    
    var body: some View {
        ZStack {
            // Background content (to be blurred)
            Group {
                if isLoading {
                    ProgressView("Loading inventory...")
                        .font(.headline)
                        .padding()
                } else {
                    VStack {
                        SearchBar(searchText: $searchText)

                        HStack(spacing: 4) {
                            TabButton(title: "Parts", selectedTab: $selectedTab)
                            TabButton(title: "Fluids", selectedTab: $selectedTab)
                        }
                        .padding(4)
                        .background(Color(hex: "396BAF"))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        if selectedTab == "Parts" {
                            PartsView(searchText: searchText, items: $inventoryItems)
                        } else {
                            FluidsView(searchText: searchText, items: $inventoryItems)
                        }

                        OrderButton(itemType: selectedTab, showSheet: $showOrderSheet)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                    .padding(.top)
                    .background(Color.white)
                }
            }
            .blur(radius: showOrderSheet ? 3 : 0) // Apply blur to background content only

            // Foreground content (OrderFormView and tap-to-dismiss)
            if showOrderSheet {
                // Tap outside to dismiss
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            showOrderSheet = false
                        }
                    }

                OrderFormView(
                    itemType: selectedTab,
                    inventoryItems: $inventoryItems,
                    showSheet: $showOrderSheet
                )
                .transition(.opacity)
                .animation(.linear(duration: 0.3), value: showOrderSheet)
            }
        }
        .onAppear {
            isLoading = true
            FirebaseModules.shared.fetchInventoryItems { fetchedItems in
                self.inventoryItems = fetchedItems
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Subviews
    struct TabButton: View {
        let title: String
        @Binding var selectedTab: String
        
        var body: some View {
            Button(action: {
                selectedTab = title
            }) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selectedTab == title ? Color(hex: "396BAF") : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            if selectedTab == title {
                                Color.white
                                    .cornerRadius(10)
                            }
                        }
                    )
            }
        }
    }
    
    struct SearchBar: View {
        @Binding var searchText: String
        
        var body: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search by name or ID", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
    
    struct OrderButton: View {
        let itemType: String
        @Binding var showSheet: Bool
        
        var body: some View {
            Button(action: {
                withAnimation {
                    showSheet = true
                }
            }) {
                Text("Order New \(itemType)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(hex: "396BAF"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: "396BAF"), lineWidth: 1)
                    )
            }
        }
    }
    
    struct InventoryView_Previews: PreviewProvider {
        static var previews: some View {
            InventoryView()
        }
    }
}
