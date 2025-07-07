//
//  RiveAnimationView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/1/25.
//

// MARK: - Rive Animation View
import SwiftUI
import RiveRuntime


struct RiveAnimationView: View {
    @ObservedObject var userManager: UserManager
    
    let fileName: String
    let stateMachine: String
    let actionForTrigger: Bool
    let animationScale: CGFloat?
    let triggerName: String
    let completionHandler: (() -> Void)?
    
    @State private var riveViewModel: RiveViewModel
    
    init(userManager: UserManager, fileName: String, stateMachine: String, actionForTrigger: Bool, animationScale: CGFloat? = nil, triggerName: String, completionHandler: (() -> Void)? = nil) {
        self.userManager = userManager
        self.fileName = fileName
        self.stateMachine = stateMachine
        self.actionForTrigger = actionForTrigger
        self.animationScale = animationScale
        self.triggerName = triggerName
        self.completionHandler = completionHandler
        _riveViewModel = State(initialValue: RiveViewModel(fileName: fileName, stateMachineName: stateMachine))
    }
    
    var body: some View {
        Group {
            if let scale = animationScale {
                riveViewModel.view()
                    .scaleEffect(scale)
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
            } else {
                riveViewModel.view()
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
            }
        }

        .onChange(of: actionForTrigger) { newValue in
            print("[RiveAnimationView] isCheckingAuth changed to \(newValue)")
            if !newValue && userManager.showIntroAnimation {
                // Transition from loading to intro animation
                print("[RiveAnimationView] Triggering transition to Intro Animation")
                transitionToIntroAnimation()
            }
        }
    }
    
    private func transitionToIntroAnimation() {

        // Transition to intro animation state machine
        riveViewModel.triggerInput(triggerName)
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.7) {
            print("[RiveAnimationView] transitionToIntroAnimation - Intro animation complete, calling completionHandler()")
            completionHandler?()
        }
    }
}
