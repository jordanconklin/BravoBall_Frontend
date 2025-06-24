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
        VStack(spacing: 0) {
            HStack(spacing: 22) {
                
                // this will use userManger object later for profile pic
                Button(action: {
                    Haptic.medium()
                    appModel.mainTabSelected = 3
                }) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.blue.opacity(0.25))
                        .padding(.bottom, 7)
                }
                
                Spacer()
                
//                HStack {
//                    Label("500", systemImage: "diamond.fill")
//                        .labelStyle(IconOnlyLabelStyle())
//                        .foregroundColor(.blue)
//                        .font(.system(size: 25))
//                    Text("0")
//                        .font(.custom("Poppins-Bold", size: 30))
//                        .foregroundColor(.blue)
//                }
//
//                HStack {
//                    Label("5", systemImage: "heart.fill")
//                        .labelStyle(IconOnlyLabelStyle())
//                        .foregroundColor(.red)
//                        .font(.system(size: 25))
//                    Text("0")
//                        .font(.custom("Poppins-Bold", size: 30))
//                        .foregroundColor(.red)
//                }
                
                Text("BravoBall")
                    .foregroundColor(appModel.globalSettings.primaryYellowColor)
                    .padding(.leading, 20)
                    .font(.custom("PottaOne-Regular", size: 25))
                
                Spacer()
                
                Button(action: {
                    Haptic.light()
                    appModel.mainTabSelected = 1
                }) {
                    HStack {
                        Image("Streak_Flame")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 40)
                        Text("\(appModel.currentStreak)")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundColor(.orange)
                    }
                }
                
            }
            .frame(height: 35)
            .padding(.horizontal)
            .padding(.vertical, 5)
            .contentShape(Rectangle())

            Divider()
                .frame(height: 3)
                .background(Color.gray.opacity(0.3))
            
        }
        .background(Color.white)
    }
}
