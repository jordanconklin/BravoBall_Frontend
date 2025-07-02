//
//  FilterScrollView.swift
//  BravoBall
//
//  Created by Jordan on 5/15/25.
//

import SwiftUI

struct FilterScrollView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    var geometry: ViewGeometry
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Gray line below filters
            Rectangle()
                .stroke(appModel.globalSettings.primaryGrayColor.opacity(0.3), lineWidth: 1)
                .frame(height: 1)
                .offset(y: 30)
            // All filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: -5) {
                    ForEach(FilterType.allCases, id: \ .self) { type in
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
                .frame(height: 55)
            }
            .padding(.leading, 70)
            // White filter button on the left
            FilterOptionsButton(appModel: appModel, sessionModel: sessionModel)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 5)
    }
}

#if DEBUG
struct FilterScrollView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel()
        let geometry = ViewGeometry(size: CGSize(width: 390, height: 844), safeAreaInsets: EdgeInsets())
        FilterScrollView(appModel: appModel, sessionModel: sessionModel, geometry: geometry)
    }
}
#endif 
