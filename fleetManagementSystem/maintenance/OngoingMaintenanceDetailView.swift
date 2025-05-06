import SwiftUI

struct OngoingMaintenanceDetailView: View {
    let ongoingTasks: [MaintenanceTask] = [
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil)    ]

    var body: some View {
        VStack(alignment: .leading) {
//            Text("OnGoing Tasks")
//                .font(.title2.bold())
//                .padding(.top)
//                .padding(.horizontal)

            ScrollView {
                ForEach(ongoingTasks) { task in
                    MaintenanceCardView(task: task, showDate: false)
                }
            }
        }
        .navigationTitle("OnGoing Tasks")
    }
}

struct OngoingMaintenanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OngoingMaintenanceDetailView()
        }
    }
}


