import SwiftUI

struct UpcomingMaintenanceDetailView: View {
    let upcomingTasks: [MaintenanceTask] = [
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: "23/11/24 - 23/11/32"),
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: "23/11/24 - 23/11/32"),
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: "23/11/24 - 23/11/32"),
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: "23/11/24 - 23/11/32")
    ]

    var body: some View {
        VStack(alignment: .leading) {
//            Text("Upcoming Tasks")
//                .font(.title2.bold())
//                .padding(.top)
//                .padding(.horizontal)

            ScrollView {
                ForEach(upcomingTasks) { task in
                    NavigationLink(destination: UpcomingMaintenanceBillView()){
                        MaintenanceCardView(task: task, showDate: false)
                    }
                }
            }
            .padding(.top, 24)
        }
        .navigationTitle("Upcoming Tasks")
    }
}

struct UpcomingMaintenanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UpcomingMaintenanceDetailView()
        }
    }
}

