//import SwiftUI
//import FirebaseAuth
//import FirebaseFirestore
//
//enum AuthScreen {
//    case login
//    case home
//}
//
////MARK: authentication rootView
//struct AuthRootView: View {
//    @StateObject private var authViewModel = AuthViewModel()
//    @State private var screen: AuthScreen = .login
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var isPasswordVisible: Bool = false
//    @State private var showAlert: Bool = false
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
//                        password: $password,
//                        isPasswordVisible: $isPasswordVisible,
//                        authViewModel: authViewModel,
//                        onLogin: {
//                            guard !email.isEmpty else {
//                                authViewModel.errorMessage = "Please enter an email"
//                                showAlert = true
//                                return
//                            }
//
//                            guard !password.isEmpty else {
//                                authViewModel.errorMessage = "Please enter a password"
//                                showAlert = true
//                                return
//                            }
//
//                            authViewModel.signInWithEmail(email: email, password: password) { success in
//                                if success {
//                                    screen = .home
//                                } else {
//                                    showAlert = true
//                                }
//                            }
//                        }
//                    )
//
//                case .home:
//                    Text("Welcome to Fleet Management System")
//                        .font(.title)
//                        .padding()
//
//                    Button("Sign Out") {
//                        authViewModel.signOut()
//                        screen = .login
//                    }
//                    .padding()
//                    .background(Color(red: 51/255, green: 102/255, blue: 204/255))
//                    .foregroundColor(.white)
//                    .cornerRadius(6)
//                }
//                Spacer()
//            }
//        }
//        .alert("Error", isPresented: $showAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(authViewModel.errorMessage ?? "An error occurred")
//        }
//        .onAppear {
//            authViewModel.checkAuthStatus()
//            if authViewModel.isAuthenticated {
//                screen = .home
//            }
//        }
//    }
//}
//
//struct LoginScreen: View {
//    @Binding var email: String
//    @Binding var password: String
//    @Binding var isPasswordVisible: Bool
//    @ObservedObject var authViewModel: AuthViewModel
//    var onLogin: () -> Void
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.85, green: 0.9, blue: 0.97),
//                    Color(red: 0.96, green: 0.98, blue: 1.0)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                VStack {
//                    LogoView()
//                        .frame(width: 120, height: 120)
//                        .padding(.top, 40)
//
//                    Spacer().frame(height: 24) // spacing below logo
//                }
//
//                VStack(spacing: 16) {
//                    TextField("Email ID", text: $email)
//                        .autocapitalization(.none)
//                        .keyboardType(.emailAddress)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(6)
//                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))
//
//                    ZStack(alignment: .trailing) {
//                        Group {
//                            if isPasswordVisible {
//                                TextField("Password", text: $password)
//                            } else {
//                                SecureField("Password", text: $password)
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(6)
//                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))
//
//                        Button(action: {
//                            isPasswordVisible.toggle()
//                        }) {
//                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
//                                .foregroundColor(.gray)
//                                .padding(.trailing, 12)
//                        }
//                    }
//
//                    HStack {
//                        Spacer()
//                        Button("Forgot password?") {}
//                            .font(.system(size: 13, weight: .medium))
//                            .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
//                            .padding(.trailing, 4)
//                    }
//                }
//                .padding(.bottom, 12)
//
//                Button(action: onLogin) {
//                    HStack {
//                        Spacer()
//                        if authViewModel.isLoading {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        } else {
//                            Text("Log In")
//                                .font(.system(size: 18, weight: .semibold))
//                            Image(systemName: "arrow.right")
//                                .font(.system(size: 18, weight: .bold))
//                        }
//                        Spacer()
//                    }
//                    .padding()
//                    .background(Color(red: 51/255, green: 102/255, blue: 204/255))
//                    .foregroundColor(.white)
//                    .cornerRadius(6)
//                }
//                .disabled(authViewModel.isLoading)
//                .padding(.top, 8)
//
//                Spacer()
//            }
//            .padding(.horizontal, 24)
//            .padding(.top, 24)
//        }
//    }
//}
//
//struct LogoView: View {
//    var body: some View {
//        Image("logo")
//            .resizable()
//            .scaledToFit()
//            .frame(width: 120, height: 120)
//    }
//}
//
//struct AuthRootView_Previews: PreviewProvider {
//    static var previews: some View {
//        AuthRootView()
//    }
//}
//
//
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum AuthScreen {
    case login
    case otpVerification
    case home
}

//MARK: - Authentication Root View
struct AuthRootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var screen: AuthScreen = .login
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false

    var body: some View {
        ZStack {
            Color(red: 238/255, green: 247/255, blue: 255/255).ignoresSafeArea()
            VStack {
                Spacer()
                switch screen {
                case .login:
                    LoginScreen(
                        email: $email,
                        password: $password,
                        phoneNumber: $phoneNumber,
                        isPasswordVisible: $isPasswordVisible,
                        authViewModel: authViewModel,
                        onLogin: {
                            // Validate inputs
                            guard !email.isEmpty else {
                                authViewModel.errorMessage = "Please enter an email"
                                showAlert = true
                                return
                            }

                            guard !password.isEmpty else {
                                authViewModel.errorMessage = "Please enter a password"
                                showAlert = true
                                return
                            }

                            guard !phoneNumber.isEmpty else {
                                authViewModel.errorMessage = "Please enter a phone number"
                                showAlert = true
                                return
                            }

                            // Sign in with email first
                            authViewModel.signInWithEmail(email: email, password: password) { success in
                                if success {
                                    // After successful email login, proceed to OTP verification
                                    screen = .otpVerification
                                } else {
                                    showAlert = true
                                }
                            }
                        }
                    )

                case .otpVerification:
                    PhoneEntryView(
                        authViewModel: authViewModel,
                        initialPhoneNumber: phoneNumber,
                        onVerificationComplete: {
                            // Complete full authentication and go to home screen
                            authViewModel.completeAuthentication()
                            screen = .home
                        }
                    )

                case .home:
                    VStack(spacing: 20) {
                        Text("Welcome to Fleet Management System")
                            .font(.title)
                        
                        if let user = authViewModel.currentUser {
                            Text("Logged in as: \(user.email ?? "User")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Button("Sign Out") {
                            authViewModel.signOut()
                            screen = .login
                            email = ""; password = ""; phoneNumber = ""
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                }

                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Authentication Error"),
                    message: Text(authViewModel.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            authViewModel.checkAuthStatus()
            if authViewModel.isAuthenticated {
                screen = .home
            }
        }
    }
}

struct LoginScreen: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var phoneNumber: String
    @Binding var isPasswordVisible: Bool
    @ObservedObject var authViewModel: AuthViewModel
    var onLogin: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.9, blue: 0.97),
                    Color(red: 0.96, green: 0.98, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack {
                    LogoView()
                        .frame(width: 120, height: 120)
                        .padding(.top, 40)

                    Spacer().frame(height: 24)
                }

                VStack(spacing: 16) {
                    TextField("Email ID", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))

                    ZStack(alignment: .trailing) {
                        Group {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))

                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }

                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.5)))

                    HStack {
                        Spacer()
                        Button("Forgot password?") {}
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 51/255, green: 102/255, blue: 204/255))
                            .padding(.trailing, 4)
                    }
                }
                .padding(.bottom, 12)

                Button(action: onLogin) {
                    HStack {
                        Spacer()
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Log In")
                                .font(.system(size: 18, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 51/255, green: 102/255, blue: 204/255))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .disabled(authViewModel.isLoading)
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
    }
}

struct LogoView: View {
    var body: some View {
        Image("logo")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .onAppear {
                // If you don't have a logo image, this will handle the error gracefully
                print("Note: Add a 'logo' image to your assets or modify LogoView")
            }
    }
}
