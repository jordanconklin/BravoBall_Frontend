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
    @ObservedObject var userManager: UserManager
    @ObservedObject var forgotPasswordModel: ForgotPasswordModel
    @ObservedObject var loginModel: LoginModel
    let loginService = LoginService.shared
    let globalSettings = GlobalSettings.shared
    

    
    var body: some View {
        VStack(spacing: 20) {
                Text("Welcome Back!")
                    .font(.custom("PottaOne-Regular", size: 32))
                    .foregroundColor(globalSettings.primaryDarkColor)
                
            RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                    .frame(width: 200, height: 200)
                    .padding()
                
                VStack(spacing: 15) {
                    // Email Field
                    TextField("Email", text: $loginModel.email)
                        .padding()
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                    
                    // Password Field
                    ZStack(alignment: .trailing) {
                        if loginModel.isPasswordVisible {
                            TextField("Password", text: $loginModel.password)
                                .padding()
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                                .keyboardType(.default)
                        } else {
                            SecureField("Password", text: $loginModel.password)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                                .keyboardType(.default)
                            
                        }
                        
                        // Eye icon for password visibility toggle
                        Button(action: {
                            Haptic.light()
                            loginModel.isPasswordVisible.toggle()
                        }) {
                            Image(systemName: loginModel.isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(globalSettings.primaryYellowColor)
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
                        .foregroundColor(globalSettings.primaryYellowColor)
                        .padding(.top, 4)
                }
                .sheet(isPresented: $forgotPasswordModel.showForgotPasswordPage) {
                    ForgotPasswordSheet(forgotPasswordModel: forgotPasswordModel)
                }
                
                // Error message
            if !loginModel.errorMessage.isEmpty {
                Text(loginModel.errorMessage)
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
                            Task {
                                await loginService.loginUser(userManager: userManager, loginModel: loginModel)
                            }
                        }
                    },
                    frontColor: globalSettings.primaryYellowColor,
                    backColor: globalSettings.primaryDarkYellowColor,
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
                            loginModel.resetLoginInfo()
                        }
                    },
                    frontColor: Color.white,
                    backColor: globalSettings.primaryLightGrayColor,
                    textColor: globalSettings.primaryYellowColor,
                    textSize: 18,
                    width: .infinity,
                    height: 50,
                    borderColor: globalSettings.primaryLightGrayColor,
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
