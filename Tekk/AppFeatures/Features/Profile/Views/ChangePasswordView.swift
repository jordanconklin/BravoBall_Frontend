//
//  ChangePasswordView.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @ObservedObject var globalSettings: GlobalSettings
    @ObservedObject var settingsModel: SettingsModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAlertError = true
    @State private var isCurrentPasswordVisible = false
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        Haptic.light()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(globalSettings.primaryDarkColor)
                    }
                    Spacer()
                    Text("Change Password")
                        .font(.custom("Poppins-Bold", size: 22))
                        .foregroundColor(globalSettings.primaryDarkColor)
                    Spacer()
                    // Empty view for alignment
                    Image(systemName: "xmark")
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Text("Update your password below.")
                    .font(.custom("Poppins-Regular", size: 15))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                
                VStack(spacing: 18) {
                    BravoSecureField(placeholder: "Current Password", text: $currentPassword)
                    BravoSecureField(placeholder: "New Password", text: $newPassword)
                    BravoSecureField(placeholder: "Confirm New Password", text: $confirmPassword)
                }

                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                
                // Error message
                if showAlert {
                    Text(alertMessage)
                        .foregroundColor(isAlertError ? .red : Color(hex: "60AE17"))
                        .font(.custom("Poppins-Regular", size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                }
                
                Spacer()
       
                PrimaryButton(
                    title: "Update Password",
                    action: { savePassword() },
                    frontColor: globalSettings.primaryYellowColor,
                    backColor: globalSettings.primaryDarkYellowColor,
                    textColor: Color.white,
                    textSize: 16,
                    width: .infinity,
                    height: 50,
                    disabled: false
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
                
            }
        }
    }
    
    private func savePassword() {
        // Current password required
        guard !currentPassword.isEmpty else {
            alertMessage = "Current password is required."
            isAlertError = true
            showAlert = true
            return
        }
        
        // Validate new password
        if let passError = AccountValidation.passwordError(newPassword) {
            alertMessage = passError
            isAlertError = true
            showAlert = true
            return
        }
        
        // Check password confirmation
        guard newPassword == confirmPassword else {
            alertMessage = "New passwords do not match."
            isAlertError = true
            showAlert = true
            return
        }
        
        // Check that new password is different from current password
        guard newPassword != currentPassword else {
            alertMessage = "New password must be different from current password."
            isAlertError = true
            showAlert = true
            return
        }
        
        Task {
            do {
                try await settingsModel.updateUserPassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword
                )
                alertMessage = "Password updated successfully"
                isAlertError = false
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            } catch {
                alertMessage = "Failed to update password: \(error.localizedDescription)"
                isAlertError = true
                showAlert = true
            }
        }
    }
}

#if DEBUG
struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        let mockSettings = SettingsModel()
        let mockGlobal = GlobalSettings()
        return ChangePasswordView(globalSettings: mockGlobal, settingsModel: mockSettings)
    }
}
#endif 
