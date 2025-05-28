//
//  DrillFollowAlongView.swift
//  BravoBall
//
//  Created by Jordan on 1/15/25.
//

import SwiftUI
import AVKit

struct DrillFollowAlongView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Binding var editableDrill: EditableDrillModel
    
    @State private var showDrillDetailView: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewGeometry) var geometry
    
    @State private var isPlaying = false
    @State private var restartTime: TimeInterval = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var countdownValue: Int?
    @State private var displayCountdown: Bool = true
    @State private var timer: Timer?
    @State private var player: AVPlayer? = nil
    
    
    init(appModel: MainAppModel, sessionModel: SessionGeneratorModel, editableDrill: Binding<EditableDrillModel>) {
        // First initialize all properties
        self.appModel = appModel
        self.sessionModel = sessionModel
        self._editableDrill = editableDrill
        
        // Calculate set duration
        let setDuration = calculateSetDuration(
            totalDuration: editableDrill.wrappedValue.totalDuration,
            totalSets: editableDrill.wrappedValue.totalSets
        )
        
        // Initialize all @State properties
        self._showDrillDetailView = State(initialValue: false)
        self._isPlaying = State(initialValue: false)
        self._countdownValue = State(initialValue: nil)
        self._displayCountdown = State(initialValue: true)
        self._timer = State(initialValue: nil)
        self._restartTime = State(initialValue: setDuration)
        self._elapsedTime = State(initialValue: setDuration)
    }

    
    var body: some View {
        
        
        
//        ZStack(alignment: .bottom) {
//            Color.white.ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                HStack {
                    
                    backButton

                    Spacer()
                    
                    Text("\(editableDrill.drill.title)")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .font(.custom("Poppins-Bold", size: 18))
                        .padding(.leading, 60)
                    
                    Spacer()
                    
                    // How-to button
                    Button(action: {
                        showDrillDetailView = true
                        
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(Color.white)
                                .font(.system(size: 13, weight: .medium))
                            Text("How-to")
                                .font(.custom("Poppins-Bold", size: 13))
                                .foregroundColor(.white)
                            
                        }
                        .padding(.horizontal,5)
                        .padding(.vertical, 5)

                        .background(appModel.globalSettings.primaryLightGrayColor)
                        .cornerRadius(12)
                            
                    }
                    
                }
                
                .padding(.top, 16)
                
                
                // Progress stroke rectangle
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 360, y: 0))
                }
                .stroke(
                    Color.gray.opacity(0.3),
                    style: StrokeStyle(
                        lineWidth: 9,
                        lineCap: .round  // This rounds the ends
                    )
                )
                .overlay(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 360, y: 0))
                    }
                    .trim(from: 0, to: Double(editableDrill.setsDone) / Double(editableDrill.totalSets))
                    .stroke(
                        appModel.globalSettings.primaryYellowColor,
                        style: StrokeStyle(
                            lineWidth: 9,
                            lineCap: .round  // This rounds the ends
                        )
                    )
                    .animation(.linear, value: Double(editableDrill.setsDone) / Double(editableDrill.totalSets))
                )
                .frame(width: 360, height: 20)
                .padding(.top, 20)
                
                
                Text("Sets \(Int(editableDrill.setsDone)) / \(Int(editableDrill.totalSets))")
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    .font(.custom("Poppins-Bold", size: 16))
                
                Spacer()
                

                HStack {
                    Spacer()
                    
                    // Top timer section
                    VStack(alignment: .center, spacing: 4) {
                        Text("Time")
                            .font(.custom("Poppins-Bold", size: 24))
                            .foregroundColor(.gray)
                        Text(timeString(from: elapsedTime))
                            .font(.custom("Poppins-Bold", size: 26))
                    }
                    
                    Spacer()
                }


                Spacer()

                ZStack {
                    // Video preview in the middle
                    if !editableDrill.drill.videoUrl.isEmpty, let videoUrl = URL(string: editableDrill.drill.videoUrl) {
                        VideoPlayer(player: player)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                            .onAppear {
                                let avPlayer = AVPlayer(url: videoUrl)
                                player = avPlayer
                                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                                    avPlayer.seek(to: .zero)
                                    avPlayer.play()
                                }
                            }
                            .onDisappear {
                                player?.pause()
                                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
                            }
                    }
                    
                    // Add countdown overlay
                    if let countdown = countdownValue {
                        Text("\(countdown)")
                            .font(.custom("Poppins-Bold", size: 60))
                            .foregroundColor(.white)
                    }
                    
                }
                
                
                Spacer()
                
                Button(action: togglePlayPause) {
                    Circle()
                        .fill(.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.1), radius: 10)
                        .overlay(
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        )
                        .padding(.bottom, 145)
                }
                
                Spacer()
                
                if doneWithDrill() {
                    Button(action: {
                        handleDrillCompletion()
                        endDrill()
                        
                        if doneWithSession() {
                            handleSessionCompletion()
                        }
                        
                    }
                            
                    ){
                        Text("End Drill")
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.red)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .statusBar(hidden: false)
            .navigationBarHidden(true)
            .sheet(isPresented: $showDrillDetailView) {
                DrillDetailView(appModel: appModel, sessionModel: sessionModel, drill: editableDrill.drill)
            }
            .onChange(of: isPlaying) { newValue in
                if newValue {
                    player?.play()
                } else {
                    player?.pause()
                }
            }
            
    }
    
    private var backButton: some View {
        Button(action: {
            stopTimer()
            dismiss()
        }) {
            HStack {
                Image(systemName: "xmark")
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
            }
        }
    }
    
    private func doneWithDrill() -> Bool {

        return editableDrill.totalSets == editableDrill.setsDone
    }
    
    private func handleDrillCompletion() {
        editableDrill.isCompleted = true
    }
    
    private func doneWithSession() -> Bool {
        for editableDrill in sessionModel.orderedSessionDrills {
            if editableDrill.isCompleted == false {
                return false
            }
        }
        return true
        
    }

    private func handleSessionCompletion() {
        appModel.addCompletedSession(
            date: Date(),
            drills: sessionModel.orderedSessionDrills,
            totalCompletedDrills: completedDrillsCount,
            totalDrills: sessionModel.orderedSessionDrills.count
        )
        
        if appModel.allCompletedSessions.count(where: {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .day)
        }) == 1 {
            appModel.currentStreak += 1
        }
        
        appModel.highestStreakSetter(streak: appModel.currentStreak)
    }
    
    private var completedDrillsCount: Int {
        sessionModel.orderedSessionDrills.filter( {$0.isCompleted == true}).count
    }
    

    private func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            if displayCountdown {
                startCountdown()
            } else {
                startTimer()
            }
        } else {
            stopTimer()
        }
    }
    
    private func startCountdown() {
        countdownValue = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if let count = countdownValue {
                if count > 1 {
                    countdownValue = count - 1
                } else {
                    timer.invalidate()
                    countdownValue = nil
                    displayCountdown = false
                    startTimer()
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if elapsedTime > 0 {
                elapsedTime -= 1
            } else {
                stopTimer()
                if editableDrill.setsDone < editableDrill.totalSets {
                    editableDrill.setsDone += 1
                }
                elapsedTime = restartTime
                isPlaying = false
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func endDrill() {
        stopTimer()
        dismiss()
        
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func calculateSetDuration(totalDuration: Int, totalSets: Int, breakDuration: Int = 45) -> TimeInterval {
        // Convert total duration to seconds
        let totalDurationSeconds = Double(totalDuration) * 60.0
        
        // Calculate total break time
        let totalBreakSeconds = Double(totalSets - 1) * Double(breakDuration)
        
        // Calculate available time for sets
        let availableTimeForSets = totalDurationSeconds - totalBreakSeconds
        
        // Ensure minimum set duration (e.g., 30 seconds)
        let minimumSetDuration: Double = 10.0
        
        // Calculate base set duration
        var setDuration = availableTimeForSets / Double(totalSets)
        
        // If set duration is too short, adjust break duration
        if setDuration < minimumSetDuration {
            // Calculate how much time we need for minimum sets
            let requiredTimeForSets = minimumSetDuration * Double(totalSets)
            
            // Calculate new break duration that fits within total time
            let newBreakDuration = (totalDurationSeconds - requiredTimeForSets) / Double(totalSets - 1)
            
            // Use the minimum set duration
            setDuration = minimumSetDuration
            
            // Round break duration to nearest 5 seconds
            let roundedBreakDuration = (newBreakDuration / 5.0).rounded() * 5.0
            
            print("⚠️ Adjusted break duration to \(roundedBreakDuration) seconds to maintain minimum set duration")
            return setDuration
        }
        
        // Round to nearest 10 seconds
        let roundedDuration = (setDuration / 10.0).rounded() * 10.0
        return roundedDuration
    }
}

//#Preview {
//    struct PreviewWrapper: View {
//        @State var mockDrill = EditableDrillModel(
//            drill: DrillModel(
//                title: "Test Drill",
//                skill: "Passing",
//                sets: 2,
//                reps: 10,
//                duration: 15,
//                description: "Test description",
//                tips: ["Tip 1", "Tip 2"],
//                equipment: ["Ball"],
//                trainingStyle: "Medium Intensity",
//                difficulty: "Beginner"
//            ),
//            setsDone: 0,
//            totalSets: 2,
//            totalReps: 10,
//            totalDuration: 15,
//            isCompleted: false
//        )
//        
//        var body: some View {
//            DrillFollowAlongView(
//                appModel: MainAppModel(),
//                sessionModel: SessionGeneratorModel(appModel: MainAppModel(), onboardingData: OnboardingModel.OnboardingData()),
//                editableDrill: $mockDrill  // This binding will be mutable
//            )
//        }
//    }
//    
//    return PreviewWrapper()
//}
