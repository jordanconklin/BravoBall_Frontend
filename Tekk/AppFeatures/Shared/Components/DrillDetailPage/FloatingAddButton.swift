//
//  FloatingAddButton.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/1/25.
//

import SwiftUI
import RiveRuntime

struct FloatingAddButton: View {
    var action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
        Spacer()
                Button(action: action) {
                    RiveViewModel(fileName: "Plus_Button").view()
                        .frame(width: 60, height: 60)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
