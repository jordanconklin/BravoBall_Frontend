//
//  CustomVideoPlayer.swift
//  BravoBall
//
//  Created by Jordan on 6/4/25.
//

import SwiftUI
import AVKit

struct CustomVideoPlayer: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(16/9, contentMode: .fit)
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
    }
    
    private func setupPlayer() {
        let avPlayer = AVPlayer(url: videoURL)
        player = avPlayer
        
        // Add observer for video end
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem,
            queue: .main
        ) { _ in
            // Seek to beginning and play again
            avPlayer.seek(to: .zero)
            avPlayer.play()
        }
        
        // Start playing immediately
        avPlayer.play()
    }
    
    private func cleanupPlayer() {
        player?.pause()
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        player = nil
    }
} 
