//
//  CircleButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/24/25.
//

import SwiftUI

struct CircleButton<Content: View>: View {

    
    var action: () -> Void
    var frontColor: Color = Color.accentColor
    var backColor: Color = Color.accentColor
    var width: CGFloat
    var height: CGFloat = 60
    var borderColor: Color?
    var disabled: Bool = false
    var pressedOffset: CGFloat
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Button(action: action) {
            content()
        }
        .buttonStyle(
            ThreeDPressCircleButtonStyle(
                frontColor: frontColor,
                backColor: backColor,
                width: width,
                height: height,
                size: CGSize(width: width, height: height),
                pressedOffset: pressedOffset,
                borderColor: borderColor
            )
        )
        .disabled(disabled)
    }
}
