//
//  SkillRow.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct SkillRow: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let skill: DrillResponse.Skill
    let isSelected: Bool
    
    var body: some View {
        let _ = print("DEBUG: SkillRow category: '\(skill.category)' -> Icon: '\(sessionModel.skillIconName(for: skill.category))'")
        Button( action: {
            Haptic.light()
            if isSelected {
                sessionModel.selectedSkills.remove(skill.subSkill)
            } else {
                sessionModel.selectedSkills.insert(skill.subSkill)
            }
        }) {
            HStack {
                Image(sessionModel.skillIconName(for: skill.category))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading) {
                    Text(skill.subSkill)
                        .font(.custom("Poppins-Bold", size: 14))
                        .foregroundColor(.black)
                    Text(skill.category)
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                Spacer()
                
                Checkbox(appModel: appModel, isSelected: isSelected)
            }
        }
    }
    
}
