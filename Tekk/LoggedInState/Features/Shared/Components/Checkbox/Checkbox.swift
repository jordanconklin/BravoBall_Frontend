//
//  Checkbox.swift
//  BravoBall
//
//  Created by Joshua Conklin on 5/9/25.
//

import SwiftUI


struct Checkbox: View {
    @ObservedObject var appModel: MainAppModel
    let globalSettings = GlobalSettings.shared
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? globalSettings.primaryYellowColor : Color.clear)
                .stroke(isSelected ? globalSettings.primaryYellowColor : globalSettings.primaryGrayColor, lineWidth: 1)
                .frame(width: 20, height: 20)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
            }
        }
    }
}
