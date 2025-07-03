//
//  FloatingAddButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/1/25.
//

import SwiftUI
import RiveRuntime

struct FloatingAddButton: View {
    @ObservedObject var appModel: MainAppModel
    let globalSettings = GlobalSettings.shared
    var action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
        Spacer()
                // Search skills button
                CircleButton(
                    action: {
                        Haptic.light()
                        action()
                    },
                    frontColor: globalSettings.primaryYellowColor,
                    backColor: globalSettings.primaryDarkYellowColor,
                    width: 60,
                    height: 60,
                    disabled: false,
                    pressedOffset: 6
                    
                ) {
                    Image(systemName: "plus")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
