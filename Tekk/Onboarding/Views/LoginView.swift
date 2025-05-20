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
    let first_name: String
    let last_name: String
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
                            onboardingModel.isPasswordVisible.toggle()
                        }) {
                            Image(systemName: onboardingModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(onboardingModel.globalSettings.primaryYellowColor)
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding(.horizontal)
            
                
                // Error message
                if !onboardingModel.errorMessage.isEmpty {
                    Text(onboardingModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.horizontal)
                }
                
            
                // Login button
                Button(action: {
                    withAnimation(.spring()) {
                        loginUser()
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(onboardingModel.globalSettings.primaryYellowColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal)
                .padding(.top)
                
            
                // Cancel button
                Button(action: {
                    withAnimation(.spring()) {
                        resetLoginInfo()
                    }
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.gray.opacity(0.2))
                        .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
                        .cornerRadius(12)
                        .font(.system(size: 16, weight: .semibold))
                }
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

        let loginDetails = [
            "email": email,
            "password": password
        ]

        // sending HTTP POST request to FastAPI app running locally
        let url = URL(string: "http://127.0.0.1:8000/login/")!
        var request = URLRequest(url: url)

        print("current token: \(onboardingModel.authToken)")
        // HTTP POST request to login user and receive JWT token
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: loginDetails)

        // Start URL session to interact with backend
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let data = data,
                       let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        DispatchQueue.main.async {
                            onboardingModel.authToken = decodedResponse.access_token
                            
                            KeychainWrapper.standard.set(self.onboardingModel.authToken, forKey: "authToken")
                            onboardingModel.isLoggedIn = true
                            onboardingModel.showLoginPage = false
                            
                            userManager.updateUserKeychain(
                                email: decodedResponse.email,
                                firstName: decodedResponse.first_name,
                                lastName: decodedResponse.last_name
                            )
                            
                            print("Auth token: \(self.onboardingModel.authToken)")
                            print("Login success: \(self.onboardingModel.isLoggedIn)")
                            print("Email: \(decodedResponse.email)")
                            print("First name: \(decodedResponse.first_name)")
                            print("Last name: \(decodedResponse.last_name)")
                        }
                    }
                case 401:
                    DispatchQueue.main.async {
                        self.onboardingModel.errorMessage = "Invalid credentials, please try again."
                        print("❌ Login failed: Invalid credentials")
                    }
                default:
                    DispatchQueue.main.async {
                        self.onboardingModel.errorMessage = "Failed to login. Please try again."
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("Response data not fully completed: \(responseString)")
                        }
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.onboardingModel.errorMessage = "Network error. Please try again."
                    print("Login error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

}
