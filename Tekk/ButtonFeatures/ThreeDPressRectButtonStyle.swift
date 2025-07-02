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
    var borderColor: Color?

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
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor ?? Color.clear, lineWidth: 2)
                    )
                configuration.label
            }
            .offset(y: configuration.isPressed ? pressedOffset : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Default button
        Button("Press Me") {
            print("Button pressed!")
        }
        .buttonStyle(ThreeDPressRectButtonStyle(
            frontColor: .blue,
            backColor: .blue.opacity(0.6),
            cornerRadius: 12,
            size: CGSize(width: 200, height: 50),
            pressedOffset: 4,
            borderColor: .blue.opacity(0.8)
        ))
        
        // Yellow button (matching app theme)
        Button("Send Code") {
            print("Send code pressed!")
        }
        .buttonStyle(ThreeDPressRectButtonStyle(
            frontColor: .white,
            backColor: .gray,
            cornerRadius: 10,
            size: CGSize(width: 200, height: 50),
            pressedOffset: 3,
            borderColor: .gray
        ))
        
        // Button without border
        Button("No Border") {
            print("No border button pressed!")
        }
        .buttonStyle(ThreeDPressRectButtonStyle(
            frontColor: .green,
            backColor: .green.opacity(0.6),
            cornerRadius: 10,
            size: CGSize(width: 200, height: 50),
            pressedOffset: 3
        ))
    }
    .padding()
    .background(Color(.systemBackground))
}
