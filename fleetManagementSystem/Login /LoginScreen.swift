import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

enum AuthScreen {
    case login
    case otp
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
    @Published var phoneNumber: String = ""
    @Published var otp: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var userRole: UserRole = .unknown
    @Published var resendCounter: Int = 30
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var resendTimer: Timer?
    private var isEmailAuthenticated = false
    
    // For storing the verification ID securely
    private var verificationID: String = ""
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please fill all fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                return
            }
            
            // First factor succeeded - email is authenticated
            self.isEmailAuthenticated = true
            // Proceed to fetch user data and send OTP
            self.fetchUserDataAndSendOTP()
        }
    }
    
    func fetchUserDataAndSendOTP() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.isLoading = false
            self.errorMessage = "User not authenticated"
            return
        }
        
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let document = document, document.exists {
                // Store role information
                if let roleString = document.data()?["role"] as? String,
                   let role = UserRole(rawValue: roleString) {
                    self.userRole = role
                } else {
                    self.userRole = .unknown
                }
                
                // Get phone number and send OTP
                if let phone = document.data()?["phone"] as? String {
                    self.phoneNumber = phone
                    self.sendOTP()
                } else {
                    self.isLoading = false
                    self.errorMessage = "No phone number associated with this account"
                }
            } else {
                self.isLoading = false
                self.errorMessage = "User profile not found"
            }
        }
    }
    
    func sendOTP() {
        // Format the phone number with country code
        let formattedPhone = phoneNumber.hasPrefix("+") ? phoneNumber : "+91\(phoneNumber)"
        
        // CRITICAL: Disable app verification before sending the OTP
        // This bypasses the need for Apple Developer account
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        
        // Use Firebase Phone Auth API to send the SMS
        PhoneAuthProvider.provider().verifyPhoneNumber(formattedPhone, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                let authError = error as NSError
                print("Firebase Auth Error: \(error.localizedDescription)")
                
                // Handle specific error cases
                if authError.code == AuthErrorCode.invalidPhoneNumber.rawValue {
                    self.errorMessage = "Invalid phone number format. Please check and try again."
                } else if authError.code == AuthErrorCode.quotaExceeded.rawValue {
                    self.errorMessage = "Too many requests. Please try again later."
                } else {
                    self.errorMessage = "Error sending verification code: \(error.localizedDescription)"
                }
                return
            }
            
            guard let verificationID = verificationID else {
                self.errorMessage = "Failed to get verification ID"
                return
            }
            
            // Store the verification ID
            self.verificationID = verificationID
            
            // Set up resend counter
            self.resendCounter = 30
            self.startResendTimer()
            
            // Show OTP screen
            self.screen = .otp
        }
    }
    
    private func startResendTimer() {
        resendTimer?.invalidate()
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.resendCounter > 0 {
                self.resendCounter -= 1
            } else {
                self.resendTimer?.invalidate()
            }
        }
    }
    
    func verifyOTP() {
        guard !otp.isEmpty else {
            self.errorMessage = "Please enter the OTP"
            return
        }
        
        guard !verificationID.isEmpty else {
            self.errorMessage = "Invalid verification session"
            return
        }
        
        isLoading = true
        
        // Create credential with the verification ID and user-entered code
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otp
        )
        
        // Verify the credential
        if isEmailAuthenticated, let user = Auth.auth().currentUser {
            user.link(with: credential) { [weak self] result, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    let authError = error as NSError
                    
                    if authError.code == AuthErrorCode.invalidVerificationCode.rawValue {
                        self.errorMessage = "Invalid verification code. Please check and try again."
                    } else if authError.code == AuthErrorCode.sessionExpired.rawValue {
                        self.errorMessage = "Verification session expired. Please request a new code."
                    } else {
                        self.errorMessage = "Failed to verify OTP: \(error.localizedDescription)"
                    }
                    return
                }
                
                // Both factors verified successfully
                self.screen = .home
            }
        } else {
            self.isLoading = false
            self.errorMessage = "Email authentication required before OTP verification"
        }
    }
    
    func resendOTP() {
        if resendCounter <= 0 {
            sendOTP()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            screen = .login
            email = ""
            password = ""
            otp = ""
            isEmailAuthenticated = false
            verificationID = ""
            resendTimer?.invalidate()
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
                    
                case .otp:
                    OTPScreen(viewModel: viewModel)
                    
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

struct OTPScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    
    // State for individual digit inputs
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    
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
                
                Text("We have sent a verification code to your phone number")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                Text(viewModel.phoneNumber.hasPrefix("+") ? viewModel.phoneNumber : "+91\(viewModel.phoneNumber)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, -10)
                
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        OTPDigitTextField(
                            text: $otpDigits[index],
                            isFocused: focusedIndex == index
                        )
                        .focused($focusedIndex, equals: index)
                        .onChange(of: otpDigits[index]) { newValue in
                            // Allow only one digit
                            if newValue.count > 1 {
                                otpDigits[index] = String(newValue.last!)
                            }
                            // Move to next field if current is filled
                            if !newValue.isEmpty && index < 5 {
                                focusedIndex = index + 1
                            }
                            // Move to previous field if current is empty
                            if newValue.isEmpty && index > 0 {
                                focusedIndex = index - 1
                            }
                            // Update the combined OTP string
                            viewModel.otp = otpDigits.joined()
                        }
                    }
                }
                .padding(.vertical, 8)
                
                HStack {
                    Text("Didn't get the code?")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    Button(viewModel.resendCounter > 0 ? "Resend SMS in \(viewModel.resendCounter)s" : "Resend SMS") {
                        viewModel.resendOTP()
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(viewModel.resendCounter > 0 ? .gray : Color(red: 51/255, green: 102/255, blue: 204/255))
                    .disabled(viewModel.resendCounter > 0)
                }
                .padding(.top, 2)
                
                Button(action: viewModel.verifyOTP) {
                    HStack {
                        Spacer()
                        Text("Verify")
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
                .disabled(viewModel.otp.count < 6)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .onAppear {
                focusedIndex = 0 // Focus first field on appear
            }
        }
    }
}

struct OTPDigitTextField: View {
    @Binding var text: String
    var isFocused: Bool
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .frame(width: 44, height: 44)
            .background(Color.white)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isFocused ? Color.blue : Color.black.opacity(0.5), lineWidth: 2)
            )
            .font(.system(size: 20, weight: .bold))
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
                FleetManagerScreen(viewModel: viewModel)
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

struct FleetManagerScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Fleet Manager Dashboard").font(.largeTitle).padding()
                Text("Welcome to the Fleet Manager Portal").font(.title2)
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
            .navigationTitle("Fleet Manager Portal")
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
