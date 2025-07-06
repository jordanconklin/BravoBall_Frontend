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
    let globalSettings = GlobalSettings.shared

    
    var body: some View {
        VStack {
            
            // Search skills button
            CircleButton(
                action: {
                    Haptic.light()
                    withAnimation {
                        appModel.viewState.showFilterOptions.toggle()
                    }
                },
                frontColor: globalSettings.primaryYellowColor,
                backColor: globalSettings.primaryDarkYellowColor,
                width: 40,
                height: 40,
                borderColor: .clear,
                disabled: false,
                pressedOffset: 4
                
            ) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
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
        .background(globalSettings.primaryLightBlueColor)
    }
    

}
