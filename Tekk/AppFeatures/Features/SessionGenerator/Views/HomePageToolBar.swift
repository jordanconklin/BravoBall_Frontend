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
    @ObservedObject var sessionModel: SessionGeneratorModel
    @ObservedObject var userManager: UserManager
    
    @Environment(\.viewGeometry) var geometry
    
    var body: some View {
        HStack(spacing: 22) {
            
            // this will use userManger object later for profile pic
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(appModel.globalSettings.primaryYellowColor)
            
            Spacer()
            
            HStack {
                Label("500", systemImage: "diamond.fill")
                    .labelStyle(IconOnlyLabelStyle())
                    .foregroundColor(.blue)
                    .font(.system(size: 25))
                Text("0")
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
            }

            HStack {
                Label("5", systemImage: "heart.fill")
                    .labelStyle(IconOnlyLabelStyle())
                    .foregroundColor(.red)
                    .font(.system(size: 25))
                Text("0")
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
            }
            
            HStack {
                Image("Streak_Flame")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 40)
                Text("\(appModel.currentStreak)")
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
            }
            
        }
        .frame(height: 45)
        .padding()
        .background(Color.clear)  // Transparent, but blocks touches
        .contentShape(Rectangle())
    }
}
