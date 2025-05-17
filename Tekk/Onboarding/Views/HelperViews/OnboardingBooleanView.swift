//
//  OnboardingBooleanView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI

// For onboarding pages with 'Yes or No' options
struct OnboardingBooleanView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    let title: String
    @Binding var selection: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
            
            HStack(spacing: 15) {
                Button(action: {
                    selection = true
                }) {
                    HStack {
                        Text("Yes")
                            .font(.custom("Poppins-Bold", size: 16))
                        if selection {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(selection ? onboardingModel.globalSettings.primaryYellowColor : .white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(selection ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .foregroundColor(selection ? .white : onboardingModel.globalSettings.primaryDarkColor)
                
                Button(action: {
                    selection = false
                }) {
                    HStack {
                        Text("No")
                            .font(.custom("Poppins-Bold", size: 16))
                        if !selection {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(!selection ? onboardingModel.globalSettings.primaryYellowColor : .white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(!selection ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .foregroundColor(!selection ? .white : onboardingModel.globalSettings.primaryDarkColor)
            }
        }
        .padding(.horizontal)
    }
}
