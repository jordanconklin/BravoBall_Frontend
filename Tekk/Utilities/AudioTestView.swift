//
//  AudioTestView.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//

import SwiftUI

struct AudioTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Test")
                .font(.title)
                .padding()
            
            Button("Test 321 Start Sound") {
                AudioManager.shared.play321Start()
            }
            .buttonStyle(.bordered)
            
            Button("Test 321 Done Sound") {
                AudioManager.shared.play321Done()
            }
            .buttonStyle(.bordered)
            
            Button("Test Success Sound") {
                AudioManager.shared.playSuccess()
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    AudioTestView()
} 
