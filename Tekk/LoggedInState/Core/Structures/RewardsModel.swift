//
//  RewardsModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/3/25.
//
import SwiftUI

class RewardsModel: ObservableObject {
    @Published var treats: Int = 3 // Start with 3 for testing

    func useTreat() -> Bool {
        guard treats > 0 else { return false }
        treats -= 1
        return true
    }
    
//    func calculateSessionXP(session: Session) -> Int {
//        let baseXP = 50
//        let completionBonus = session.completionRate * 100 // 0-100 XP
//        let difficultyMultiplier = session.averageDifficulty * 1.5
//        let skillVarietyBonus = min(session.uniqueSkills.count * 10, 50) // Max 50 XP
//        
//        return Int((baseXP + completionBonus) * difficultyMultiplier + skillVarietyBonus)
//    }
}
