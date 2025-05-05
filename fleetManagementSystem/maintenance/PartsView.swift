//
//  PartsView.swift
//  Fleet_Inventory_Screen
//
//  Created by admin81 on 29/04/25.
//

// MARK: - Parts View
import SwiftUI

// MARK: - Parts View
struct PartsView: View {
    let searchText: String
    @Binding var items: [InventoryItem]
    
    var filteredItems: [InventoryItem] {
        items.filter { item in
            guard item.type == .part else { return false }
            return searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                (item.partID?.localizedCaseInsensitiveContains(searchText) ?? false)
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
