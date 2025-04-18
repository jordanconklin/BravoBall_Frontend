//
//  SavedDrillsView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI

struct SavedDrillsView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let geometry: GeometryProxy
    
    @State private var showCreateGroup: Bool = false
    @State private var showGroupDetails: Bool = false
    @State private var savedGroupName: String = ""
    @State private var savedGroupDescription: String = ""
    @State private var selectedGroup: GroupModel? = nil
    
    // MARK: Main view
    var body: some View {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        Spacer()
                        
                        // Progress header
                        Text("Saved Drills")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.black)
                            .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            showCreateGroup = true
                        }) {
                            Image(systemName: "plus")
                                .font(.custom("Poppins-Bold", size: 20))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    AllGroupsDisplay(appModel: appModel, sessionModel: sessionModel, selectedGroup: $selectedGroup)
                    

                }
                
                if showCreateGroup {
                    createGroupPrompt
                }
                
            }
            .sheet(item: $selectedGroup) { group in
                GroupDetailView(appModel: appModel, sessionModel: sessionModel, group: group)
            }
    }
    
    // MARK: Create group prompt
    private var createGroupPrompt: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    savedGroupName = ""
                    savedGroupDescription = ""
                    showCreateGroup = false
                }
            
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            savedGroupName = ""
                            savedGroupDescription = ""
                            showCreateGroup = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Text("Create group")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                TextField("Name", text: $savedGroupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                TextField("Description", text: $savedGroupDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                Button(action: {
                    withAnimation {
                        sessionModel.createGroup(
                            name: savedGroupName,
                            description: savedGroupDescription
                        )
                        showCreateGroup = false
                    }
                }) {
                    Text("Save")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(appModel.globalSettings.primaryYellowColor)
                        .cornerRadius(8)
                }
                .disabled(savedGroupName.isEmpty || savedGroupDescription.isEmpty)
                .padding(.top, 16)
            }
            .padding()
            .frame(width: 300, height: 250)
            .background(Color.white)
            .cornerRadius(15)
        }
    }

}


//#Preview {
//    let mockAppModel = MainAppModel()
//    let mockSesGenModel = SessionGeneratorModel(appModel: MainAppModel(), onboardingData: OnboardingModel.OnboardingData())
//    
//    // Create a mock drill
//    let mockDrill = DrillModel(
//            title: "Quick Passing",
//            skill: "Passing",
//            sets: 3,
//            reps: 5,
//            duration: 15,
//            description: "Short passing drill to improve accuracy",
//            tips: ["no funny beezness"],
//            equipment: ["ball", "cones"],
//            trainingStyle: "Medium Intensity",
//            difficulty: "Beginner"
//        )
//        
//        // Create a mock group with the drill
//        let mockGroup = GroupModel(
//            name: "My First Group",
//            description: "Collection of passing drills",
//            drills: [mockDrill]
//        )
//        
//        // Add the mock group to savedDrills
//        mockSesGenModel.savedDrills = [mockGroup]
//    
//    
//    return SavedDrillsView(appModel: mockAppModel, sessionModel: mockSesGenModel)
//}
