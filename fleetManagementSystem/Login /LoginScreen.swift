
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

enum AuthScreen {
    case login
    case home
}

enum UserRole: String {
    case driver = "driver"
    case fleetManager = "fleet_manager"
    case maintenance = "maintenance"
    case unknown = "unknown"
}

class AuthViewModel: ObservableObject {
    @Published var screen: AuthScreen = .login
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var userRole: UserRole = .unknown

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please fill all fields"
            return
        }

        isLoading = true
        errorMessage = ""

        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            self.isLoading = false

            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            self.fetchUserRole()
        }
    }

    func fetchUserRole() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        isLoading = true

        db.collection("users").document(userID).getDocument { [weak self] document, error in
            guard let self = self else { return }

            self.isLoading = false

            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            if let document = document, document.exists {
                if let roleString = document.data()?["role"] as? String,
                   let role = UserRole(rawValue: roleString) {
                    self.userRole = role
                } else {
                    self.userRole = .unknown
                }
            } else {
                self.createUserProfile()
                return
            }

            self.screen = .home
        }
    }

    private func createUserProfile() {
        guard let user = Auth.auth().currentUser else { return }

        let userData: [String: Any] = [
            "email": user.email ?? self.email,
            "role": UserRole.driver.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("users").document(user.uid).setData(userData) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            self.userRole = .driver
            self.screen = .home
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            screen = .login
            email = ""
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct AuthRootView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                switch viewModel.screen {
                case .login:
                    LoginScreen(viewModel: viewModel)

                case .home:
                    HomeScreenRouter(viewModel: viewModel)
                }

                Spacer()
            }

            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().scaleEffect(2).progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { !viewModel.errorMessage.isEmpty },
            set: { _ in viewModel.errorMessage = "" }
        )) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct LogoView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("Logo")
                .resizable()
                .frame(width: 150, height: 150)
            Text("Navora")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
            Text("Manage your fleets")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
        }
        .padding(.top, 25)
        .padding(.bottom, 25)
    }
}

struct LoginScreen: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBlue).opacity(0.1),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()



            VStack(spacing: 20) {
                LogoView()

                VStack(spacing: 16) {
                    TextField("Email ID", text: $viewModel.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))

                    ZStack(alignment: .trailing) {
                        Group {
                            if viewModel.isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))

                        Button(action: { viewModel.isPasswordVisible.toggle() }) {
                            Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }

                    HStack {
                        Spacer()
                        Button("Forgot password?") {
                            // Action for forgot password
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
                        .padding(.trailing, 4)
                    }
                }
                .padding(.bottom, 12)

                Button(action: viewModel.login) {
                    HStack {
                        Spacer()
                        Text("Log In")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 51/255, green: 102/255, blue: 204/255))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
    }
}


struct HomeScreenRouter: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
            switch viewModel.userRole {
            case .driver:
                DriverHomeScreen(viewModel: viewModel)
            case .fleetManager:
                MainTabView()
            case .maintenance:
                MaintenanceHomeScreen(viewModel: viewModel)
            case .unknown:
                UnknownRoleScreen(viewModel: viewModel)
            }
        }
    }
}

struct DriverHomeScreen: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Driver Dashboard").font(.largeTitle).padding()
                Text("Welcome to the Driver Portal").font(.title2)
                Spacer()
                Button("Sign Out") {
                    viewModel.signOut()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Driver Portal")
        }
    }
}

struct MaintenanceHomeScreen: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Maintenance Dashboard").font(.largeTitle).padding()
                Text("Welcome to the Maintenance Portal").font(.title2)
                Spacer()
                Button("Sign Out") {
                    viewModel.signOut()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Maintenance Portal")
        }
    }
}

struct UnknownRoleScreen: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
            Text("Role Not Assigned").font(.largeTitle).padding()
            Text("Your account doesn't have a role assigned yet. Please contact admin.")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            Button("Sign Out") {
                viewModel.signOut()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct AuthRootView_Previews: PreviewProvider {
    static var previews: some View {
        AuthRootView()
    }
}
