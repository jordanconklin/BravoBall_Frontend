//
//  HomePageField.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/24/25.
//
import SwiftUI
import RiveRuntime


struct HomePageField: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.viewGeometry) var geometry
    
    @State private var showingFollowAlong: Bool = false
        
    var body: some View {
        
        ScrollView {
                
                // When the session begins, the field pops up
                ZStack(alignment: .top) {
                    
                    
                    VStack(spacing: 0) {
                        RiveViewModel(fileName: "Grass_Field").view()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .padding(.top, 30)
                    
                    }
                    
                    
                    
                    VStack {
                        
                        sessionMessageBubble
                        
                        HStack(spacing: 15) {
 
                            RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                                .frame(width: 110, height: 110)
                            
                            Button(action:  {
                                Haptic.light()
                                appModel.viewState.showHomePage = true
                                bravoTextBubbleDelay()
                            }) {
                                RiveViewModel(fileName: "Backpack").view()
                                    .frame(width: 80, height: 80)
                                    .padding(.top, 25)
                                
                            }
                            .buttonStyle(ShrinkingButtonStyle())
                        }
                        
                        
                        PrimaryButton(
                            title: sessionModel.doesSessionHaveAnyProgress() ? "Continue" : "Begin",
                            action: {
                                Haptic.light()
                                showingFollowAlong = true
                            },
                            frontColor: appModel.globalSettings.primaryYellowColor,
                            backColor: appModel.globalSettings.primaryDarkYellowColor,
                            textColor: Color.white,
                            textSize: 18,
                            width: 180,
                            height: 50,
                            disabled: !sessionModel.sessionInProgress()
                                
                        )
                        .padding()
                        .opacity(sessionModel.sessionInProgress() ? 1.0 : 0.0)
                        
                        

     
                        
                        VStack(spacing: 15) {
                            
                            // Ordered drill cards on the field
                            ForEach(sessionModel.orderedSessionDrills, id: \.drill.id) { editableDrill in
                                if let index = sessionModel.orderedSessionDrills.firstIndex(where: {$0.drill.id == editableDrill.drill.id}) {
                                    FieldDrillCard(
                                        appModel: appModel,
                                        sessionModel: sessionModel,
                                        editableDrill: $sessionModel.orderedSessionDrills[index]
                                    )
                                }
                            }
                            
                            // Trophy button for completionview
                            trophyButton
                        }
                        .padding()
                        .padding(.bottom, 120)
                    }
                    .padding(.top, 220)
                    
                    Spacer()
                    
                }

        }
        .edgesIgnoringSafeArea(.all)
        .background(Color(hex:"70D412"))

        
        .fullScreenCover(isPresented: $showingFollowAlong) {
            if let index = sessionModel.orderedSessionDrills.firstIndex(where: { !$0.isCompleted }) {
                DrillFollowAlongView(
                    appModel: appModel,
                    sessionModel: sessionModel,
                    editableDrill: $sessionModel.orderedSessionDrills[index]
                )
            }
        }
    }
    
    func bravoTextBubbleDelay() {
       // Initially hide the bubble
       appModel.viewState.showPreSessionTextBubble = false
       
       // Show it after a 1 second delay
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           withAnimation(.easeIn(duration: 0.3)) {
               appModel.viewState.showPreSessionTextBubble = true
           }
       }
   }
    
    private var trophyButton: some View {
        Button(action: {
            Haptic.light()
            AudioManager.shared.playSuccess()
            appModel.viewState.showSessionComplete = true
        }) {
            Image("BravoBall_Trophy")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 90)
        }
        .buttonStyle(ShrinkingButtonStyle())
        .padding(.top, 20)
        .disabled(sessionModel.sessionInProgress() || sessionModel.orderedSessionDrills.isEmpty)
        .opacity(sessionModel.sessionInProgress() || sessionModel.orderedSessionDrills.isEmpty ? 0.6 : 1.0)
    }

    
    private var sessionMessageBubble: some View {
        let state: SessionMessageState
        let drillsLeft = sessionModel.sessionsLeftToComplete()
        if sessionModel.orderedSessionDrills.isEmpty {
            state = .noDrills
        } else if sessionModel.sessionInProgress() {
            state = .inProgress(drillsLeft: drillsLeft)
        } else {
            state = .completed
        }
        
        return VStack(spacing: 0) {
            Text(message(for: state))
                .font(.custom("Poppins-Bold", size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex:"60AE17"))
                )
                .frame(maxWidth: 200)
                .transition(.opacity.combined(with: .offset(y: 10)))
            // Pointer
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 10, y: 10))
                path.addLine(to: CGPoint(x: 20, y: 0))
            }
            .fill(Color(hex:"60AE17"))
            .frame(width: 20, height: 10)
        }
        .padding(.trailing, 100)
    }
    
    private enum SessionMessageState {
        case noDrills
        case inProgress(drillsLeft: Int)
        case completed
    }
    
    private func message(for state: SessionMessageState) -> String {
        switch state {
        case .noDrills:
            return "Click on the soccer bag to add drills to your session!"
        case .inProgress(let drillsLeft):
            return "You have \(drillsLeft) drill\(drillsLeft == 1 ? "" : "s") to complete."
        case .completed:
            return "Well done! Click on the trophy to claim your prize."
        }
    }
}

#if DEBUG
struct HomePageField_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel()
        let geometry = ViewGeometry(size: CGSize(width: 390, height: 844), safeAreaInsets: EdgeInsets())
        // Set the flag to show the field
        appModel.viewState.showFieldBehindHomePage = true
        return HomePageField(appModel: appModel, sessionModel: sessionModel)
            .environment(\.viewGeometry, geometry)
    }
}
#endif
