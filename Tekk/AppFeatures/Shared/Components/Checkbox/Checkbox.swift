//
//  Checkbox.swift
//  BravoBall
//
//  Created by Joshua Conklin on 5/9/25.
//

import SwiftUI


struct Checkbox: View {
    @ObservedObject var appModel: MainAppModel
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? appModel.globalSettings.primaryYellowColor : Color.clear)
                .stroke(isSelected ? appModel.globalSettings.primaryYellowColor : appModel.globalSettings.primaryGrayColor, lineWidth: 1)
                .frame(width: 20, height: 20)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
            }
        }
    }
}
