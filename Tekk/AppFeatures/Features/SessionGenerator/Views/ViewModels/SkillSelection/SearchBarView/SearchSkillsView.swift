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
        }
        .frame(width: geometry.size.width)
        .safeAreaInset(edge: .bottom) {
                        
            Button(action: {
                Haptic.light()
                searchText = ""
                appModel.viewState.showSkillSearch = false
                
                sessionModel.schedulePreferenceUpdate()
                
            }) {
                
                    Text("Create Session")
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(sessionModel.selectedSkills.isEmpty ? appModel.globalSettings.primaryLightGrayColor : appModel.globalSettings.primaryYellowColor)
                    .cornerRadius(12)
            }
            .disabled(sessionModel.selectedSkills.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeOut(duration: 0.16), value: isFocused)
        
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
