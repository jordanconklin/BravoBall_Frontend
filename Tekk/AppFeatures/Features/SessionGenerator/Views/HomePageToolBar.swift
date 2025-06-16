//
//  HomePageToolBar.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/15/25.
//

import SwiftUI
import RiveRuntime

struct HomePageToolBar: View {
    @ObservedObject var appModel: MainAppModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                
                Spacer()
                
                RiveViewModel(fileName: "Bravo_Peaking_Home")
                    .view()
                    .frame(width: 70, height: 70)
                
                Spacer()
                
                // Title
                Text("BravoBall")
                    .font(.custom("PottaOne-Regular", size: 24))
                    .foregroundColor(.white)
                    .padding(.trailing, 30)
                
                Spacer()
                
                HStack {
                    Image("Streak_Flame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                    Text("\(appModel.currentStreak)")
                        .font(.custom("Poppins-Bold", size: 30))
                        .padding(.trailing, 20)
                        .foregroundColor(Color.white)
                }
            }
            .frame(height: 80)
            .background(appModel.globalSettings.primaryYellowColor)

            
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(appModel.globalSettings.secondaryYellowColor)
                            .frame(height: 5)
                            .padding(.bottom, 0)
                            .shadow(color: .black.opacity(0.08), radius: 2, y: 2)
        }
    }
}
