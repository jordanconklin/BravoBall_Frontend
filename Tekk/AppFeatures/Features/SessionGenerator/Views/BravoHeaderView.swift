//
//  BravoHeaderView.swift
//  BravoBall
//
//  Created by Jordan on 5/15/25.
//

import SwiftUI
import RiveRuntime

struct BravoHeaderView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    var geometry: ViewGeometry
    
    var body: some View {
        ZStack(alignment: .center) {
            Spacer()
            // Bravo
            RiveViewModel(fileName: "Bravo_Peaking_Home")
                .view()
                .frame(width: 90, height: 90)
                .offset(x: geometry.size.width * 0.1 - 105, y: -62)
            if appModel.viewState.showPreSessionTextBubble {
                preSessionMessageBubble
                    .offset(x: geometry.size.width * 0.1 + 15, y: -50)
            }
            Spacer()
        }
        .padding(.top, geometry.safeAreaInsets.top + 4)
    }
    
    private var preSessionMessageBubble: some View {
        ZStack(alignment: .center) {
            HStack(spacing: 0) {
                // Left Pointer
                Path { path in
                    path.move(to: CGPoint(x: 15, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 10))
                    path.addLine(to: CGPoint(x: 15, y: 20))
                }
                .fill(Color(hex:"E4FBFF"))
                .frame(width: 9, height: 20)
                .offset(x: 2, y: 1)
                
                // Text Bubble
                Text(sessionModel.orderedSessionDrills.isEmpty ? "Create your session with the filters below." : "Looks like you got \(sessionModel.orderedSessionDrills.count) drills for today!")
                    .font(.custom("Poppins-Bold", size: 13))
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex:"E4FBFF"))
                    )
                    .frame(maxWidth: 180)
            }
            .offset(x: 5, y: -15)
            .transition(.opacity.combined(with: .offset(y: 10)))
        }
    }
}

#if DEBUG
struct BravoHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        // Provide a mock geometry
        let geometry = ViewGeometry(size: CGSize(width: 390, height: 844), safeAreaInsets: EdgeInsets())
        BravoHeaderView(appModel: appModel, sessionModel: sessionModel, geometry: geometry)
    }
}
#endif 
