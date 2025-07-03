//
//  OnboardingRegisterForm.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/8/25.
//

import SwiftUI

struct OnboardingRegisterForm: View {
    @ObservedObject var onboardingModel: OnboardingModel
    
    @Binding var email: String
    @Binding var password: String
    
    @State private var hasAttemptedSubmit = false
    
    var body: some View {
            // Register Form
            VStack(spacing: 20) {
                // Email Field
                BravoTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                
                // Password Field
                BravoSecureField(placeholder: "Password", text: $password)
                
                // Confirm Password Field
                BravoSecureField(placeholder: "Confirm Password", text: $onboardingModel.onboardingData.confirmPassword)
                
                Spacer()
                
                // Show validation error if present and user has attempted to submit
                if hasAttemptedSubmit, let error = onboardingModel.registrationValidationError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.custom("Poppins-Regular", size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal)
            .onChange(of: onboardingModel.errorMessage) { index, newValue in
                if !newValue.isEmpty {
                    hasAttemptedSubmit = true
                }
            }
    }
}

