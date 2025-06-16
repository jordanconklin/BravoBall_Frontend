//
//  SessionGeneratorHomePage.swift
//  BravoBall
//
//  Created by Jordan on 5/15/25.
//

import SwiftUI

struct SessionGeneratorHomePage: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Binding var searchSkillsText: String
    var geometry: ViewGeometry
    

    var body: some View {
        ZStack(alignment: .top) {
            if appModel.viewState.showFieldBehindHomePage {
                AreaBehindHomePage(appModel: appModel, sessionModel: sessionModel)
                    .frame(maxWidth: geometry.size.width)
                    .transition(.opacity)
            }
            
            if appModel.viewState.showHomePage {
                // White part of home page
                VStack(alignment: .center, spacing: 0) {
                    HomePageToolBar(appModel: appModel)
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
                    // If skills search bar is not selected
                    } else {
                        FilterScrollView(appModel: appModel, sessionModel: sessionModel, geometry: geometry)
                            .frame(width: geometry.size.width)
                        // Main content
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: appModel.layout.standardSpacing) {
                                GeneratedDrillsSection(appModel: appModel, sessionModel: sessionModel)
                                    .padding(.horizontal, appModel.layout.contentMinPadding)
                            }
                            .padding(.bottom, 120)
                        }
                        .frame(maxWidth: appModel.layout.adaptiveWidth(geometry))
                    }
                }
                .frame(maxWidth: geometry.size.width)
                .background(Color.white)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appModel.viewState.showFieldBehindHomePage)
        .animation(.easeInOut(duration: 0.4), value: appModel.viewState.showHomePage)
        .onAppear {
            BravoTextBubbleDelay()
        }
        .onDisappear {
            sessionModel.saveChanges()
        }
        .onChange(of: UIApplication.shared.applicationState) {
            if UIApplication.shared.applicationState == .background {
                sessionModel.saveChanges()
            }
        }
    }

    func BravoTextBubbleDelay() {
        // Initially hide the bubble
        appModel.viewState.showPreSessionTextBubble = false
        // Show it after a 1 second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                appModel.viewState.showPreSessionTextBubble = true
            }
        }
    }
}

#if DEBUG
struct SessionGeneratorHomePage_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        @State var searchSkillsText = ""
        let geometry = ViewGeometry(size: CGSize(width: 390, height: 844), safeAreaInsets: EdgeInsets())
        return SessionGeneratorHomePage(appModel: appModel, sessionModel: sessionModel, searchSkillsText: $searchSkillsText, geometry: geometry)
    }
}
#endif 
