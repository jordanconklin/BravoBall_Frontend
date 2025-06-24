//
//  PressableButtonstyle.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/23/25.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.92
    var animation: Animation = .spring(response: 0.2, dampingFraction: 0.6)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(animation, value: configuration.isPressed)
    }
}
