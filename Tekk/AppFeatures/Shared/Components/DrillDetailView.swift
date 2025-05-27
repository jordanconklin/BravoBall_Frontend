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
    
    @Environment(\.viewGeometry) var geometry
    @Environment(\.dismiss) private var dismiss
    @State private var showSaveDrill: Bool = false

    
    // MARK: Main view
    var body: some View {
            ZStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        HStack(spacing: 25) {
                            Button(action: {
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                                }
                            }
                            
                            Spacer()
                            
                            // Like button
                            Button(action: {
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
                                            .foregroundColor(sessionModel.isDrillLiked(drill) ? .red : appModel.globalSettings.primaryDarkColor)  // Stroke color
                                            .frame(width: 30, height: 30)
                                    )
                            }
                            
                            // Add drill to group
                            Button(action: {
                                showSaveDrill = true
                            }) {
                                Image(systemName: "square.and.arrow.down")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                                    .frame(width: 30, height: 30)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    if sessionModel.orderedSessionDrills.contains(where: { $0.drill.id == drill.id }) {
                                        appModel.toastMessage = .notAllowed("Drill is already in session")
                                    } else {
                                        appModel.toastMessage = .success("Drill added to session")
                                    }
                                }
                                
                                sessionModel.addDrillToSession(drills: [drill])

                            }) {
                                RiveViewModel(fileName: "Plus_Button").view()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding(.vertical)
                        
                        if !drill.videoUrl.isEmpty, let videoUrl = URL(string: drill.videoUrl) {
                            VideoPlayer(player: AVPlayer(url: videoUrl))
                                .aspectRatio(16/9, contentMode: .fit)
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Drill information
                        VStack(alignment: .leading, spacing: 16) {
                            Text(drill.title)
                                .font(.custom("Poppins-Bold", size: 24))
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            
                            HStack(spacing: 16) {
                                Label("\(drill.sets)" + " sets", systemImage: "repeat")
                                Label("\(drill.reps)" + " reps", systemImage: "figure.run")
                                Label("\(drill.duration)" + " minutes", systemImage: "clock")
                            }
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            Text(drill.description)
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(appModel.globalSettings.primaryGrayColor)
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            ForEach(Array(drill.instructions.enumerated()), id: \.element) { index, instruction in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.custom("Poppins-Bold", size: 16))
                                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                    Text(instruction)
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                }
                            }
                        }
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tips")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            ForEach(drill.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(tip)
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                }
                            }
                        }
                        
                        // Equipment needed
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Equipment Needed")
                                .font(.custom("Poppins-Bold", size: 18))
                                .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            ForEach(drill.equipment, id: \.self) { item in
                                HStack(spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.gray)
                                    Text(item)
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(width: geometry.size.width)
                
                if showSaveDrill {
                    findGroupToSaveToView
                }
                
            }
        // MARK: testing
            .toastOverlay(appModel: appModel)
            
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
                        withAnimation {
                            showSaveDrill = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Text("Save to group")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                if sessionModel.savedDrills.isEmpty {
                    Text("No groups created yet")
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(.gray)
                        .padding()
                    
                } else {
                    // Groups Display
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(sessionModel.savedDrills) { group in
                                GroupCard(group: group)
                                        .onTapGesture {
                                            // MARK: testing
                                            withAnimation {
                                                if group.drills.contains(where: { $0.id == drill.id }) {
                                                    appModel.toastMessage = .unAdded("Drill unadded from group")
                                                    sessionModel.removeDrillFromGroup(drill: drill, groupId: group.id)
                                                    
                                                } else {
                                                    appModel.toastMessage = .success("Drill added to group")
                                                    sessionModel.addDrillToGroup(drill: drill, groupId: group.id)
                                                }
                                            }
                                            showSaveDrill = false
                                        }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 300, height: 470)
            .background(Color.white)
            .cornerRadius(15)
        }

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
    let mockSessionModel = SessionGeneratorModel(appModel: MainAppModel(), onboardingData: .init())
    
    
    return DrillDetailView(
        appModel: mockAppModel,
        sessionModel: mockSessionModel,
        drill: mockDrill
    )
}
