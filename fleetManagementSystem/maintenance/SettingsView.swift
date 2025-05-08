import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        // Call logout and dismiss the sheet
                        Task {
                               await viewModel.logout()
                               // Force navigation reset
                               DispatchQueue.main.async {
                                   if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                      let window = windowScene.windows.first {
                                       let rootView = ApplicationSwitcher().environmentObject(viewModel)
                                       window.rootViewController = UIHostingController(rootView: rootView)
                                   }
                               }
                           }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Logout")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: AuthViewModel())
    }
}
