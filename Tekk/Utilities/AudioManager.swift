//
//  AudioManager.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private init() {}
    
    private var audioPlayer: AVAudioPlayer?
    
    func play321Start() {
        playSound(named: "321-start")
    }
    
    func play321Done() {
        playSound(named: "321-done")
    }
    
    func playSuccess() {
        playSound(named: "success")
    }
    
    private func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "MP3") else {
            print("Audio file \(name) not found in AudioAssets folder.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing sound \(name): \(error.localizedDescription)")
        }
    }
} 
