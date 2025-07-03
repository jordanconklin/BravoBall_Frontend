//
//  ForgotPasswordSheet.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//

import SwiftUI

// Forgot Password Sheet
struct ForgotPasswordSheet: View {
    @ObservedObject var forgotPasswordModel: ForgotPasswordModel
    let forgotPasswordService = ForgotPasswordService.shared
    let globalSettings = GlobalSettings.shared
    
    @Environment(\.dismiss) private var dismiss
    @State private var isSending = false
    
    private var messageColor: Color {
        let message = forgotPasswordModel.forgotPasswordMessage.lowercased()
        
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
                switch forgotPasswordModel.forgotPasswordStep {
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
                        forgotPasswordModel.resetForgotPasswordState()
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
                .foregroundColor(globalSettings.primaryDarkColor)
                .padding(.top)
            
            Text("Enter your email address and we'll send you a 6-digit verification code.")
                .font(.custom("Poppins-Regular", size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Email", text: $forgotPasswordModel.forgotPasswordEmail)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
            
            if !forgotPasswordModel.forgotPasswordMessage.isEmpty {
                Text(forgotPasswordModel.forgotPasswordMessage)
                    .foregroundColor(messageColor)
                    .font(.system(size: 14))
                    .padding(.horizontal)
            }
            
            Spacer()
            
            PrimaryButton(
                title: "Send Verification Code",
                action: {
                    Haptic.light()
                    guard !forgotPasswordModel.forgotPasswordEmail.isEmpty else { return }
                    isSending = true
                    Task {
                        await forgotPasswordService.sendForgotPassword(email: forgotPasswordModel.forgotPasswordEmail, forgotPasswordModel: forgotPasswordModel)
                        isSending = false
                    }
                },
                frontColor: globalSettings.primaryYellowColor,
                backColor: globalSettings.primaryDarkYellowColor,
                textColor: Color.white,
                textSize: 18,
                width: .infinity,
                height: 50,
                disabled: forgotPasswordModel.forgotPasswordEmail.isEmpty
                    
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
                .foregroundColor(globalSettings.primaryDarkColor)
                .padding(.top)
            
            Text("We've sent a 6-digit code to \(forgotPasswordModel.forgotPasswordEmail)")
                .font(.custom("Poppins-Regular", size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("6-digit code", text: $forgotPasswordModel.forgotPasswordCode)
                .padding()
                .keyboardType(.numberPad)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
                .onChange(of: forgotPasswordModel.forgotPasswordCode) { index, newValue in
                    // Limit to 6 digits
                    if newValue.count > 6 {
                        forgotPasswordModel.forgotPasswordCode = String(newValue.prefix(6))
                    }
                }
            
            if !forgotPasswordModel.forgotPasswordMessage.isEmpty {
                Text(forgotPasswordModel.forgotPasswordMessage)
                    .foregroundColor(messageColor)
                    .font(.system(size: 14))
                    .padding(.horizontal)
            }
            
            Spacer()
            
            PrimaryButton(
                title: "Verify Code",
                action: {
                    Haptic.light()
                    guard forgotPasswordModel.forgotPasswordCode.count == 6 else { return }
                    isSending = true
                    Task {
                        await forgotPasswordService.verifyResetCode(code: forgotPasswordModel.forgotPasswordCode, forgotPasswordModel: forgotPasswordModel)
                        isSending = false
                    }
                },
                frontColor: globalSettings.primaryYellowColor,
                backColor: globalSettings.primaryDarkYellowColor,
                textColor: Color.white,
                textSize: 18,
                width: .infinity,
                height: 50,
                disabled: forgotPasswordModel.forgotPasswordCode.count != 6
                    
            )
            .disabled(isSending)
            .padding(.horizontal)
            
            PrimaryButton(
                title: "Resend Code",
                action: {
                    Haptic.light()
                    isSending = true
                    Task {
                        await forgotPasswordService.sendForgotPassword(email: forgotPasswordModel.forgotPasswordEmail, forgotPasswordModel: forgotPasswordModel)
                        isSending = false
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
            .disabled(isSending)
            .padding(.horizontal)
        }
    }
    
    // Step 3: New Password
    private var passwordStepView: some View {
        VStack(spacing: 20) {
            Text("Set New Password")
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundColor(globalSettings.primaryDarkColor)
                .padding(.top)
            
            Text("Enter your new password")
                .font(.custom("Poppins-Regular", size: 15))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // New Password Field
            ZStack(alignment: .trailing) {
                if forgotPasswordModel.isNewPasswordVisible {
                    TextField("New Password", text: $forgotPasswordModel.forgotPasswordNewPassword)
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                } else {
                    SecureField("New Password", text: $forgotPasswordModel.forgotPasswordNewPassword)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                }
                
                Button(action: {
                    forgotPasswordModel.isNewPasswordVisible.toggle()
                }) {
                    Image(systemName: forgotPasswordModel.isNewPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(globalSettings.primaryYellowColor)
                }
                .padding(.trailing, 10)
            }
            .padding(.horizontal)
            
            // Confirm Password Field
            SecureField("Confirm New Password", text: $forgotPasswordModel.forgotPasswordConfirmPassword)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
            
            if !forgotPasswordModel.forgotPasswordMessage.isEmpty {
                Text(forgotPasswordModel.forgotPasswordMessage)
                    .foregroundColor(messageColor)
                    .font(.system(size: 14))
                    .padding(.horizontal)
            }
            
            Spacer()
            
            PrimaryButton(
                title: "Reset Password",
                action: {
                    Haptic.light()
                    guard !forgotPasswordModel.forgotPasswordNewPassword.isEmpty && !forgotPasswordModel.forgotPasswordConfirmPassword.isEmpty else { return }
                    isSending = true
                    Task {
                        await forgotPasswordService.resetPassword(
                            newPassword: forgotPasswordModel.forgotPasswordNewPassword,
                            confirmPassword: forgotPasswordModel.forgotPasswordConfirmPassword,
                            forgotPasswordModel: forgotPasswordModel
                        )
                        isSending = false
                    }
                },
                frontColor: globalSettings.primaryYellowColor,
                backColor: globalSettings.primaryDarkYellowColor,
                textColor: Color.white,
                textSize: 18,
                width: .infinity,
                height: 50,
                disabled: forgotPasswordModel.forgotPasswordNewPassword.isEmpty || forgotPasswordModel.forgotPasswordConfirmPassword.isEmpty
                    
            )
            .disabled(isSending)
            .padding()
            
        }
    }
}
