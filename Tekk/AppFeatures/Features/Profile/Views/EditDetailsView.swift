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
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAlertError = true
    
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
                    Text("Edit Email")
                        .font(.custom("Poppins-Bold", size: 22))
                        .foregroundColor(globalSettings.primaryDarkColor)
                    Spacer()
                    // Empty view for alignment
                    Image(systemName: "xmark")
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Text("Update your email address below.")
                    .font(.custom("Poppins-Regular", size: 15))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                
                VStack(spacing: 18) {
                    BravoTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
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
                
                
                PrimaryButton(
                    title: "Update Email",
                    action: { saveEmail() },
                    frontColor: globalSettings.primaryYellowColor,
                    backColor: globalSettings.primaryDarkYellowColor,
                    textColor: Color.white,
                    textSize: 16,
                    width: .infinity,
                    height: 40,
                    disabled: false
                        
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
                
                Spacer()
            }
        }
        .onAppear {
            email = settingsModel.email
        }
    }
    
    private func saveEmail() {
        // Email validation before attempting to save
        guard AccountValidation.isValidEmail(email) else {
            alertMessage = "Please enter a valid email address."
            isAlertError = true
            showAlert = true
            return
        }
        
        Task {
            do {
                try await settingsModel.updateUserEmail(email: email)
                alertMessage = "Email updated successfully"
                isAlertError = false
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            } catch {
                alertMessage = "Failed to update email: \(error.localizedDescription)"
                isAlertError = true
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
