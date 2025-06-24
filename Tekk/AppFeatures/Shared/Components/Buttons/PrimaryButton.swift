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
    var frontColor: Color = Color.accentColor
    var backColor: Color = Color.accentColor
    var textColor: Color = .white
    var textSize: CGFloat = 18
    var width: CGFloat
    var height: CGFloat = 60
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
                pressedOffset: 6
            )
        )
        .disabled(disabled)
    }
}


