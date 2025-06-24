//
//  ThreeDPressCircleButtonStyle.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/24/25.
//
import SwiftUI

struct ThreeDPressCircleButtonStyle: ButtonStyle {
    var frontColor: Color
    var backColor: Color
    var width: CGFloat
    var height: CGFloat
    var size: CGSize
    var pressedOffset: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            
            // background
            Circle()
                .fill(backColor)
                .frame(width: width, height: height)
                .offset(y: pressedOffset)
            
            // front
            ZStack {
                Circle()
                    .fill(frontColor)
                    .frame(width: width, height: height)
                configuration.label
            }
            .offset(y: configuration.isPressed ? pressedOffset : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            
        }
        .opacity(1.0) // will stop the disabled feature from changing its opacity
    }
}
