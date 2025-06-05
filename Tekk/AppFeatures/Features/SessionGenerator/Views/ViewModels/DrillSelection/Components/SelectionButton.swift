//
//  SelectionButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//
import SwiftUI

struct SelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            Text(title)
                .font(.custom("Poppins-Medium", size: 18))
                .foregroundColor(.gray)
                .padding(.horizontal)
                .frame(width: 200)
                .padding(.vertical, 12)
                .background(Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
}
