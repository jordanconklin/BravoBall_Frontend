//
//  SkillButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct SkillButton: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
            HStack(spacing: 4) {
                Text(title)
                    .font(.custom("Poppins-Bold", size: 12))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Button(action: {
                    action()
                    
                    if !appModel.viewState.showSkillSearch {
                        sessionModel.schedulePreferenceUpdate()
                    }
                    
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor.opacity(0.5))
                        .font(.system(size: 14))
                }
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 8)  // Increased horizontal padding for X button
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .stroke(appModel.globalSettings.primaryLightGrayColor, lineWidth: 2)
            )
            .padding(.vertical, 2)
            .padding(.horizontal, 2)
        }
}
