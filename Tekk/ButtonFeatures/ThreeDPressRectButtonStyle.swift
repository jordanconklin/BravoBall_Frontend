
//
//  ThreeDPressRectButtonStyle.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/24/25.
//

import SwiftUI

struct ThreeDPressRectButtonStyle: ButtonStyle {
    var frontColor: Color
    var backColor: Color
    var cornerRadius: CGFloat
    var size: CGSize
    var pressedOffset: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Back rectangle (does NOT move)
            Rectangle()
                .foregroundColor(backColor)
                .cornerRadius(cornerRadius)
                .offset(y: pressedOffset)

            // Front rectangle + label (move together)
            ZStack {
                Rectangle()
                    .foregroundColor(frontColor)
                    .cornerRadius(cornerRadius)
                configuration.label
            }
            .offset(y: configuration.isPressed ? pressedOffset : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
        }
        .frame(width: size.width, height: size.height)
    }
}
