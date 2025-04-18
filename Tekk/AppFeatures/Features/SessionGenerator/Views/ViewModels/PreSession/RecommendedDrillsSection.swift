//
//  RecommendedDrillsSection.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct RecommendedDrillsSection: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    private let layout = ResponsiveLayout.shared
    
    var body: some View {
        VStack(spacing: layout.standardSpacing) {
                HStack {
                    Text("Recommended drills for you:")
                        .font(.custom("Poppins-Bold", size: 17))
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .padding(.trailing, 60)
                    Spacer()
                }
                
            LazyVStack(spacing: layout.isPad ? 40 : 20) {
                    ForEach(sessionModel.recommendedDrills) { testDrill in
                        RecommendedDrillCard(
                            appModel: appModel,
                            sessionModel: sessionModel,
                            drill: testDrill
                        )
                        .frame(height: layout.isPad ? 340 : 170)
                    }
                }
                
            }
            .padding()
            .onAppear {
                loadRandomDrills()
            }
        
    }
    
    // TODO: make it so recommended drills really recommends drills based on users onboarding data
    func loadRandomDrills() {
        guard sessionModel.recommendedDrills.isEmpty else { return }  // Only load if empty
        let randomSet = Array(SessionGeneratorModel.testDrills.shuffled().prefix(3))
        sessionModel.recommendedDrills = randomSet
    }
}
