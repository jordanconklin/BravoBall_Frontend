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
    let globalSettings = GlobalSettings.shared
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewGeometry) var geometry
    
    @State private var selectedDrill: DrillModel? = nil
    @State private var isPlaying = false
    @State private var restartTime: TimeInterval = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var countdownValue: Int?
    @State private var displayCountdown: Bool = true
    @State private var timer: Timer?
    @State private var player: AVPlayer? = nil
    @State private var showInfoSheet = false
    @State private var hapticGenerator = UINotificationFeedbackGenerator()
    @State private var impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
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
        self._selectedDrill = State(initialValue: nil)
        self._isPlaying = State(initialValue: false)
        self._countdownValue = State(initialValue: nil)
        self._displayCountdown = State(initialValue: true)
        self._timer = State(initialValue: nil)
        self._restartTime = State(initialValue: setDuration)
        self._elapsedTime = State(initialValue: setDuration)
    }

    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        backButton
                        Spacer()
                        
                        
                        Text("\(editableDrill.drill.title)")
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .font(.custom("Poppins-Bold", size: 18))
                            .padding(.leading, 60)
                        Spacer()
                        detailsButton
                    }
                    .padding(.top, 16)
                    
                    
                    ZStack {
                        // Background progress bar
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: .infinity, maxHeight: 8)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 12)
                            .fill(globalSettings.primaryYellowColor)
                            .frame(maxWidth: .infinity)
                            .scaleEffect(x: progress, anchor: .leading)
                            .frame(maxWidth: .infinity, maxHeight: 8)
                    }
                    .padding(.top, 10)

                    
                    HStack {
                        Spacer()
                        
                        Text("\(editableDrill.totalSets) sets - \(editableDrill.totalReps) reps - \(editableDrill.totalDuration) mins")
                            .font(.custom("Poppins-Bold", size: 13))
                            .foregroundColor(globalSettings.primaryGrayColor)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    
                    
                    Spacer()

                    // Center the video player more visually
                    if !editableDrill.drill.videoUrl.isEmpty, let videoUrl = URL(string: editableDrill.drill.videoUrl) {
                        CustomVideoPlayer(videoURL: videoUrl)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    }

                    // Play button, timer, and info button row
                    HStack(spacing: 24) {
                        togglePlayButton
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(.gray)
                            Text(timeString(from: elapsedTime))
                                .font(.custom("Poppins-Bold", size: 32))
                        }
                        // Info button
                        Button(action: { 
                            Haptic.light()
                            showInfoSheet = true 
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(globalSettings.primaryGrayColor)
                                .padding(.leading, 8)
                        }
                        .accessibilityLabel("How this works")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)

                    Spacer()
                    HStack {
                        endDrillButton
                        skipButton
                    }
                }
            }
            .padding(.horizontal, 20)
            .statusBar(hidden: false)
            .navigationBarHidden(true)
            .onChange(of: isPlaying) { newValue, _ in
                if newValue {
                    player?.play()
                } else {
                    player?.pause()
                }
            }
            .navigationDestination(item: $selectedDrill) { drill in
                DrillDetailView(appModel: appModel, sessionModel: sessionModel, drill: drill)
            }
            .sheet(isPresented: $showInfoSheet) {
                InfoPopupView(
                    title: "How Drill Timer Works",
                    description: "Press play to start the countdown for this set.\n\nWhen the timer ends, you'll move to the next set and the timer will reset.\n\nComplete all sets to finish the drill and proceed to the next one. You can see the amount of sets you completed on the progress bar above.\n\nYou can skip a drill, but your session will be marked as incomplete if you do.",
                    onClose: { showInfoSheet = false }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var togglePlayButton: some View {
        
        CircleButton(
            action: {
                Haptic.light()
                togglePlayPause()
            },
            frontColor: globalSettings.primaryYellowColor,
            backColor: globalSettings.primaryDarkYellowColor,
            width: 100,
            height: 100,
            disabled: countdownValue != nil,
            pressedOffset: 6
            
        ) {
            Group {
                if let countdown = countdownValue {
                    Text("\(countdown)")
                        .font(.custom("Poppins-Bold", size: 44))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
        }
        .opacity(editableDrill.setsDone != editableDrill.totalSets ? 1.0 : 0.0)


    }
    
    
    private var detailsButton: some View {
        // Details button
        Button(action: {
            Haptic.light()
            selectedDrill = editableDrill.drill

        }) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(Color.white)
                    .font(.system(size: 13, weight: .medium))
                Text("Details")
                    .font(.custom("Poppins-Bold", size: 13))
                    .foregroundColor(.white)
                
            }
            .padding(.horizontal,5)
            .padding(.vertical, 5)

            .background(globalSettings.primaryGrayColor)
            .cornerRadius(12)
                
        }
    }
    
    private var endDrillButton: some View {
        
        PrimaryButton(
            title: "Done",
            action: {
                Haptic.light()
                handleDrillCompletion()
                endDrill()
                
                if doneWithSession() {
                    handleSessionCompletion()
                }
            },
            frontColor: globalSettings.primaryGreenColor,
            backColor: globalSettings.primaryDarkGreenColor,
            textColor: Color.white,
            textSize: 18,
            width: .infinity,
            height: 50,
            disabled: !doneWithDrill()
            
        )
        .padding(.trailing, 5)

    }
    
    private var skipButton: some View {
        
        PrimaryButton(
            title: "Skip Drill",
            action: {
                Haptic.light()
                handleDrillCompletion()
                endDrill()
            },
            frontColor: globalSettings.primaryYellowColor,
            backColor: globalSettings.primaryDarkYellowColor,
            textColor: Color.white,
            textSize: 18,
            width: 150,
            height: 50,
            disabled: false
            
        ) {
            Image(systemName: "forward.fill")
                .foregroundColor(Color.white)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(.trailing, 5)

    }
    
    private var backButton: some View {
        Button(action: {
            Haptic.light()
            endDrill()
        }) {
            HStack {
                Image(systemName: "xmark")
                    .foregroundColor(globalSettings.primaryDarkColor)
            }
        }
    }
    
    private var setsDoneText: some View {
        Text("Set  \(min(Int(editableDrill.setsDone + 1), Int(editableDrill.totalSets))) / \(Int(editableDrill.totalSets))")
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(globalSettings.primaryDarkColor)
            .font(.custom("Poppins-Bold", size: 16))
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
    
    private var progress: Double {
        Double(editableDrill.setsDone) / Double(editableDrill.totalSets)
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
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
        AudioManager.shared.play321Start()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if let count = countdownValue {
                if count > 1 {
                    countdownValue = count - 1
                    impactGenerator.impactOccurred()
                } else {
                    timer.invalidate()
                    countdownValue = nil
                    displayCountdown = false
                    impactGenerator.impactOccurred(intensity: 1.0)
                    startTimer()
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if elapsedTime > 0 {
                // Check for specific time markers
                if elapsedTime == 30 {
                    impactGenerator.impactOccurred(intensity: 0.7)
                } else if elapsedTime == 10 {
                    impactGenerator.impactOccurred(intensity: 0.8)
                } else if elapsedTime <= 3 && elapsedTime > 0 {
                    // Last 3 seconds - increasing intensity
                    let intensity = 0.6 + (Double(3 - elapsedTime) * 0.15)
                    impactGenerator.impactOccurred(intensity: intensity)
                    if elapsedTime == 3 {
                        AudioManager.shared.play321Done()
                    }
                }
                
                elapsedTime -= 1
            } else {
                stopTimer()
                hapticGenerator.notificationOccurred(.success)
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

