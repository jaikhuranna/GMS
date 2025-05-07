

//import SwiftUI
//
//// MARK: - Home View
//
//struct HomeView: View {
//    let inventoryItems: [InventoryItem] = [
//        InventoryItem(name: "Brake Pad", quantity: 2, price: 150.0, partID: "BR123"),
//        InventoryItem(name: "Coolant", quantity: 2, price: 75.0)
//    ]
//
//    @State private var isNavigatingToOngoing = false
//    @State private var isNavigatingToUpcoming = false
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Header
//                ZStack(alignment: .top) {
//                    RoundedRectangle(cornerRadius: 30)
//                        .fill(Color(red: 231/255, green: 237/255, blue: 248/255))
//                        .edgesIgnoringSafeArea(.top)
//
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Welcome,")
//                                .font(.title3)
//                                .foregroundColor(.black)
//                            Text("Maintenance Manager")
//                                .font(.title2)
//                                .bold()
//                                .foregroundColor(.black)
//                        }
//                        Spacer()
//                        HStack(spacing: 16) {
//                            Image(systemName: "bell.fill").font(.system(size: 25))
//                            Image(systemName: "person.circle.fill").font(.system(size: 25))
//                        }
//                        .foregroundColor(.black)
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 40)
//                }
//                .frame(height: 120)
//                .zIndex(1)
//
//                // Scrollable Content
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 28) {
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//                            // On Going Tasks Card with NavigationLink
//                            Button(action: {
//                                isNavigatingToOngoing = true
//                            }) {
//                                TaskSummaryCard(title: "On Going Tasks", count: 5, icon: "hammer")
//                            }
//                            .background(
//                                NavigationLink(
//                                    destination: OngoingMaintenanceDetailView(),
//                                    isActive: $isNavigatingToOngoing,
//                                    label: { EmptyView() }
//                                )
//                                .hidden()
//                            )
//
//                            // Scheduled Tasks Card with NavigationLink
//                            Button(action: {
//                                isNavigatingToUpcoming = true
//                            }) {
//                                TaskSummaryCard(title: "Scheduled Tasks", count: 4, icon: "calendar")
//                            }
//                            .background(
//                                NavigationLink(
//                                    destination: UpcomingMaintenanceDetailView(),
//                                    isActive: $isNavigatingToUpcoming,
//                                    label: { EmptyView() }
//                                )
//                                .hidden()
//                            )
//                        }
//
//                        SectionView(title: "Requests") {
//                            RequestCard(carNumber: "TN 22 BP 9987", serviceDetail: "Oil Change", totalBill: 3200.0)
//                        }
//
//                        SectionView(title: "Inventory") {
//                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//                                ForEach(inventoryItems) { item in
//                                    InventoryCard2(item: item)
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 16)
//                    .padding(.bottom, 40)
//                }
//            }
//            .background(Color.white)
//            .navigationBarHidden(true)
//        }
//    }
//}
//
//// MARK: - Subviews
//
//struct TaskSummaryCard: View {
//    var title: String
//    var count: Int
//    var icon: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text("\(count)")
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(Color(hex: "#396BAF"))
//                Spacer()
//                ZStack {
//                    Circle()
//                        .fill(Color.white)
//                        .frame(width: 50, height: 50)
//                    Image(systemName: icon)
//                        .font(.system(size: 22))
//                        .foregroundColor(Color(hex: "#396BAF"))
//                }
//            }
//            Text(title)
//                .font(.headline)
//                .foregroundColor(Color(hex: "#396BAF"))
//        }
//        .padding(20)
//        .frame(minHeight: 120)
//        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
//        .cornerRadius(20)
//    }
//}
//
//struct SectionView<Content: View>: View {
//    var title: String
//    @ViewBuilder var content: () -> Content
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(title)
//                .font(.title2)
//                .foregroundColor(Color(hex: "#396BAF"))
//            content()
//        }
//    }
//}
//
//struct RequestCard: View {
//    let carNumber: String
//    let serviceDetail: String
//    let totalBill: Double
//
//    @State private var showDatePicker = false
//    @State private var selectedDate = Date()
//    @State private var decision: RequestDecision? = nil
//
//    enum RequestDecision {
//        case accepted, rejected
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            // Header Information
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Car Number: \(carNumber)")
//                    .font(.headline)
//                    .foregroundColor(Color(hex: "#396BAF"))
//                Text("Service Detail: \(serviceDetail)")
//                    .font(.subheadline)
//                    .foregroundColor(Color(hex: "#396BAF"))
//                Text("Total Bill: ₹\(Int(totalBill))")
//                    .font(.subheadline)
//                    .foregroundColor(Color(hex: "#396BAF"))
//            }
//            
//            Divider()
//
//            ZStack {
//                if let decision = decision {
//                    Text(decision == .accepted ? "Request Accepted" : "Request Rejected")
//                        .font(.headline)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 8)
//                        .frame(maxWidth: .infinity)
//                        .foregroundColor(decision == .accepted ? .green : .red)
//                        .cornerRadius(8)
//                        .bold()
//                        .transition(.opacity)
//                } else {
//                    VStack(spacing: 8) {
//                        if showDatePicker {
//                            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
//                                .labelsHidden()
//                                .datePickerStyle(.compact)
//                        } else {
//                            HStack {
//                                Spacer()
//                                Button(action: {
//                                    withAnimation {
//                                        showDatePicker = true
//                                    }
//                                }) {
//                                    Label("Schedule Maintenance Date", systemImage: "calendar.badge.plus")
//                                        .font(.headline)
//                                        .padding(6)
//                                        .cornerRadius(8)
//                                }
//                                Spacer()
//                            }
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
//            .frame(minHeight: 24)
//        }
//        .padding(16)
//        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
//        .cornerRadius(20)
//        .shadow(color: .gray.opacity(0.05), radius: 2, x: 0, y: 1)
//    }
//}
//
//struct InventoryCard2: View {
//    let item: InventoryItem
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(item.name)
//                        .font(.headline)
//                        .foregroundColor(Color(hex: "#396BAF"))
//                    Text("Only \(item.quantity) left in stock")
//                        .font(.subheadline)
//                        .foregroundColor(.red)
//                }
//                Spacer()
//                ZStack {
//                    Circle()
//                        .fill(Color.white)
//                        .frame(width: 50, height: 50)
//                    Image(systemName: item.type == .part ? "wrench.and.screwdriver" : "drop.fill")
//                        .font(.system(size: 22))
//                        .foregroundColor(Color(hex: "#396BAF"))
//                }
//            }
//        }
//        .padding(20)
//        .frame(minHeight: 100)
//        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
//        .cornerRadius(20)
//    }
//}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}




import SwiftUI

// MARK: - Home View

struct HomeView: View {
    let inventoryItems: [InventoryItem] = [
        InventoryItem(name: "Brake Pad", quantity: 2, price: 150.0, partID: "BR123"),
        InventoryItem(name: "Coolant", quantity: 2, price: 75.0)
    ]

    @State private var isNavigatingToOngoing = false
    @State private var isNavigatingToUpcoming = false
    @State private var showProfile = false // Add this state variable

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Header
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(red: 231/255, green: 237/255, blue: 248/255))
                        .edgesIgnoringSafeArea(.top)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome,")
                                .font(.title3)
                                .foregroundColor(.black)
                            Text("Maintenance Manager")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.black)
                        }
                        Spacer()
                        HStack(spacing: 16) {
                            Image(systemName: "bell.fill").font(.system(size: 25))
                            Button(action: {
                                showProfile = true
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 25))
                            }
                        }
                        .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                }
                .frame(height: 120)
                .zIndex(1)
                
                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            // On Going Tasks Card with NavigationLink
                            Button(action: {
                                isNavigatingToOngoing = true
                            }) {
                                TaskSummaryCard(title: "On Going Tasks", count: 5, icon: "hammer")
                            }
                            .background(
                                NavigationLink(
                                    destination: OngoingMaintenanceDetailView(),
                                    isActive: $isNavigatingToOngoing,
                                    label: { EmptyView() }
                                )
                                .hidden()
                            )
                            
                            // Scheduled Tasks Card with NavigationLink
                            Button(action: {
                                isNavigatingToUpcoming = true
                            }) {
                                TaskSummaryCard(title: "Scheduled Tasks", count: 4, icon: "calendar")
                            }
                            .background(
                                NavigationLink(
                                    destination: UpcomingMaintenanceDetailView(),
                                    isActive: $isNavigatingToUpcoming,
                                    label: { EmptyView() }
                                )
                                .hidden()
                            )
                        }
                        
                        SectionView(title: "Requests") {
                            RequestCard(carNumber: "TN 22 BP 9987", serviceDetail: "Oil Change", totalBill: 3200.0)
                        }
                        
                        SectionView(title: "Inventory") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(inventoryItems) { item in
                                    InventoryCard2(item: item)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showProfile) {
                MaintenanceProfileView()
            }
        }
    }
}

// MARK: - Subviews

struct TaskSummaryCard: View {
    var title: String
    var count: Int
    var icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(count)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(hex: "#396BAF"))
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "#396BAF"))
                }
            }
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "#396BAF"))
        }
        .padding(20)
        .frame(minHeight: 120)
        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
        .cornerRadius(20)
    }
}

struct SectionView<Content: View>: View {
    var title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .foregroundColor(Color(hex: "#396BAF"))
            content()
        }
    }
}

struct RequestCard: View {
    let carNumber: String
    let serviceDetail: String
    let totalBill: Double

    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var decision: RequestDecision? = nil

    enum RequestDecision {
        case accepted, rejected
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Information
            VStack(alignment: .leading, spacing: 4) {
                Text("Car Number: \(carNumber)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#396BAF"))
                Text("Service Detail: \(serviceDetail)")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#396BAF"))
                Text("Total Bill: ₹\(Int(totalBill))")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#396BAF"))
            }
            
            Divider()

            ZStack {
                if let decision = decision {
                    Text(decision == .accepted ? "Request Accepted" : "Request Rejected")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(decision == .accepted ? .green : .red)
                        .cornerRadius(8)
                        .bold()
                        .transition(.opacity)
                } else {
                    VStack(spacing: 8) {
                        if showDatePicker {
                            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        } else {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        showDatePicker = true
                                    }
                                }) {
                                    Label("Schedule Maintenance Date", systemImage: "calendar.badge.plus")
                                        .font(.headline)
                                        .padding(6)
                                        .cornerRadius(8)
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(minHeight: 24)
        }
        .padding(16)
        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct InventoryCard2: View {
    let item: InventoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(Color(hex: "#396BAF"))
                    Text("Only \(item.quantity) left in stock")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                    Image(systemName: item.type == .part ? "wrench.and.screwdriver" : "drop.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "#396BAF"))
                }
            }
        }
        .padding(20)
        .frame(minHeight: 100)
        .background(Color(red: 231/255, green: 237/255, blue: 248/255))
        .cornerRadius(20)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
