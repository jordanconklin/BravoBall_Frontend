//
//  HomePage.swift
//  BravoBall
//
//  Created by Jordan on 4/18/25.
//

import SwiftUI
import RiveRuntime

// MARK: - Home Page Component
struct HomePage: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.viewGeometry) var geometry
    @State private var searchSkillsText: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            // Where session begins, behind home page
            AreaBehindHomePage(appModel: appModel, sessionModel: sessionModel)
                .frame(maxWidth: geometry.size.width)
            
            if appModel.viewState.showHomePage {
                VStack(spacing: 0) {
                    // Header with Bravo and message bubble
                    HStack(alignment: .bottom) {
                        Spacer()
                        
                        // Bravo
                        RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 3")
                            .view()
                            .frame(width: 110, height: 110)
                            .padding(.leading, geometry.size.width * 0.1)
                            .offset(y: 15)
                        
                        // Pre-session text bubble
                        if appModel.viewState.showPreSessionTextBubble {
                            PreSessionMessageBubble(appModel: appModel, sessionModel: sessionModel)
                                // .padding(.leading, 5)
                                .offset(y: -10)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, geometry.safeAreaInsets.top - 85)
                    
                    // ZStack for rounded corner
                    ZStack {
                        // Rounded corner
                        RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                            .fill(Color.white)
                            .edgesIgnoringSafeArea(.bottom)
                        
                        // White part of home page
                        VStack(alignment: .center, spacing: 5) {
                            HStack {
                                Spacer()
                                
                                SkillSearchBar(appModel: appModel, sessionModel: sessionModel, searchText: $searchSkillsText)
                                    .padding(.top, 3)
                                
                                Spacer()
                            }
                            .padding(.top, 5)
                            .frame(maxWidth: appModel.layout.adaptiveWidth(geometry))
                            
                            // If skills search bar is selected
                            if appModel.viewState.showSkillSearch {
                                // New view for searching skills
                                SearchSkillsView(
                                    appModel: appModel,
                                    sessionModel: sessionModel,
                                    searchText: $searchSkillsText
                                )
                            } else {
                                FilterScrollView(appModel: appModel, sessionModel: sessionModel)
                                    .frame(width: geometry.size.width)
                                
                                // Main content
                                ScrollView(showsIndicators: false) {
                                    VStack(spacing: appModel.layout.standardSpacing) {
                                        GeneratedDrillsSection(appModel: appModel, sessionModel: sessionModel)
                                            .padding(.horizontal, appModel.layout.contentMinPadding)
                                        
                                        if sessionModel.selectedSkills.isEmpty {
                                            RecommendedDrillsSection(appModel: appModel, sessionModel: sessionModel)
                                                .padding(.horizontal, appModel.layout.contentMinPadding)
                                        }
                                    }
                                }
                                .frame(maxWidth: appModel.layout.adaptiveWidth(geometry))
                            }
                        }
                        .frame(maxWidth: geometry.size.width)
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
} 
