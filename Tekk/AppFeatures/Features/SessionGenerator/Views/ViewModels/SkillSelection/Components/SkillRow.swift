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
        Button( action: {
            if isSelected {
                sessionModel.selectedSkills.remove(skill.subSkill)
            } else {
                sessionModel.selectedSkills.insert(skill.subSkill)
            }
        }) {
            HStack {
                Image(systemName: "figure.soccer")
                    .font(.system(size: 24))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
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
