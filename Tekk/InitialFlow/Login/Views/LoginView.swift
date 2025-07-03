//
//  LoginView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI
import RiveRuntime
import SwiftKeychainWrapper


// Login page
struct LoginView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var userManager: UserManager
    @ObservedObject var forgotPasswordModel: ForgotPasswordModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
                Text("Welcome Back!")
                    .font(.custom("PottaOne-Regular", size: 32))
                    .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                
            RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                    .frame(width: 200, height: 200)
                    .padding()
                
                VStack(spacing: 15) {
                    // Email Field
                    TextField("Email", text: $email)
                        .padding()
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                    
                    // Password Field
                    ZStack(alignment: .trailing) {
                        if onboardingModel.isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding()
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                                .keyboardType(.default)
                        } else {
                            SecureField("Password", text: $password)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                                .keyboardType(.default)
                            
                        }
                        
                        // Eye icon for password visibility toggle
                        Button(action: {
                            Haptic.light()
                            onboardingModel.isPasswordVisible.toggle()
                        }) {
                            Image(systemName: onboardingModel.isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(onboardingModel.globalSettings.primaryYellowColor)
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding(.horizontal)
                
                // Forgot Password Button
                Button(action: {
                    forgotPasswordModel.showForgotPasswordPage = true
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(onboardingModel.globalSettings.primaryYellowColor)
                        .padding(.top, 4)
                }
                .sheet(isPresented: $forgotPasswordModel.showForgotPasswordPage) {
                    ForgotPasswordSheet(onboardingModel: onboardingModel, forgotPasswordModel: forgotPasswordModel)
                }
                
                // Error message
                if !onboardingModel.errorMessage.isEmpty {
                    Text(onboardingModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.horizontal)
                }
                
            
                // Login button
            
                PrimaryButton(
                    title: "Login",
                    action: {
                        Haptic.light()
                        withAnimation(.spring()) {
                            loginUser()
                        }
                    },
                    frontColor: onboardingModel.globalSettings.primaryYellowColor,
                    backColor: onboardingModel.globalSettings.primaryDarkYellowColor,
                    textColor: Color.white,
                    textSize: 18,
                    width: .infinity,
                    height: 50,
                    disabled: false
                )
                .padding(.horizontal)
                .padding(.top)
            
            
                
            
                // Cancel button
                PrimaryButton(
                    title: "Cancel",
                    action: {
                        Haptic.light()
                        withAnimation(.spring()) {
                            resetLoginInfo()
                        }
                    },
                    frontColor: Color.white,
                    backColor: onboardingModel.globalSettings.primaryLightGrayColor,
                    textColor: onboardingModel.globalSettings.primaryYellowColor,
                    textSize: 18,
                    width: .infinity,
                    height: 50,
                    borderColor: onboardingModel.globalSettings.primaryLightGrayColor,
                    disabled: false
                )
                .padding(.horizontal)
            
                
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            // Add this modifier to handle keyboard
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    

    // Resets login info and error message when user cancels login page
    func resetLoginInfo() {
        userManager.showLoginPage = false
        email = ""
        password = ""
        onboardingModel.errorMessage = ""
    }

    
    // MARK: - Login user function
    // function for login user
    func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            self.onboardingModel.errorMessage = "Please fill in all fields."
            return
        }

        Task {
            let loginDetails = [
                "email": email,
                "password": password
            ]
            let body = try? JSONSerialization.data(withJSONObject: loginDetails)
            do {
                let (data, response) = try await APIService.shared.request(
                    endpoint: "/login/",
                    method: "POST",
                    headers: ["Content-Type": "application/json"],
                    body: body,
                    retryOn401: false,
                    debounceKey: "login_request",
                    debounceInterval: 1.0
                )
                if response.statusCode == 200 {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    DispatchQueue.main.async {
                        userManager.accessToken = loginResponse.access_token
                        KeychainWrapper.standard.set(loginResponse.access_token, forKey: "accessToken")
                        if let refreshToken = loginResponse.refresh_token {
                            KeychainWrapper.standard.set(refreshToken, forKey: "refreshToken")
                        }
                        // Save user info to Keychain (only email now)
                        userManager.updateUserKeychain(
                            email: loginResponse.email
                        )
                        userManager.userHasAccountHistory = true
                        userManager.isLoggedIn = true
                        userManager.showLoginPage = false
                        print("🔑 Token saved to keychain: \(KeychainWrapper.standard.string(forKey: "accessToken") ?? "nil")")
                        print("🔑 Refresh token saved to keychain: \(KeychainWrapper.standard.string(forKey: "refreshToken") ?? "nil")")
                        print("Auth token: \(userManager.accessToken)")
                        print("Login success: \(userManager.isLoggedIn)")
                    }
                } else if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        self.onboardingModel.errorMessage = "Invalid credentials, please try again."
                        print("❌ Login failed: Invalid credentials")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.onboardingModel.errorMessage = "Failed to login. Please try again."
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("Response data not fully completed: \(responseString)")
                        }
                    }
                }
            } catch URLError.timedOut {
                print("⏱️ Login request debounced - too soon since last request")
            } catch {
                DispatchQueue.main.async {
                    self.onboardingModel.errorMessage = "Network error. Please try again."
                    print("Login error: \(error.localizedDescription)")
                }
            }
        }
    }

}


//#if DEBUG
//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Provide mock models for preview
//        let onboardingModel = OnboardingModel()
//        let userManager = UserManager()
//        LoginView(onboardingModel: onboardingModel, userManager: userManager)
//            .background(Color(.systemBackground))
//            .previewLayout(.sizeThatFits)
//    }
//}
//#endif
