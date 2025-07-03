//
//  CustomTabItem.swift
//  BravoBall
//
//  Created by Joshua Conklin on 3/10/25.
//
import SwiftUI

struct CustomTabItem: View {
    let icon: AnyView
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Haptic.medium()
            action()
        }) {
            VStack(spacing: 4) {
                icon
                    .frame(width: 30, height: 30)
                    .scaleEffect(isSelected ? 1.5 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(ShrinkingButtonStyle())
    }
}

