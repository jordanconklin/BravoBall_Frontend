//
//  DrillRow.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/21/25.
//

import SwiftUI

// MARK: - Drill Row
struct DrillRow: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    let globalSettings = GlobalSettings.shared
    
    let drill: DrillModel
    
    
    var body: some View {
        HStack {
            Image(systemName: "figure.soccer")
                .font(.system(size: 24))
                .foregroundColor(.black)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(drill.title)
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.black)
                Text(drill.description)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Button to select a drill to add in the search drill view
            if appModel.viewState.showSearchDrills {
                Button(action: {
                    Haptic.light()
                    sessionModel.drillsToAdd(drill: drill)
                }) {
                    ZStack {
                        
                        if sessionModel.orderedSessionDrills.contains(where: { $0.drill.title == drill.title }) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(globalSettings.primaryLightGrayColor)
                                .stroke((globalSettings.primaryLightGrayColor), lineWidth: 2)
                                .frame(width: 20, height: 20)
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.white)
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(sessionModel.isDrillSelected(drill) ? globalSettings.primaryYellowColor : Color.clear)
                                .stroke(sessionModel.isDrillSelected(drill) ? globalSettings.primaryYellowColor : globalSettings.primaryDarkColor, lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                        
                        
                        if sessionModel.isDrillSelected(drill) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.white)
                        }
                    }
                    
                }
                .disabled(sessionModel.orderedSessionDrills.contains(where: { $0.drill.title == drill.title }))
                
            }
        }
        .padding(.vertical, 8)

    }
}
