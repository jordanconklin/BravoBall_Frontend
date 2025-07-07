//
//  CircularScore.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct CircularScore: View {
    @ObservedObject var appModel: MainAppModel
    let globalSettings = GlobalSettings.shared
    
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: appModel.viewState.showHomePage ? 20 : 10)
                .opacity(0.2)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(animatedProgress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: appModel.viewState.showHomePage ? 20 : 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(globalSettings.primaryYellowColor)
                .rotationEffect(Angle(degrees: 270.0))
        }
        // When progress first appears
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        // When progress changes
        .onChange(of: progress) {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
    }
}
