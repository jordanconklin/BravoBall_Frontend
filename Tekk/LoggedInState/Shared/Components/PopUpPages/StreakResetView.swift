//
//  StreakResetView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//

import SwiftUI

struct StreakResetView: View {
    let globalSettings = GlobalSettings.shared
    
    var onDismiss: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Streak Lost")
                .font(.largeTitle)
                .bold()
                .foregroundColor(globalSettings.primaryDarkColor)
            Text("You missed a day and lost your streak. Don't worry, you can start a new one today!")
                .multilineTextAlignment(.center)
                .font(.title3)
                .foregroundColor(globalSettings.primaryDarkColor)
                .padding(.horizontal)
            PrimaryButton(
                title: "Got it",
                action: {
                    Haptic.light()
                    onDismiss()
                },
                frontColor: Color.orange,
                backColor: Color(hex:"ad791a"),
                textColor: Color.white,
                textSize: 18,
                width: .infinity,
                height: 50,
                disabled: false
            )

        }
        .padding()
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(radius: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.move(edge: .top))
    }
}

