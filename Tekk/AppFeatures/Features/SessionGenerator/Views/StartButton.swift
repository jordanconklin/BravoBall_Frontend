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
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RiveViewModel(fileName: "Golden_Button").view()
                    .frame(width: 320, height: 80)
                Text("Start Session")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 80)
        .transition(.move(edge: .bottom))
    }
}

#if DEBUG
struct StartButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        StartButton(appModel: appModel) {
            // Preview action
        }
    }
}
#endif
