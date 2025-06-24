//
//  GroupDetailView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/21/25.
//

import SwiftUI
import RiveRuntime

// MARK: - Group Detail View
struct GroupDetailView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let group: GroupModel
    
    
    @State private var selectedDrill: DrillModel? = nil
    
    @Environment(\.viewGeometry) var geometry
    @Environment(\.dismiss) private var dismiss
    @State private var showAddDrillSheet = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var currentDrills: [DrillModel] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Button(action: {
                            Haptic.light()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                        }
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        
                        Spacer()
                        
                        Button(action: {
                            Haptic.light()
                            appModel.viewState.showGroupFilterOptions = true
                        }) {
                            Image(systemName: "ellipsis")
                        }
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        
                    }
                    .padding()
                    
                    
                    // Group Info Header
                    VStack(spacing: 8) {
                        Image(systemName: "figure.soccer")
                            .font(.system(size: 40))
                        Text(group.name)
                            .font(.custom("Poppins-Bold", size: 24))
                        Text(group.description)
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    // Drills List
                    if currentDrills.isEmpty {
                        Text("No drills saved yet")
                            .font(.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Spacer()
                    } else {
                        List {
                            ForEach($currentDrills) { $drill in
                                HStack {
                                    if appModel.viewState.showDrillGroupDeleteButtons {
                                        Button(action: {
                                            Haptic.light()
                                            sessionModel.removeDrillFromGroup(drill: drill, groupId: group.id)
                                            // Remove from currentDrills
                                            if let index = currentDrills.firstIndex(where: { $0.id == drill.id }) {
                                                currentDrills.remove(at: index)
                                            }
                                            
                                            if currentDrills.isEmpty {
                                                appModel.viewState.showDrillGroupDeleteButtons = false
                                            }
                                            
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.red)
                                                    .frame(width: 20, height: 20)
                                                Rectangle()
                                                    .fill(Color.white)
                                                    .frame(width: 10, height: 2)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.leading)
                                    }
                                    
                                    DrillRow(appModel: appModel, sessionModel: sessionModel, drill: drill)
                                        .onTapGesture {
                                            selectedDrill = drill
                                        }
                                }
                            }
                        }
                        .id(UUID()) // Force refresh list when data changes
                    }
                }
                
                // Floating add button
                
                FloatingAddButton(
                    appModel: appModel
                ){
                    showAddDrillSheet = true
                }
                
                // Toast message
                if showToast {
                    VStack {
                        Spacer()
                        
                        Text(toastMessage)
                            .font(.custom("Poppins-Medium", size: 14))
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeInOut, value: showToast)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                }
            }
            .frame(width: geometry.size.width)
            .navigationDestination(item: $selectedDrill) { drill in
                DrillDetailView(appModel: appModel, sessionModel: sessionModel, drill: drill)
            }
            // Sheet pop-up for filter option button
            .sheet(isPresented: $appModel.viewState.showGroupFilterOptions) {
                GroupFilterOptions(
                    appModel: appModel,
                    sessionModel: sessionModel,
                    group: group
                )
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(200)])
            }
            // Sheet for adding drills
            .sheet(isPresented: $showAddDrillSheet) {
                DrillSearchView(
                    appModel: appModel,
                    sessionModel: sessionModel,
                    onDrillsSelected: { selectedDrills in
                        // Add selected drills to the group using the new bulk add method
                        // which returns the actual number of new drills added
                        let newDrillsCount = sessionModel.addDrillsToGroup(drills: selectedDrills, groupId: group.id)
                        
                        // Update the current drills state to reflect changes
                        refreshDrillsList()
                        
                        // Show toast notification with accurate count from the model
                        toastMessage = "\(newDrillsCount) drill\(newDrillsCount == 1 ? "" : "s") added to group"
                        withAnimation {
                            showToast = true
                        }
                        
                        // Auto-hide toast after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showToast = false
                            }
                        }
                        
                        // Dismiss the sheet
                        showAddDrillSheet = false
                    },
                    title: "Add Drills to \(group.name)",
                    actionButtonText: { count in
                        "Add \(count) \(count == 1 ? "Drill" : "Drills") to Group"
                    },
                    filterDrills: { drill in
                        false // No drills are disabled
                    },
                    isDrillSelected: { drill in
                        // Check if the drill is already in the group
                        currentDrills.contains(drill)
                    }
                )
            }
            .onAppear {
                // First deduplicate all groups to ensure we start with clean data
                sessionModel.deduplicateAllGroups()
                
                // Then initialize current drills from the group
                refreshDrillsList()
                
                // Set up notification observer
                NotificationCenter.default.addObserver(
                    forName: Notification.Name("ShowAddDrillSheet"),
                    object: nil,
                    queue: .main
                ) { _ in
                    showAddDrillSheet = true
                }
                
                // Add observer for drill changes
                NotificationCenter.default.addObserver(
                    forName: Notification.Name("DrillGroupUpdated"),
                    object: nil,
                    queue: .main
                ) { notification in
                    if let updatedGroupId = notification.userInfo?["groupId"] as? UUID,
                       updatedGroupId == group.id {
                        refreshDrillsList()
                    }
                }
                
                // Add observer for liked drills changes
                NotificationCenter.default.addObserver(
                    forName: Notification.Name("LikedDrillsUpdated"),
                    object: nil,
                    queue: .main
                ) { notification in
                    // Check if this view is displaying the liked drills group
                    let groupId = group.id
                    let likedGroupId = sessionModel.likedDrillsGroup.id
                    print("📣 Received LikedDrillsUpdated notification")
                    print("  - Current group ID: \(groupId)")
                    print("  - Liked group ID: \(likedGroupId)")
                    
                    if let notificationGroupId = notification.userInfo?["likedGroupId"] as? UUID {
                        print("  - Notification group ID: \(notificationGroupId)")
                    }
                    
                    if groupId == likedGroupId {
                        print("✅ Matched! Refreshing liked drills list")
                        refreshDrillsList()
                    } else {
                        print("❌ Not a match, skipping refresh")
                    }
                }
            }
            .onDisappear {
                // Remove notification observers
                NotificationCenter.default.removeObserver(
                    self,
                    name: Notification.Name("ShowAddDrillSheet"),
                    object: nil
                )
                NotificationCenter.default.removeObserver(
                    self,
                    name: Notification.Name("DrillGroupUpdated"),
                    object: nil
                )
                NotificationCenter.default.removeObserver(
                    self,
                    name: Notification.Name("LikedDrillsUpdated"),
                    object: nil
                )
            }
        }
    
    }
    
    // Function to refresh the drills list from the latest data
    private func refreshDrillsList() {
        // Always run a comprehensive deduplication first
        sessionModel.deduplicateAllGroups()
        
        // First check if this is the liked drills group
        if group.id == sessionModel.likedDrillsGroup.id {
            currentDrills = sessionModel.likedDrillsGroup.drills
            print("📋 Refreshed liked drills list: \(currentDrills.count) drills")
        } else if let groupIndex = sessionModel.savedDrills.firstIndex(where: { $0.id == group.id }) {
            currentDrills = sessionModel.savedDrills[groupIndex].drills
            print("📋 Refreshed drill list: \(currentDrills.count) drills")
        } else {
            // Just use the original group data if we can't find an updated version
            currentDrills = group.drills
            print("⚠️ Could not find updated group, using original: \(currentDrills.count) drills")
        }
    }
}

