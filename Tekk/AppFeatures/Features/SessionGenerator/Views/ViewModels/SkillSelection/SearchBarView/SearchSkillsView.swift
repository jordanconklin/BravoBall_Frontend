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
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(filteredSkills, id: \.self) { skill in
                    VStack(alignment: .leading) {
                        SkillRow(
                            appModel: appModel,
                            sessionModel: sessionModel,
                            skill: skill
                        )
                        Divider()
                    }
                }
            }
            Spacer()
        }
        .frame(width: geometry.size.width)
        .safeAreaInset(edge: .bottom) {
                        
            Button(action: {
                searchText = ""
                appModel.viewState.showSkillSearch = false
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
            .padding(.bottom, 80)
        }
    }
    
    // Flatten all skills for searching
    private var allSkills: [String] {
        SessionGeneratorView.skillCategories.flatMap { category in
            category.subSkills.map { subSkill in
                (subSkill)
            }
        }
        
    }

    private var filteredSkills: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return allSkills.filter { skill in
                skill.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
