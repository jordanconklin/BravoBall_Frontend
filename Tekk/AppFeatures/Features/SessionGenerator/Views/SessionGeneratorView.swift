//
//  testSesGenView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 1/22/25.
//

import SwiftUI
import RiveRuntime

// Main session page view
struct SessionGeneratorView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @ObservedObject var userManager: UserManager
    @Environment(\.viewGeometry) var geometry
    

        
    
    // MARK: Main view
    var body: some View {
        ZStack(alignment: .top) {
            // Sky background color
            Color(hex:"BEF1FA")
                .ignoresSafeArea()
            
            HomePageField(appModel: appModel, sessionModel: sessionModel)
        
            
            HomePageToolBar(appModel: appModel, sessionModel: sessionModel, userManager: userManager)
                .frame(maxWidth: geometry.size.width)
            
        }
        .fullScreenCover(isPresented: $appModel.viewState.showHomePage) {
            SessionGeneratorEditPage(appModel: appModel, sessionModel: sessionModel, geometry: geometry)
                .frame(maxWidth: geometry.size.width)
                .frame(maxWidth: .infinity)
        }
        .fullScreenCover(isPresented: $appModel.viewState.showSessionComplete) {
            SessionCompleteView(
                appModel: appModel, sessionModel: sessionModel
            )
        }
    }
    

}
//
//#if DEBUG
//struct SessionGeneratorView_Previews: PreviewProvider {
//    static var previews: some View {
//        let onboardingModel = OnboardingModel()
//        let appModel = MainAppModel()
//        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
//        SessionGeneratorView(onboardingModel: onboardingModel, appModel: appModel, sessionModel: sessionModel, userManager: userManager)
//    }
//}
//#endif

