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

struct OnGoingMaintenance: View {
    @State private var tasks: [MaintenanceTask] = []

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(tasks) { task in
                    NavigationLink(destination: MaintenanceDetailsView()) {
                        MaintenanceCardView(task: task, showDate: true)
                    }
                }
            }
            .padding(.top, 24)
            .onAppear {
                FirebaseModules.shared.fetchOngoingMaintenanceTasks { fetched in
                    self.tasks = fetched
                }
            }

        }
        .navigationTitle("OnGoing Tasks")
    }
}


struct OngoingMaintenanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnGoingMaintenance()
        }
    }
}
