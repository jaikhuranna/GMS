import SwiftUI

struct Request: Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let date: String
    let vehicleNumber: String
    let iconName: String
}

struct RequestListView: View {
    // Dummy request data
    let requests: [Request] = [
        Request(title: "Oil Levels", location: "Mandakalli, Karnataka 571311", date: "14th Apr", vehicleNumber: "KA05AK0434", iconName: "drop.fill"),
        Request(title: "Engine Issue", location: "Mandakalli, Karnataka 571311", date: "9th Apr", vehicleNumber: "KA05AK0434", iconName: "exclamationmark.triangle.fill"),
        Request(title: "Tire Issue", location: "Mandakalli, Karnataka 571311", date: "6th Apr", vehicleNumber: "KA05AK0434", iconName: "car.fill"),
        Request(title: "Engine Issue", location: "Mandakalli, Karnataka 571311", date: "29th Mar", vehicleNumber: "KA05AK0434", iconName: "exclamationmark.triangle.fill"),
        Request(title: "Engine Issue", location: "Mandakalli, Karnataka 571311", date: "20th Mar", vehicleNumber: "KA05AK0434", iconName: "exclamationmark.triangle.fill")
    ]
    
    @Environment(\.dismiss) var dismiss // To dismiss the view
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed Top Card
                ZStack(alignment: .leading) {
                    Color(red: 67/255, green: 110/255, blue: 184/255)
                        .frame(height: 150)
                        .clipShape(.rect(
                            bottomLeadingRadius: 30,
                            bottomTrailingRadius: 30
                        ))
                        .ignoresSafeArea(edges: .top)

                    HStack {
                        Button(action: {
                            dismiss() // Dismiss the current view when the back button is tapped
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .semibold))
                                Text("All Requests")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }

                        Spacer()

                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                }

                // Scrollable Requests List
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Past")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 16)

                        ForEach(requests) { request in
                            NavigationLink(
                                destination: RequestDetailView(request: request),
                                label: {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(red: 230/255, green: 239/255, blue: 249/255))
                                                    .frame(width: 42, height: 42)

                                                Image(systemName: request.iconName)
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 16, weight: .bold))
                                            }

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(request.title)
                                                    .font(.system(size: 17, weight: .semibold))
                                                    .foregroundColor(.primary)

                                                Text(request.location)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)

                                                HStack(spacing: 4) {
                                                    Text(request.date)
                                                    Text("•")
                                                    Text(request.vehicleNumber)
                                                }
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                            }

                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)

                                        if request.id != requests.last?.id {
                                            Divider()
                                                .padding(.leading, 70)
                                        }
                                    }
                                })
                        }
                    }
                }
            }
            .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color.white)
            .edgesIgnoringSafeArea(.top)
        }
        .navigationBarBackButtonHidden(true) // Hide default back button
    }
}

// Detail View for Request
struct RequestDetailView: View {
    var request: Request

    var body: some View {
        VStack {
            Text("Request Detail")
                .font(.system(size: 24, weight: .bold))
                .padding()

            Text("Title: \(request.title)")
            Text("Location: \(request.location)")
            Text("Date: \(request.date)")
            Text("Vehicle Number: \(request.vehicleNumber)")

            Spacer()
        }
        .navigationTitle(request.title)
        .navigationBarBackButtonHidden(false) // Show back button
    }
}

struct RequestListView_Preview: View {
    var body: some View {
        NavigationStack {
            RequestListView()
        }
    }
}

#Preview {
    RequestListView()
}
