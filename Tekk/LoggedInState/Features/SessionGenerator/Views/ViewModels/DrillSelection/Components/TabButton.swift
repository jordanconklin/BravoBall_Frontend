//
//  TabButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//
import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            Text(title)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.yellow : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.yellow : Color.gray, lineWidth: 1)
                )
        }
    }
}
