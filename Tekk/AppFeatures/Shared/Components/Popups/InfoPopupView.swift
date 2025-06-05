//
//  InfoPopupView.swift
//  BravoBall
//
//  Created by Jordan on 6/4/25.
//

import SwiftUI
import RiveRuntime

struct InfoPopupView: View {
    let title: String
    let description: String
    let onClose: (() -> Void)?
    var riveFileName: String = "Bravo_Animation"
    var riveStateMachine: String = "State Machine 1"
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack(alignment: .center, spacing: 16) {
                            RiveViewModel(fileName: riveFileName, stateMachineName: riveStateMachine).view()
                                .frame(width: 80, height: 80)
                                .padding(.top, 8)
                            Text(title)
                                .font(.custom("Poppins-Bold", size: 22))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: 340, alignment: .leading)
                        .padding(.bottom, 20)
                        
                        Text(description)
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                    }
                }
                // Fade-out gradient at the bottom
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)
                .allowsHitTesting(false)
            }
            Button(action: { 
                Haptic.light()
                onClose?() 
            }) {
                Text("Got it!")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(GlobalSettings().primaryYellowColor)
                    .cornerRadius(20)
            }
            .padding(.bottom, 16)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct InfoPopupView_Previews: PreviewProvider {
    static var previews: some View {
        InfoPopupView(
            title: "What is this page?",
            description: "This is text for testing the info popup\n\nThis is text for testing the info popup",
            onClose: {}
        )
    }
}
#endif 
