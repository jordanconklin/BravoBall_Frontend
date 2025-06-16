//
//  StartButton.swift
//  BravoBall
//
//  Created by Jordan on 5/15/25.
//

import SwiftUI
import RiveRuntime

struct StartButton: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            Haptic.heavy()
            action()
        }) {
            ZStack {
                RiveViewModel(fileName: "Golden_Button").view()
                    .frame(width: 320, height: 80)
                Text("Load Session")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom))
    }
    
    func isTheSessionInProgress() -> Bool {
        return sessionModel.orderedSessionDrills.contains(where: { $0.setsDone > 0 })
    }
}

#if DEBUG
struct StartButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        StartButton(appModel: appModel, sessionModel: sessionModel) {
            
        }
    }
}
#endif
