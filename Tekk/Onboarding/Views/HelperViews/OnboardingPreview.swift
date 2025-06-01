//
//  OnboardingPreview.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI

struct OnboardingPreview: View {
    @ObservedObject var appModel: MainAppModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Hello! Im Bravo!")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(appModel.globalSettings.primaryDarkColor)
            Text("I will help you on your journey to improve as a soccer player so that you can achieve your goals. First I will ask you a few questions to get to know more about you and create a personalized training session for you!")
                .font(.custom("Poppins-Bold", size: 14))
                .foregroundColor(appModel.globalSettings.primaryDarkColor)
            Spacer()
        }
        .padding(.top, 10)
        .padding(.horizontal)
    }
}
