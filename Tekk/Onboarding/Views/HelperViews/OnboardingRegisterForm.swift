//
//  OnboardingRegisterForm.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/8/25.
//

import SwiftUI

struct OnboardingRegisterForm: View {
    @ObservedObject var onboardingModel: OnboardingModel
    
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var password: String
    
    
    var body: some View {
            
            // Register Form
            VStack(spacing: 20) {
                // First Name Field
                TextField("First Name", text: $firstName)
                    .padding()
                    .disableAutocorrection(true)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                    .keyboardType(.default)
                
                // Last Name Field
                TextField("Last Name", text: $lastName)
                    .padding()
                    .disableAutocorrection(true)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(onboardingModel.globalSettings.primaryYellowColor.opacity(0.3), lineWidth: 1))
                    .keyboardType(.default)
                
                Spacer()
                    .frame(height: 10)
                
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
                
                Spacer()
            }
            .padding(.horizontal)
    }
}

