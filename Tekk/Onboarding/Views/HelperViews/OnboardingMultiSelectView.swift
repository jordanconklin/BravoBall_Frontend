//
//  OnboardingMultiSelectView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI

// For onboarding pages with multi-select options
struct OnboardingMultiSelectView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    let options: [String]
    @Binding var selections: [String]
    
    var body: some View {
        ScrollView {
            VStack {
                
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        if selections.contains(option) {
                            selections.removeAll { $0 == option }
                        } else {
                            selections.append(option)
                        }
                    }) {
                        HStack {
                            Text(option)
                                .font(.custom("Poppins-Bold", size: 16))
                            Spacer()
                            if selections.contains(option) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(selections.contains(option) ? onboardingModel.globalSettings.primaryYellowColor : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(selections.contains(option) ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .foregroundColor(selections.contains(option) ? .white : onboardingModel.globalSettings.primaryDarkColor)
                }
            }
            .padding(.horizontal)

        }
    }
}
