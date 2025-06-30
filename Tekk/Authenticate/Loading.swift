//
//  AuthenticationLoadingView.swift
//  BravoBall
//
//  Created by Assistant on 1/15/25.
//

import SwiftUI
import RiveRuntime

struct AuthenticationLoadingView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                    .frame(width: 150, height: 150)
                
                Text("Welcome back!")
                    .font(.custom("PottaOne-Regular", size: 24))
                    .foregroundColor(.black)
                
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(.top, 10)
                
                Text("Checking your session...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    AuthenticationLoadingView()
}
