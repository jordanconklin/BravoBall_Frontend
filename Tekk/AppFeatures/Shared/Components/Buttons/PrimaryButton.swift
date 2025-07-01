//
//  PrimaryButton.swift
//  BravoBall
//
//  Created by Jordan on 6/5/25.
//

import SwiftUI

struct PrimaryButton<Content: View>: View {
    enum Style {
        case filled
        case outlined
    }
    
    var title: String
    var action: () -> Void
    var frontColor: Color
    var backColor: Color
    var textColor: Color
    var textSize: CGFloat
    var width: CGFloat
    var height: CGFloat
    var borderColor: Color
    var disabled: Bool = false
    var content: Content
    
    // Default initializer with empty content
        init(
            title: String,
            action: @escaping () -> Void,
            frontColor: Color = Color.accentColor,
            backColor: Color = Color.accentColor,
            textColor: Color = .white,
            textSize: CGFloat = 18,
            width: CGFloat,
            height: CGFloat = 60,
            borderColor: Color = Color.clear,
            disabled: Bool = false,
            @ViewBuilder content: @escaping () -> Content = { EmptyView() }
        ) {
            self.title = title
            self.action = action
            self.frontColor = frontColor
            self.backColor = backColor
            self.textColor = textColor
            self.textSize = textSize
            self.width = width
            self.height = height
            self.borderColor = borderColor
            self.disabled = disabled
            self.content = content()
        }
    
    var body: some View {
        Button(action: action) {
            HStack {
                content
                
                Text(title)
                    .font(.custom("Poppins-Bold", size: textSize))
                    .foregroundColor(textColor)
            }
            .padding(.horizontal)

        }
        .buttonStyle(
            ThreeDPressRectButtonStyle(
                frontColor: disabled ? Color(hex:"d6d6d6") : frontColor,
                backColor: disabled ? Color(hex:"b8b8b8") : backColor,
                cornerRadius: 12,
                size: CGSize(width: width, height: height),
                pressedOffset: 6,
                borderColor: borderColor
            )
        )
        .disabled(disabled)
    }
}


