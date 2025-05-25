//
//  CustomVideoPlayer.swift
//  BravoBall
//
//  Created by Jordan on 5/25/25.
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
                player?.pause()
                player = nil
            }
    }
    
    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Add observer for video end
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        // Start playing
        player?.play()
    }
}
