//
//  LoginView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI
import RiveRuntime
import SwiftKeychainWrapper


// expected response structure from backend after POST request to login endpoint
struct LoginResponse: Codable {
    let access_token: String
    let token_type: String
    let email: String
    let refresh_token: String?
}


// Login page
struct LoginView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var userManager: UserManager
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
                    onboardingModel.showForgotPasswordPage = true
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(onboardingModel.globalSettings.primaryYellowColor)
                        .padding(.top, 4)
                }
                .sheet(isPresented: $onboardingModel.showForgotPasswordPage) {
                    ForgotPasswordSheet(onboardingModel: onboardingModel)
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
        onboardingModel.showLoginPage = false
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
                        onboardingModel.accessToken = loginResponse.access_token
                        KeychainWrapper.standard.set(loginResponse.access_token, forKey: "accessToken")
                        if let refreshToken = loginResponse.refresh_token {
                            KeychainWrapper.standard.set(refreshToken, forKey: "refreshToken")
                        }
                        // Save user info to Keychain (only email now)
                        userManager.updateUserKeychain(
                            email: loginResponse.email
                        )
                        userManager.userHasAccountHistory = true
                        onboardingModel.isLoggedIn = true
                        onboardingModel.showLoginPage = false
                        print("🔑 Token saved to keychain: \(KeychainWrapper.standard.string(forKey: "accessToken") ?? "nil")")
                        print("🔑 Refresh token saved to keychain: \(KeychainWrapper.standard.string(forKey: "refreshToken") ?? "nil")")
                        print("Auth token: \(self.onboardingModel.accessToken)")
                        print("Login success: \(self.onboardingModel.isLoggedIn)")
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

// Forgot Password Sheet
struct ForgotPasswordSheet: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSending = false
    
    private var messageColor: Color {
        let message = onboardingModel.forgotPasswordMessage.lowercased()
        
        // Success messages
        if message.contains("sent") || 
           message.contains("verified") || 
           message.contains("successfully") {
            return .green
        }
        
        // Error messages
        return .red
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                switch onboardingModel.forgotPasswordStep {
                case 1:
                    emailStepView
                case 2:
                    codeStepView
                case 3:
                    passwordStepView
                default:
                    emailStepView
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { 
                        onboardingModel.resetForgotPasswordState()
                        dismiss() 
                    }
                }
            }
        }
    }
    
    // Step 1: Email Input
    private var emailStepView: some View {
        VStack(spacing: 20) {
            Text("Reset Your Password")
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                .padding(.top)
            
            Text("Enter your email address and we'll send you a 6-digit verification code.")
                .font(.custom("Poppins-Regular", size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Email", text: $onboardingModel.forgotPasswordEmail)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
            
            if !onboardingModel.forgotPasswordMessage.isEmpty {
                Text(onboardingModel.forgotPasswordMessage)
                    .foregroundColor(messageColor)
                    .font(.system(size: 14))
                    .padding(.horizontal)
            }
            
            Spacer()
            
            PrimaryButton(
                title: "Send Verification Code",
                action: {
                    guard !onboardingModel.forgotPasswordEmail.isEmpty else { return }
                    isSending = true
                    Task {
                        await onboardingModel.sendForgotPassword(email: onboardingModel.forgotPasswordEmail)
                        isSending = false
                    }
                },
                frontColor: onboardingModel.globalSettings.primaryYellowColor,
                backColor: onboardingModel.globalSettings.primaryDarkYellowColor,
                textColor: Color.white,
                textSize: 18,
                width: .infinity,
                height: 50,
                disabled: onboardingModel.forgotPasswordEmail.isEmpty
                    
            )
            .disabled(isSending)
            .padding()
        }
    }
    
    // Step 2: Code Verification
    private var codeStepView: some View {
        VStack(spacing: 20) {
            Text("Enter Verification Code")
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                .padding(.top)
            
            Text("We've sent a 6-digit code to \(onboardingModel.forgotPasswordEmail)")
                .font(.custom("Poppins-Regular", size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("6-digit code", text: $onboardingModel.forgotPasswordCode)
                .padding()
                .keyboardType(.numberPad)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
                .onChange(of: onboardingModel.forgotPasswordCode) { newValue in
                    // Limit to 6 digits
                    if newValue.count > 6 {
                        onboardingModel.forgotPasswordCode = String(newValue.prefix(6))
                    }
                }
            
            if !onboardingModel.forgotPasswordMessage.isEmpty {
                Text(onboardingModel.forgotPasswordMessage)
                    .foregroundColor(messageColor)
                    .font(.system(size: 14))
                    .padding(.horizontal)
            }
            
            Spacer()
            
            PrimaryButton(
                title: "Verify Code",
                action: {
                    guard onboardingModel.forgotPasswordCode.count == 6 else { return }
                    isSending = true
                    Task {
                        await onboardingModel.verifyResetCode(code: onboardingModel.forgotPasswordCode)
                        isSending = false
                    }
                },
                frontColor: onboardingModel.globalSettings.primaryYellowColor,
                backColor: onboardingModel.globalSettings.primaryDarkYellowColor,
                textColor: Color.white,
                textSize: 18,
                width: .infinity,
                height: 50,
                disabled: onboardingModel.forgotPasswordCode.count != 6
                    
            )
            .disabled(isSending)
            .padding(.horizontal)
            
            PrimaryButton(
                title: "Resend Code",
                action: {
                    isSending = true
                    Task {
                        await onboardingModel.sendForgotPassword(email: onboardingModel.forgotPasswordEmail)
                        isSending = false
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
            .disabled(isSending)
            .padding(.horizontal)
        }
    }
    
    // Step 3: New Password
    private var passwordStepView: some View {
        VStack(spacing: 20) {
            Text("Set New Password")
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                .padding(.top)
            
            Text("Enter your new password")
                .font(.custom("Poppins-Regular", size: 15))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // New Password Field
            ZStack(alignment: .trailing) {
                if onboardingModel.isNewPasswordVisible {
                    TextField("New Password", text: $onboardingModel.forgotPasswordNewPassword)
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                } else {
                    SecureField("New Password", text: $onboardingModel.forgotPasswordNewPassword)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                }
                
                Button(action: {
                    onboardingModel.isNewPasswordVisible.toggle()
                }) {
                    Image(systemName: onboardingModel.isNewPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(onboardingModel.globalSettings.primaryYellowColor)
                }
                .padding(.trailing, 10)
            }
            .padding(.horizontal)
            
            // Confirm Password Field
            SecureField("Confirm New Password", text: $onboardingModel.forgotPasswordConfirmPassword)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
            
            if !onboardingModel.forgotPasswordMessage.isEmpty {
                Text(onboardingModel.forgotPasswordMessage)
                    .foregroundColor(messageColor)
                    .font(.system(size: 14))
                    .padding(.horizontal)
            }
            
            Spacer()
            
            PrimaryButton(
                title: "Reset Password",
                action: {
                    guard !onboardingModel.forgotPasswordNewPassword.isEmpty && !onboardingModel.forgotPasswordConfirmPassword.isEmpty else { return }
                    isSending = true
                    Task {
                        await onboardingModel.resetPassword(
                            newPassword: onboardingModel.forgotPasswordNewPassword,
                            confirmPassword: onboardingModel.forgotPasswordConfirmPassword
                        )
                        isSending = false
                    }
                },
                frontColor: onboardingModel.globalSettings.primaryYellowColor,
                backColor: onboardingModel.globalSettings.primaryDarkYellowColor,
                textColor: Color.white,
                textSize: 18,
                width: .infinity,
                height: 50,
                disabled: onboardingModel.forgotPasswordNewPassword.isEmpty || onboardingModel.forgotPasswordConfirmPassword.isEmpty
                    
            )
            .disabled(isSending)
            .padding()
            
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
