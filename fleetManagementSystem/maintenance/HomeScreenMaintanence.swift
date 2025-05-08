import SwiftUI

// MARK: - Home View

struct HomeView: View {
    // Use the shared viewModel passed from MaintenanceTabView
    @ObservedObject var viewModel: AuthViewModel
    @State private var pendingBills: [PendingBill] = []

    
    
    let inventoryItems: [InventoryItem] = [
        InventoryItem(name: "Brake Pad", quantity: 2, price: 150.0, partID: "BR123"),
        InventoryItem(name: "Coolant", quantity: 2, price: 75.0)
    ]

    @State private var isNavigatingToOngoing = false
    @State private var isNavigatingToUpcoming = false
    @State private var showSettings = false
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
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
                          
                            // Settings button
                            NavigationLink(destination: MaintenanceNotificationScreen()) {
                                Image(systemName: "bell.fill").font(.system(size: 25))
                            }
                            Button(action: {
                                showProfile = true
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
                        }
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
                                    destination: OnGoingMaintenance(),
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
                                    destination: ScheduledListView(),
                                    isActive: $isNavigatingToUpcoming,
                                    label: { EmptyView() }
                                )
                                .hidden()
                            )
                        }

                        
//                            RequestCard(billId: <#String#>, carNumber: "TN 22 BP 9987", serviceDetail: "Oil Change", totalBill: 3200.0)
                            if !pendingBills.isEmpty {
                                SectionView(title: "Requests") {
                                    ForEach(pendingBills) { bill in
                                        RequestCard(
                                            billId: bill.id,
                                            carNumber: bill.vehicle,
                                            serviceDetail: bill.task,
                                            totalBill: bill.amount
                                        )
                                    }
                                }
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
            .onAppear {
                           FirebaseModules.shared.fetchApprovedBills { bills in
                               self.pendingBills = bills
                           }
                       }
            .fullScreenCover(isPresented: $showProfile) {
                MaintenanceProfileView(viewModel: viewModel)
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
    let billId: String
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

                            Button("Confirm Date & Approve") {
                                approveRequest()
                            }
                            .font(.subheadline)
                            .padding(6)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                        }

                        else {
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
    
    func approveRequest() {
        FirebaseModules.shared.scheduleMaintenanceDate(billId: billId, date: selectedDate) { error in
            if error == nil {
                withAnimation {
                    decision = .accepted
                }
            }
        }
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
