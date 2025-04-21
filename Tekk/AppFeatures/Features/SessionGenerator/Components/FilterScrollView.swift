//
//  FilterScrollView.swift
//  BravoBall
//
//  Created by Jordan on 4/18/25.
//

import SwiftUI

// MARK: - Filter Scroll View Component
struct FilterScrollView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Gray line below filters
            Rectangle()
                .stroke(appModel.globalSettings.primaryGrayColor.opacity(0.3), lineWidth: 1)
                .frame(height: 1)
                .offset(y: 30)
            
            // All filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(FilterType.allCases, id: \.self) { type in
                        FilterButton(
                            appModel: appModel,
                            type: type,
                            icon: appModel.icon(for: type),
                            isSelected: appModel.selectedFilter == type,
                            value: sessionModel.filterValue(for: type)
                        ) {
                            if appModel.selectedFilter == type {
                                appModel.selectedFilter = nil
                            } else {
                                appModel.selectedFilter = type
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
                .frame(height: 50)
            }
            .padding(.leading, 70)
            
            // White filter button on the left
            FilterOptionsButton(appModel: appModel, sessionModel: sessionModel)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 5)
    }
} 
