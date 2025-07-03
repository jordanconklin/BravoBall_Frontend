//
//  AllGroupsDisplay.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct AllGroupsDisplay: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @Binding var selectedGroup: GroupModel?
    
    var body: some View {
        // Groups Display
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                
                LikedGroupCard(sessionModel: sessionModel)
                    .onTapGesture {
                        selectedGroup = sessionModel.likedDrillsGroup
                    }
                
                ForEach(sessionModel.savedDrills) { group in
                    GroupCard(group: group)
                        .onTapGesture {
                            selectedGroup = group
                        }
                }
            }
        }
        .padding()
    }
}
