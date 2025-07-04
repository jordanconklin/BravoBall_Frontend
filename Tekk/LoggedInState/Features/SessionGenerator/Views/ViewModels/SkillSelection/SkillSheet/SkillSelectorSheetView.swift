//
//  SkillSelectorSheetView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/24/25.
//

import SwiftUI


struct SkillSelectorSheet: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let globalSettings = GlobalSettings.shared
    
    @Environment(\.viewGeometry) var geometry
    @Environment(\.dismiss) private var dismiss
    @State private var expandedCategory: String?
    

    
    var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Text("Select Skills")
                        .foregroundColor(globalSettings.primaryDarkColor)
                        .font(.custom("Poppins-Bold", size: 16))
                        .padding(.leading, 70)
                    Spacer()
                    Button(action: {
                        Haptic.light()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                    
                    .padding()
                    .foregroundColor(globalSettings.primaryDarkColor)
                    .font(.custom("Poppins-Bold", size: 16))
                }
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 40) {
                        ForEach(SessionGeneratorView.skillCategories, id: \.name) { category in
                            VStack(alignment: .leading, spacing: 0) {
                                Button(action: {
                                    Haptic.light()
                                    withAnimation {
                                        if expandedCategory == category.name {
                                            expandedCategory = nil
                                        } else {
                                            expandedCategory = category.name
                                        }
                                    }
                                }) {
                                    VStack {
                                        Text(category.name)
                                            .font(.custom("Poppins-Bold", size: 18))
                                            .foregroundColor(globalSettings.primaryDarkColor)
                                        HStack {
                                            Spacer()
                                            
                                            Image(category.icon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 70, height: 70)
                                            
                                            Spacer()

                                        }
                                        .padding()
                                        
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .stroke(isCategorySelected(category) ? globalSettings.primaryYellowColor : Color.gray.opacity(0.3), lineWidth: 4)
                                    )
                                }
                                .foregroundColor(globalSettings.primaryDarkColor)
                                
                                if expandedCategory == category.name {
                                    VStack(spacing: 12) {
                                        ForEach(category.subSkills, id: \.self) { subSkill in
                                            Button(action: {
                                                Haptic.light()
                                                if sessionModel.selectedSkills.contains(subSkill) {
                                                    sessionModel.selectedSkills.remove(subSkill)
                                                } else {
                                                    sessionModel.selectedSkills.insert(subSkill)
                                                }
                                            }) {
                                                HStack {
                                                    Text(subSkill)
                                                        .font(.custom("Poppins-Medium", size: 16))
                                                    
                                                    Spacer()
                                                    
                                                    if sessionModel.selectedSkills.contains(subSkill) {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(globalSettings.primaryYellowColor)
                                                    }
                                                }
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                            }
                                            .foregroundColor(globalSettings.primaryDarkColor)
                                        }
                                    }
                                    .padding(.vertical)
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            Spacer()
                
            PrimaryButton(
                title: "Create Session",
                action: {
                    Haptic.light()
                    dismiss()
                    Task {
                        await sessionModel.schedulePreferenceUpdate()
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
        }
        .frame(width: geometry.size.width)

    }
    // TODO: move this somewhere else?
    // Highlight category if sub skill selected
    func isCategorySelected(_ category: SkillCategory) -> Bool {
        for skill in category.subSkills {
            if sessionModel.selectedSkills.contains(skill) {
                return true
            }
        }
        return false
    }
}


