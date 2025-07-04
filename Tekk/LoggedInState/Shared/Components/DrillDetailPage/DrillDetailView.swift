//
//  DrillDetailView.swift
//  BravoBall
//
//  Created by Jordan on 1/12/25.
//


import SwiftUI
import RiveRuntime
import AVKit

struct DrillDetailView: View {
    
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let drill: DrillModel
    let globalSettings = GlobalSettings.shared
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localToastManager = ToastManager()
    @Environment(\.viewGeometry) var geometry
    @State private var showSaveDrill: Bool = false

    
    // MARK: Main view
    var body: some View {
            ZStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        HStack(spacing: 20) {
                            Button(action: {
                                Haptic.light()
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(globalSettings.primaryDarkColor)
                                }
                            }
                            
                            Spacer()
                            
                            // Like button
                            Button(action: {
                                Haptic.light()
                                sessionModel.toggleDrillLike(drillId: drill.id, drill: drill)
                            }) {
                                Image(systemName: sessionModel.isDrillLiked(drill) ? "heart.fill" : "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(sessionModel.isDrillLiked(drill) ? .red : .clear)  // Fill color
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: sessionModel.isDrillLiked(drill) ? "heart.fill" : "heart")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(sessionModel.isDrillLiked(drill) ? .red : globalSettings.primaryDarkColor)  // Stroke color
                                            .frame(width: 30, height: 30)
                                    )
                            }
                            
                            // Add drill to group
                            Button(action: {
                                Haptic.light()
                                showSaveDrill = true
                            }) {
                                Image(systemName: sessionModel.isDrillInGroup(drill) ? "bookmark.fill" : "bookmark")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(globalSettings.primaryDarkColor)
                                    .frame(width: 30, height: 30)
                            }
                            
                        }
                        .padding(.vertical)
                        
                        if !drill.videoUrl.isEmpty, let videoUrl = URL(string: drill.videoUrl) {
                            CustomVideoPlayer(videoURL: videoUrl)
                        }
                        
                        // Drill title
                        Text(drill.title)
                            .font(.custom("Poppins-Bold", size: 24))
                            .foregroundColor(globalSettings.primaryDarkColor)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(globalSettings.primaryDarkColor)
                            Text(drill.description)
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(globalSettings.primaryGrayColor)
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(globalSettings.primaryDarkColor)
                            ForEach(Array(drill.instructions.enumerated()), id: \.element) { index, instruction in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.custom("Poppins-Bold", size: 16))
                                        .foregroundColor(globalSettings.primaryGrayColor)
                                    Text(instruction)
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(globalSettings.primaryGrayColor)
                                }
                            }
                        }
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tips")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(globalSettings.primaryDarkColor)
                            ForEach(drill.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(tip)
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(globalSettings.primaryGrayColor)
                                }
                            }
                        }
                        
                        // Equipment needed
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Equipment Needed")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(globalSettings.primaryDarkColor)
                            ForEach(drill.equipment, id: \.self) { item in
                                HStack(spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.gray)
                                    Text(item)
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(globalSettings.primaryGrayColor)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .navigationBarBackButtonHidden(true)
                .frame(width: geometry.size.width)
                

                // Add drill to session button
                
                if !isDrillInRunningSession() {
                    FloatingAddButton(
                        appModel: appModel
                    ){
                        Haptic.light()
                        addDrillWithToast()
                    }
                }
                
                
                // save to group view
                
                if showSaveDrill {
                    findGroupToSaveToView
                }
                
            }
            .background(Color.white)
            .toastOverlay()
            .environmentObject(localToastManager)
            
    }
    
    // MARK: Find groups to save view
    private var findGroupToSaveToView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    showSaveDrill = false
                }
            
            VStack {
                HStack {
                    Button(action: {
                        Haptic.light()
                        withAnimation {
                            showSaveDrill = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(globalSettings.primaryDarkColor)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Text("Save to group")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(globalSettings.primaryGrayColor)
                    Spacer()
                }
                .padding(.top, 15)
                
                if sessionModel.savedDrills.isEmpty {
                    Text("No groups created yet")
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(.gray)
                        .padding()
                    
                } else {
                    // Groups Display
                    ScrollView {

                            ForEach(sessionModel.savedDrills) { group in
                                GroupCard(group: group)
                                        .onTapGesture {
                                            Haptic.light()
                                            // MARK: testing
                                            withAnimation {
                                                if group.drills.contains(where: { $0.id == drill.id }) {
                                                    showSaveDrill = false
                                                    localToastManager.toastMessage = .unAdded("Drill unadded from group")
                                                    sessionModel.removeDrillFromGroup(drill: drill, groupId: group.id)
                                                    
                                                } else {
                                                    showSaveDrill = false
                                                    
                                                    sessionModel.addDrillToGroup(drill: drill, groupId: group.id)
                                                    localToastManager.toastMessage = .success("Drill added to group")
                                                }
                                            }
                                            showSaveDrill = false
                                        }
                            }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: 300, height: 470)
            .background(Color.white)
            .cornerRadius(15)
        }

    }
    
    func isDrillInRunningSession() -> Bool {
        return sessionModel.orderedSessionDrills.contains(where: { $0.drill.title == drill.title })
    }
    
    private func addDrillWithToast() {
        withAnimation {
            if sessionModel.orderedSessionDrills.contains(where: { $0.drill.id == drill.id }) {
                    localToastManager.showToast(.notAllowed("Drill already in session"))
            } else {
                localToastManager.showToast( .success("Drill added to session"))
            }
        }
        
        sessionModel.addDrillToSession(drills: [drill])
    }
            
}


#Preview("With Liked Drill") {
    // Create mock drill
    let mockDrill = DrillModel(
        id: UUID(),
        title: "Quick Passing Drill",
        skill: "Passing",
        subSkills: ["close_control"],
        sets: 3,
        reps: 10,
        duration: 15,
        description: "A fast-paced drill designed to improve passing accuracy and ball control under pressure. Players work in pairs to complete a series of quick passes while moving.",
        instructions: [""],
        tips: [
            "Keep your head up while dribbling",
            "Use both feet for passing",
            "Maintain proper body position",
            "Communicate with your partner"
        ],
        equipment: [
            "Soccer ball",
            "Cones",
            "Training vest",
            "Partner"
        ],
        trainingStyle: "Technical",
        difficulty: "Intermediate",
        videoUrl: "www.example.com"
    )
    
    let mockAppModel = MainAppModel()
    let mockSessionModel = SessionGeneratorModel()
    
    
    return DrillDetailView(
        appModel: mockAppModel,
        sessionModel: mockSessionModel,
        drill: mockDrill
    )
}
