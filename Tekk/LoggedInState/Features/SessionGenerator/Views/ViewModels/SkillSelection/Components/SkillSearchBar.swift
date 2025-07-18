//
//  SkillSearchBar.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/24/25.
//

import SwiftUI
import RiveRuntime

struct SkillSearchBar: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.viewGeometry) var geometry
    let globalSettings = GlobalSettings.shared
    
    @State private var showingSkillSelector = false
    @FocusState private var isFocused: Bool
    @Binding var searchText: String
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            HStack {
                if appModel.viewState.showSkillSearch {
                    Button( action: {
                        Haptic.light()
                        searchText = ""
                        appModel.viewState.showSkillSearch = false
                        
                        sessionModel.selectedSkills = sessionModel.originalSelectedSkills
                        
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.vertical, 3)
                    }
                }
                
                // Full Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    // Horizontal scrolling selected skills
                        VStack {
                            if !sessionModel.selectedSkills.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 4) {
                                        ForEach(Array(sessionModel.selectedSkills).sorted(), id: \.self) { skill in
                                            SkillButton(
                                                appModel: appModel,
                                                sessionModel: sessionModel,
                                                title: skill,
                                                isSelected: true
                                            ) {
                                                sessionModel.selectedSkills.remove(skill)
                                            }
                                        }
                                    }
                                }
                            }
                            TextField(sessionModel.selectedSkills.isEmpty ? "Search skills..." : "Select more...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .tint(globalSettings.primaryYellowColor)
                                .focused($isFocused)
                                .onChange(of: isFocused) { _, newValue in
                                    updateSearchState(isFocused: newValue)
                                }
                                .onChange(of: appModel.viewState.showSkillSearch) { _, newValue in
                                    updateSearchState(isShowing: newValue)
                                }
                            
                            }
                    
                    Spacer()
                    
                    if !isFocused {
                        // Search skills button
                        CircleButton(
                            action: {
                                Haptic.light()
                                showingSkillSelector = true
                            },
                            frontColor: globalSettings.primaryYellowColor,
                            backColor: globalSettings.primaryDarkYellowColor,
                            width: 25,
                            height: 25,
                            borderColor: .clear,
                            disabled: false,
                            pressedOffset: 3
                            
                        ) {
                            Image(systemName: "figure.soccer")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(2)
                    }
                    
                    
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            Haptic.light()
                            searchText = ""
                        }) {
                            
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isFocused ? globalSettings.primaryYellowColor : globalSettings.primaryLightGrayColor, lineWidth: 3)
                )
                .cornerRadius(20)
                .padding(.top, 13)

            }
            
        }
        .sheet(isPresented: $showingSkillSelector) {
            SkillSelectorSheet(appModel: appModel, sessionModel: sessionModel)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
    }
    private func updateSearchState(isFocused: Bool? = nil, isShowing: Bool? = nil) {
           if let isFocused = isFocused {
               if isFocused {
                   appModel.viewState.showSkillSearch = true
                   // When clicking on search bar, original equals the currently selected skills
                   sessionModel.originalSelectedSkills = sessionModel.selectedSkills
               }
           }
           
           if let isShowing = isShowing {
               if !isShowing {
                   self.isFocused = false
               }
           }
       }
}
