//
//  OnboardingStepView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI

// Onboarding Step Helper View
struct OnboardingStepView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    let title: String
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(onboardingModel.globalSettings.primaryDarkColor)
            
            ForEach(options, id: \.self) { option in
                Button(action: {
                        if selection == option {
                            selection = ""
                        } else {
                            selection = option
                        }
                    }) {
                    HStack {
                        Text(option)
                            .font(.custom("Poppins-Bold", size: 16))
                        Spacer()
                        if selection == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(selection == option ? onboardingModel.globalSettings.primaryYellowColor : .white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(selection == option ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .foregroundColor(selection == option ? .white : onboardingModel.globalSettings.primaryDarkColor)
            }
        }
        .padding(.horizontal)
//            // Ternary operator for if back button is pressed or not, questions move right or left
//            .transition(.asymmetric(
//                insertion: .move(edge: onboardingModel.backTransition ? .leading : .trailing),
//                removal: .move(edge: onboardingModel.backTransition ? .trailing : .leading)
//            ))
    }
}
