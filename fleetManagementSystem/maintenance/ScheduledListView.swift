//
//  UpcomingMaintenanceDetailView.swift
//  fleetManagementSystem
//
//  Created by Steve on 07/05/25.
//



import SwiftUI

struct ScheduledListView: View {
    @State private var tasks: [MaintenanceTask] = []

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(tasks) { task in
                    NavigationLink(destination: ScheduledDetailsView(billId: task.id)) {
                        MaintenanceCardView(task: task, showDate: true)
                    }
                    .onAppear {
                        print("Task ID: \(task.id)") // Print task.id
                    }
                }
            }
            .onAppear {
                FirebaseModules.shared.fetchScheduledMaintenanceTasks { fetched in
                    self.tasks = fetched
                }
            }
        }
        .navigationTitle("Upcoming Tasks")
    }
}

struct UpcomingMaintenanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduledListView()
        }
    }
}
