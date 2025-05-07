//import SwiftUI
//
//struct OngoingMaintenanceDetailView: View {
//    let ongoingTasks: [MaintenanceTask] = [
//        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),
//        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),
//        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),
//        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil)
//    ]
//
//    var body: some View {
//        VStack(alignment: .leading) {
////            Text("OnGoing Tasks")
////                .font(.title2.bold())
////                .padding(.top)
////                .padding(.horizontal)
//
//            ScrollView {
//                ForEach(ongoingTasks) { task in
//                    NavigationLink(destination: OngoingMaintenanceBillView()) {
//                        MaintenanceCardView(task: task, showDate: false)
//                    }
//                }
//            }
//
//        }
//        .navigationTitle("OnGoing Tasks")
//
//    }
//}
//
//struct OngoingMaintenanceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            OngoingMaintenanceDetailView()
//        }
//    }
//}


import SwiftUI

struct OngoingMaintenanceDetailView: View {
    let ongoingTasks: [MaintenanceTask] = [
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil),
        MaintenanceTask(taskTitle: "Tire Replace Task", vehicleNumber: "KN23CB4563", dateRange: nil)
    ]

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(ongoingTasks) { task in
                    NavigationLink(destination: OngoingMaintenanceBillView()) {
                        MaintenanceCardView(task: task, showDate: false)
                    }
                }
            }
            .padding(.top, 24) // Increased space between navigation title and ScrollView
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
