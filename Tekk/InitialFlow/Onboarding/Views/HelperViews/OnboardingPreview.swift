//
//  OnboardingPreview.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI

struct OnboardingPreview: View {
    @ObservedObject var appModel: MainAppModel
    let globalSettings = GlobalSettings.shared
    
    @State private var displayedText1 = ""
    @State private var displayedText2a = ""
    @State private var displayedText2b = ""
    @State private var isTyping = false
    @State private var isActive = true
    
    let fullText1 = "Hello! I'm Bravo!"
    let fullText2a = "I'll help you improve as a soccer player and achieve your goals."
    let fullText2b = "Let me ask you a few quick questions to create your personalized training plan."
    
    var body: some View {
        VStack(spacing: 35) {
            Text(displayedText1)
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(globalSettings.primaryDarkColor)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 25) {
                Text(displayedText2a)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(globalSettings.primaryDarkColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text(displayedText2b)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(globalSettings.primaryDarkColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 25)
        .padding(.horizontal, 40)
        .onAppear {
            isActive = true
            startTypewriterEffect()
        }
        .onDisappear {
            isActive = false
        }
    }
    
    private func startTypewriterEffect() {
        isTyping = true
        // Type first text
        for (index, character) in fullText1.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                if isActive {
                    displayedText1 += String(character)
                    Haptic.light()
                }
            }
        }
        // Start typing first paragraph after first is done
        let delay1 = Double(fullText1.count) * 0.05 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delay1) {
            for (index, character) in fullText2a.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                    if isActive {
                        displayedText2a += String(character)
                        Haptic.light()
                    }
                }
            }
        }
        // Start typing second paragraph after first paragraph is done
        let delay2 = delay1 + Double(fullText2a.count) * 0.03 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delay2) {
            for (index, character) in fullText2b.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                    if isActive {
                        displayedText2b += String(character)
                        Haptic.light()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct OnboardingPreview_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPreview(appModel: MainAppModel())
    }
}
#endif
