//
//  EditDetailsView.swift
//  BravoBall
//
//  Created by Jordan on 3/28/25.
//

import SwiftUI

struct EditDetailsView: View {
    @ObservedObject var globalSettings: GlobalSettings
    @ObservedObject var settingsModel: SettingsModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isPasswordVisible = false
    @State private var isCurrentPasswordVisible = false
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                // Mascot/Icon
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .foregroundColor(globalSettings.primaryYellowColor)
                    .padding(.top, 30)
                
                Text("Edit Account Details")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundColor(globalSettings.primaryDarkColor)
                    .padding(.top, 8)
                
                Text("Update your account information below.")
                    .font(.custom("Poppins-Regular", size: 15))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                VStack(spacing: 18) {
                    BravoTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                    BravoSecureField(placeholder: "Current Password", text: $currentPassword)
                    BravoSecureField(placeholder: "New Password", text: $newPassword)
                    BravoSecureField(placeholder: "Confirm New Password", text: $confirmPassword)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white).shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4))
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                
                // Error message
                if showAlert {
                    Text(alertMessage)
                        .foregroundColor(.red)
                        .font(.custom("Poppins-Regular", size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                }
                
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.13)))
                    }
                    Button(action: { saveChanges() }) {
                        Text("Save")
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(globalSettings.primaryYellowColor))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
                Spacer()
            }
        }
        .onAppear {
            email = settingsModel.email
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        }
    }
    
    private func saveChanges() {
        // Email validation before attempting to save
        guard AccountValidation.isValidEmail(email) else {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }
        // Current password required
        guard !currentPassword.isEmpty else {
            alertMessage = "Current password is required."
            showAlert = true
            return
        }
        // If new password is entered, validate it and check confirmation
        if !newPassword.isEmpty || !confirmPassword.isEmpty {
            if let passError = AccountValidation.passwordError(newPassword) {
                alertMessage = passError
                showAlert = true
                return
            }
            guard newPassword == confirmPassword else {
                alertMessage = "New passwords do not match."
                showAlert = true
                return
            }
        }
        Task {
            do {
                // You may need to update your backend to accept currentPassword and newPassword
                try await settingsModel.updateUserDetails(email: email) // Add password params if backend supports
                alertMessage = "Details updated successfully"
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
                }
            } catch {
                alertMessage = "Failed to update details: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

#if DEBUG
struct EditDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockSettings = SettingsModel()
        let mockGlobal = GlobalSettings()
        mockSettings.email = "jordan@example.com"
        return EditDetailsView(globalSettings: mockGlobal, settingsModel: mockSettings)
    }
}
#endif
