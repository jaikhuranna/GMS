
//import SwiftUI
//import FirebaseFirestore
//    enum AuthScreen {
//        case login
//       
//        case otp
//    }
//
//struct AuthRootView: View {
//    @State private var screen: AuthScreen = .login
//    @State private var email: String = ""
//    @State private var phone: String = ""
//    @State private var password: String = ""
//    @State private var otp: String = ""
//    @State private var isPasswordVisible: Bool = false
//    
//    var body: some View {
//        ZStack {
//            Color(red: 238/255, green: 247/255, blue: 255/255).ignoresSafeArea()
//            VStack {
//                Spacer()
//                switch screen {
//                case .login:
//                    LoginScreen(
//                        email: $email,
//                        phone: $phone,
//                        password: $password,
//                        isPasswordVisible: $isPasswordVisible,
//                        onLogin: { screen = .otp}
//                    )
//                    
//                case .otp:
//                    OTPScreen(
//                        otp: $otp,
//                        onNext: { /* */ }
//                    )
//                    
//                    Spacer()
//                }
//            }
//        }
//    }
//    
//    struct LogoView: View {
//        var body: some View {
//            VStack(spacing: 8) {
//                Image("logo")
//                    .resizable()
//                    .frame(width: 280, height: 150)
//                    .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
//            }
//            .padding(.top,25)
//            .padding(.bottom, 25)
//        }
//    }
//    
//    
//    struct LoginScreen: View {
//        @Binding var email: String
//        @Binding var phone: String
//        @Binding var password: String
//        @Binding var isPasswordVisible: Bool
//        var onLogin: () -> Void
//        
//        var body: some View {
//            ZStack {
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(red: 0.85, green: 0.9, blue: 0.97),
//                        Color(red: 0.96, green: 0.98, blue: 1.0)
//                    ]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                VStack(spacing: 20) {
//                    LogoView()
//                    VStack(spacing: 16) {
//                        TextField("Email ID", text: $email)
//                            .autocapitalization(.none)
//                            .keyboardType(.emailAddress)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(6)
//                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))
//                        
//                        TextField("Phone No.", text: $phone)
//                            .keyboardType(.phonePad)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(6)
//                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))
//                        
//                        ZStack(alignment: .trailing) {
//                            Group {
//                                if isPasswordVisible {
//                                    TextField("Password", text: $password)
//                                } else {
//                                    SecureField("Password", text: $password)
//                                }
//                            }
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(6)
//                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))
//                            
//                            Button(action: {
//                                isPasswordVisible.toggle()
//                            }) {
//                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
//                                    .foregroundColor(.gray)
//                                    .padding(.trailing, 12)
//                            }
//                        }
//                        
//                        HStack {
//                            Spacer()
//                            Button("Forgot password?") {}
//                                .font(.system(size: 13, weight: .medium))
//                                .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
//                                .padding(.trailing, 4)
//                        }
//                    }
//                    .padding(.bottom, 12)
//                    
//                    Button(action: onLogin) {
//                        HStack {
//                            Spacer()
//                            Text("Log In")
//                                .font(.system(size: 18, weight: .semibold))
//                            Image(systemName: "arrow.right")
//                                .font(.system(size: 18, weight: .bold))
//                            Spacer()
//                        }
//                        .padding()
//                        .background(Color(red: 51/255, green: 102/255, blue: 204/255))
//                        .foregroundColor(.white)
//                        .cornerRadius(6)
//                    }
//                    .padding(.top, 8)
//                    
//                    Spacer()
//                }
//                .padding(.horizontal, 24)
//                .padding(.top, 24)
//            }
//            
//        }
//    }
//    
//    
//    // MARK: - OTP Screen
//    
//    struct OTPScreen: View {
//        @Binding var otp: String
//        var onNext: () -> Void
//        
//        // Internal state for each digit
//        @State private var otpDigits: [String] = Array(repeating: "", count: 6)
//        @FocusState private var focusedIndex: Int?
//        
//        var body: some View {
//            VStack(spacing: 20) {
//                LogoView()
//                Text("We have sent a verification code to your number")
//                    .font(.system(size: 18))
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.center)
//                    .padding(.top, 8)
//                
//                HStack(spacing: 12) {
//                    ForEach(0..<6, id: \.self) { index in
//                        OTPDigitTextField(
//                            text: $otpDigits[index],
//                            isFocused: focusedIndex == index
//                        )
//                        .focused($focusedIndex, equals: index)
//                        .onChange(of: otpDigits[index]) { newValue in
//                            // Allow only one digit
//                            if newValue.count > 1 {
//                                otpDigits[index] = String(newValue.last!)
//                            }
//                            // Move to next field if current is filled
//                            if !newValue.isEmpty && index < 5 {
//                                focusedIndex = index + 1
//                            }
//                            // Move to previous field if current is empty
//                            if newValue.isEmpty && index > 0 {
//                                focusedIndex = index - 1
//                            }
//                            // Update the combined OTP string
//                            otp = otpDigits.joined()
//                        }
//                    }
//                }
//                .padding(.vertical, 8)
//                
//                HStack {
//                    Text("Didn't get the code?")
//                        .font(.system(size: 13))
//                        .foregroundColor(.gray)
//                    Button("Resend SMS in") {
//                        // Resend action here
//                    }
//                    .font(.system(size: 13, weight: .medium))
//                    .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
//                }
//                .padding(.top, 2)
//                
//                Button(action: onNext) {
//                    HStack {
//                        Spacer()
//                        Text("Next")
//                            .font(.system(size: 18, weight: .semibold))
//                        Image(systemName: "arrow.right")
//                            .font(.system(size: 18, weight: .bold))
//                        Spacer()
//                    }
//                    .padding()
//                    .background(Color(red: 51/255, green: 102/255, blue: 204/255))
//                    .foregroundColor(.white)
//                    .cornerRadius(6)
//                }
//                .padding(.top, 8)
//                .disabled(otpDigits.joined().count < 6) // Disable until all digits are entered
//                
//                Spacer()
//            }
//            .padding(.horizontal, 24)
//            .padding(.top, 24)
//            .onAppear {
//                focusedIndex = 0 // Focus first field on appear
//            }
//        }
//    }
//    
//    // Custom TextField for OTP Digit
//    struct OTPDigitTextField: View {
//        @Binding var text: String
//        var isFocused: Bool
//        
//        var body: some View {
//            TextField("", text: $text)
//                .keyboardType(.numberPad)
//                .multilineTextAlignment(.center)
//                .frame(width: 44, height: 44)
//                .background(Color.white)
//                .cornerRadius(6)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 6)
//                        .stroke(isFocused ? Color.blue : Color.black.opacity(0.5), lineWidth: 2)
//                )
//                .font(.system(size: 20, weight: .bold))
//        }
//    }
//    // MARK: - Preview
//    
//    struct AuthRootView_Previews: PreviewProvider {
//        static var previews: some View {
//            AuthRootView()
//        }
//    }
//}


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
