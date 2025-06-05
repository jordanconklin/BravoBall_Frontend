//
//  SavedDrillsView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI
import RiveRuntime

struct SavedDrillsView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Environment(\.viewGeometry) var geometry
    
    @State private var showCreateGroup: Bool = false
    @State private var savedGroupName: String = ""
    @State private var savedGroupDescription: String = ""
    @State private var selectedGroup: GroupModel? = nil
    @State private var showInfoSheet: Bool = false
    
    // MARK: Main view
    var body: some View {
            ZStack {
                VStack {
                    HStack {
                        Button(action: { 
                            Haptic.light()
                            showInfoSheet = true 
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .accessibilityLabel("About Saved Drills")
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // Progress header
                        Text("Saved Drills")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.black)
                            .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            Haptic.light()
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
            .sheet(isPresented: $showInfoSheet) {
                InfoPopupView(
                    title: "How Saved Drills Work",
                    description: "Save your favorite drills and organize them into groups for easy access.\n\nTap the plus icon to create a new group, and add drills to keep your training organized.\n\nYou can view, edit, or remove your saved drills at any time.",
                    onClose: { showInfoSheet = false }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedGroup) { group in
                GroupDetailView(appModel: appModel, sessionModel: sessionModel, group: group)
                    .onDisappear {
                        appModel.viewState.showingDrillDetail = false
                    }
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
                        Haptic.light()
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
                    Haptic.light()
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

#if DEBUG
struct SavedDrillsView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        SavedDrillsView(appModel: appModel, sessionModel: sessionModel)
    }
}
#endif
