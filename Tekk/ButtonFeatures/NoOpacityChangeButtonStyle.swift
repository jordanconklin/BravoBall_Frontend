//
//  NoOpacityChangeButtonStyle.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/24/25.
//
import SwiftUI

// Custom button style to prevent opacity change when disabled
struct NoOpacityChangeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
