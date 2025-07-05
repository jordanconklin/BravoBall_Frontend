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
    let globalSettings = GlobalSettings.shared
    
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
                        .foregroundColor(globalSettings.primaryLightBlueColor)
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
                    .foregroundColor(globalSettings.primaryYellowColor)
                    .padding(.leading, 20)
                    .font(.custom("PottaOne-Regular", size: 25))
                
                Spacer()
                
                Button(action: {
                    Haptic.light()
                    appModel.mainTabSelected = 1
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 23))
                            .foregroundColor(.orange)
                        Text("\(appModel.currentStreak)")
                            .font(.custom("Poppins-Bold", size: 25))
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

#if DEBUG
struct HomePageToolBar_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel()
        let userManager = UserManager()
        HomePageToolBar(appModel: appModel, sessionModel: sessionModel, userManager: userManager)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
    }
}
#endif
