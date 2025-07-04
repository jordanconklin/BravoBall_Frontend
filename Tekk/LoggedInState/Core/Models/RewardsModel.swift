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
}
