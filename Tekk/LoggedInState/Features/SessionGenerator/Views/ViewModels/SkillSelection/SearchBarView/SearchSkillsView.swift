//
//  SearchSkillsView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct SearchSkillsView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.viewGeometry) var geometry
    let globalSettings = GlobalSettings.shared
    
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: true) {
                ForEach(filteredSkills, id: \.self) { skill in
                    VStack(alignment: .leading) {
                        SkillRow(
                            appModel: appModel,
                            sessionModel: sessionModel,
                            skill: skill,
                            isSelected: sessionModel.selectedSkills.contains(skill.subSkill)
                        )
                        .padding()
                        Divider()
                    }
                }
            }
            Spacer()
            
            PrimaryButton(
                title: "Create Session",
                action: {
                    Haptic.light()
                    searchText = ""
                    appModel.viewState.showSkillSearch = false
                    
                    Task {
                        if !appModel.viewState.showSkillSearch {
                            await sessionModel.syncUpdatePreferencesTask()
                        }
                    }
                },
                frontColor: globalSettings.primaryYellowColor,
                backColor: globalSettings.primaryDarkYellowColor,
                textColor: Color.white,
                textSize: 18,
                width: .infinity,
                height: 50,
                disabled: sessionModel.selectedSkills.isEmpty
            )
            .padding()
            .animation(.easeOut(duration: 0.16), value: isFocused)
        }
        .frame(width: geometry.size.width)
        
    }
    

    private var filteredSkills: [DrillResponse.Skill] {
        if searchText.isEmpty {
            return []
        }
        
        var matchingSkills: [DrillResponse.Skill] = []
        
        for category in SessionGeneratorView.skillCategories {
            // Find all subskills in this category that match the search text
            let matchingSubSkills = category.subSkills.filter { subSkill in
                subSkill.lowercased().contains(searchText.lowercased())
            }
            
            // Create a Skill object for each matching subskill
            for subSkill in matchingSubSkills {
                matchingSkills.append(DrillResponse.Skill(category: category.name, subSkill: subSkill))
            }
        }
        
        return matchingSkills
    }
}
