//
//  GroupFilterOptions.swift
//  BravoBall
//
//  Created by Joshua Conklin on 5/12/25.
//

import SwiftUI

// MARK: Group Filter Options
struct GroupFilterOptions: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let group: GroupModel
    let globalSettings = GlobalSettings.shared
    
    @Environment(\.viewGeometry) var geometry
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        OptionsSheet(
            title: "Group Options",
            onDismiss: {
                appModel.viewState.showGroupFilterOptions = false
            }
        ) {
            VStack(alignment: .leading, spacing: 5) {
                if group.id != sessionModel.likedDrillsGroup.id {
                    OptionButton(
                        icon: "trash",
                        title: "Delete Group"
                    ) {
                        Haptic.light()
                        showDeleteConfirmation = true
                    }
                    .alert("Delete Group", isPresented: $showDeleteConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            sessionModel.deleteGroup(groupId: group.id)
                            appModel.viewState.showGroupFilterOptions = false
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you want to delete this group? This action cannot be undone.")
                    }
                    
                    Divider()
                }
                
                OptionButton(
                    icon: "gearshape",
                    title: "Edit Group"
                ) {
                    Haptic.light()
                    withAnimation {
                        appModel.viewState.showGroupFilterOptions = false
                        appModel.viewState.showDrillGroupDeleteButtons.toggle()
                    }
                }
                
                Divider()
                
                OptionButton(
                    icon: "plus",
                    title: "Add to Group"
                ) {
                    Haptic.light()
                    
                    // Show add drill sheet
                    withAnimation(.spring(dampingFraction: 0.7)) {
                        appModel.viewState.showGroupFilterOptions = false
                        
                        // Delay to allow the first sheet to close smoothly
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // This will be handled in the parent view by binding to showAddDrillSheet
                            NotificationCenter.default.post(name: Notification.Name("ShowAddDrillSheet"), object: nil)
                        }
                    }
                }
            }
        }
        .frame(width: geometry.size.width)
    }
}
