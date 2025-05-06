//
//  GoldenButton.swift
//  BravoBall
//
//  Created by Jordan on 4/18/25.
//

import SwiftUI
import RiveRuntime

// MARK: - Golden Button Component
struct GoldenButton: View {
    @ObservedObject var appModel: MainAppModel
    let viewGeometry: ViewGeometry
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(dampingFraction: 0.7)) {
                appModel.viewState.showHomePage = false
                appModel.viewState.showPreSessionTextBubble = false
            }
            
            // Delay the appearance of field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.spring(dampingFraction: 0.7)) {
                    appModel.viewState.showFieldBehindHomePage = true
                }
            }
        }) {
            ZStack {
                RiveViewModel(fileName: "Golden_Button").view()
                    .frame(width: 320, height: 80)
                
                Text("Start Session")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 90)
        .transition(.move(edge: .bottom))
    }
} 
