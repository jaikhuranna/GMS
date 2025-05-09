//
//  FleetDriverListView.swift
//  FleetManagement
//
//  Created by user@89 on 22/04/25.
//

import SwiftUI

struct FleetDriverListView: View {
    @State private var selectedSegment = "HMV"
    @State private var searchText = ""
    @State private var drivers: [Driver] = []
    @State private var navigateToAddDriver = false
    @State private var editingDriver: Driver?
    @State private var navigateToEdit = false
    @State private var selectedDriver: Driver?
    
    
    let segments = ["HMV", "LMV"]
    
    
    
    var filteredDrivers: [Driver] {
        let filtered = drivers.filter { driver in
            selectedSegment == "HMV" ? driver.driverLicenseType == "HMV" : driver.driverLicenseType == "LMV"
        }
        return searchText.isEmpty ? filtered : filtered.filter { $0.driverName.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {
                searchBar
                CustomSegmentedControl(selectedSegment: $selectedSegment, segments: segments)
                
                ScrollView {
                    VStack(spacing: 4) {
                        if filteredDrivers.isEmpty {
                            Text("No drivers found.").foregroundColor(.gray)
                        } else {
                            ForEach(filteredDrivers) { drv in
                                driverRow(drv)
                                
                            }
                        }
                    }
                }
            }
                .toolbar {
                // ← Here is the Add button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddDriverView()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.black)
                    }
                }
            }
            .onAppear {
                FirebaseModules.shared.fetchDrivers { self.drivers = $0 }
            }
            .sheet(item: $editingDriver) { drv in
                EditDriverView(driver: drv) {
                    // refresh list after save
                    FirebaseModules.shared.fetchDrivers { self.drivers = $0 }
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search driver", text: $searchText)
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var driverList: some View {
        ScrollView {
            VStack(spacing: 4) {
                if filteredDrivers.isEmpty {
                    Text("No drivers found.")
                        .foregroundColor(.gray)
                        .padding(.top)
                } else {
                    ForEach(filteredDrivers) { driver in
                        driverRow(driver)
                    }
                }
            }
        }
    }
    
    private func driverRow(_ driver: Driver) -> some View {
        NavigationLink(destination: DriverDetailView(driver: driver)) {
            HStack(spacing: 16) {
                AsyncImage(url: sanitizeStorageURL(driver.driverImage)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Image("driver")
                            .resizable().foregroundColor(.gray)
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(radius: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(driver.driverName)
                        .font(.headline)
                        .foregroundColor(Color(hex: "#396BAF"))
                    Text("Experience: \(driver.driverExperience) yrs")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#396BAF"))
                }
                
                Spacer()
                
                Button {
                    editingDriver = driver
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#396BAF"))
                }
                // make sure tapping the pencil doesn't trigger the row link:
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
    
    /// Turn that bad ".firebasestorage.app" into ".appspot.com", and drop the ":443" port
    private func sanitizeStorageURL(_ raw: String) -> URL? {
        guard var comps = URLComponents(string: raw) else { return nil }
        // remove explicit port
        comps.port = nil
        // correct the host
        if let host = comps.host,
           host.hasSuffix(".firebasestorage.app") {
            comps.host = host
              .replacingOccurrences(of: ".firebasestorage.app",
                                    with: ".appspot.com")
        }
        return comps.url
    }

    
    struct CustomSegmentedControl: View {
        @Binding var selectedSegment: String
        let segments: [String]
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(segments, id: \.self) { segment in
                    Button(action: {
                        selectedSegment = segment
                    }) {
                        Text(segment)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(selectedSegment == segment ? Color(.systemBackground) : Color.accentColor)
                            .foregroundColor(selectedSegment == segment ? Color.accentColor : .white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(Color.accentColor)
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
    
    
    
    struct FleetDriverListView_Previews: PreviewProvider {
        static var previews: some View {
           FleetDriverListView()
        }
    }

