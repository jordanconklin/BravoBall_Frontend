//
//  FilterOptionsButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct FilterOptionsButton: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel

    
    var body: some View {
        VStack {
            Button(action: {
                Haptic.light()
                withAnimation {
                    appModel.viewState.showFilterOptions.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(appModel.globalSettings.primaryLightGrayColor)
                        .frame(width: 40, height: 40)
                        .offset(x: 0, y: 3)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 3)
        }
        .onTapGesture {
            withAnimation {
                if appModel.viewState.showFilterOptions {
                    appModel.viewState.showFilterOptions = false
                }
            }
        }
        .background(Color.white)
    }
    

}
