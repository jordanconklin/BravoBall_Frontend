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
    @Environment(\.viewGeometry) var geometry
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if group.id != sessionModel.likedDrillsGroup.id {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        Text("Delete Group")
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .font(.custom("Poppins-Bold", size: 12))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .alert("Delete Group", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        sessionModel.deleteGroup(groupId: group.id)
                        dismiss()
                        appModel.viewState.showGroupFilterOptions = false

                    }
                } message: {
                    Text("Are you sure you want to delete this group? This action cannot be undone.")
                }

            }
            
            
            Divider()
            
            Button(action: {
                                
                withAnimation {
                    appModel.viewState.showGroupFilterOptions = false
                    
                    appModel.viewState.showDrillGroupDeleteButtons.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    Text("Edit Group")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .font(.custom("Poppins-Bold", size: 12))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            Divider()
            
            Button(action: {
                // Show add drill sheet
                withAnimation(.spring(dampingFraction: 0.7)) {
                    appModel.viewState.showGroupFilterOptions = false
                    
                    // Delay to allow the first sheet to close smoothly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        // This will be handled in the parent view by binding to showAddDrillSheet
                        NotificationCenter.default.post(name: Notification.Name("ShowAddDrillSheet"), object: nil)
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    Text("Add to Group")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                        .font(.custom("Poppins-Bold", size: 12))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .frame(width: geometry.size.width)
        .padding(8)
        .background(Color.white)
        .frame(maxWidth: .infinity)

    }
}
