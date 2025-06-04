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
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        ScrollView {
            VStack {
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

        }
    }
}
