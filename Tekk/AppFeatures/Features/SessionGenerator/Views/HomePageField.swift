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
        
    var body: some View {
        
            VStack {
                
                
                Spacer()

                // When the session begins, the field pops up
                    ZStack {
                        RiveViewModel(fileName: "Grass_Field").view()
                            .frame(width: geometry.size.width)
                            .padding(.top, 150)
                        
                        HStack {
                            
                            VStack {
                                sessionMessageBubble
     
                                RiveViewModel(fileName: "Bravo_Animation", stateMachineName: "State Machine 1").view()
                                    .frame(width: 90, height: 90)
                            }
         
                            
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
                        }
                                            
                        
                            HStack {
                                VStack(alignment: .leading) {
                                    // back button only shows if session not completed
                                        Button(action:  {
                                            Haptic.light()

                                            appModel.viewState.showHomePage = true
                                            BravoTextBubbleDelay()
                                        }) {
                                            VStack(alignment: .leading) {
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(Color.white)
                                                    .padding(8)
                                                    .background(appModel.globalSettings.primaryYellowColor)
                                                    .clipShape(Circle())
                                                
                                                RiveViewModel(fileName: "Break_Area").view()
                                                    .frame(width: 80, height: 80)
                                                
                                            }
                                            .padding(.bottom,45)
                                            
                                            
                                        }
                                    
                                }

                                
                                Spacer()

                            }
                            .padding()
                            .padding(.top, 500) // TODO: find better way to style this
                        
                        
                    }
            }
    }
    
    func BravoTextBubbleDelay() {
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
        .padding(.top, 20)
        .disabled(sessionModel.sessionInProgress())
        .opacity(sessionModel.sessionInProgress() ? 0.5 : 1.0)
    }
    
    private var sessionMessageBubble: some View {
        VStack(spacing: 0) {
            
            Text(sessionModel.sessionInProgress() ? "You have \(sessionModel.sessionsLeftToComplete()) drill\(sessionModel.sessionsLeftToComplete() == 1 ? "" : "s") left." : "Well done! Click on the trophy to claim your prize.")
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex:"60AE17"))
                )
                .frame(maxWidth: 150)
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
    }
}

#if DEBUG
struct HomePageField_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        let geometry = ViewGeometry(size: CGSize(width: 390, height: 844), safeAreaInsets: EdgeInsets())
        // Set the flag to show the field
        appModel.viewState.showFieldBehindHomePage = true
        return HomePageField(appModel: appModel, sessionModel: sessionModel)
            .environment(\.viewGeometry, geometry)
    }
}
#endif
