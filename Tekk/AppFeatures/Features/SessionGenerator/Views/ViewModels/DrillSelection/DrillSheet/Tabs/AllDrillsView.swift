//
//  AllDrillsView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//
import SwiftUI

struct AllDrillsView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @State private var searchText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search drills...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .focused($isFocused)
                    .tint(appModel.globalSettings.primaryYellowColor)

                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isFocused ? appModel.globalSettings.primaryYellowColor : appModel.globalSettings.primaryLightGrayColor, lineWidth: 3)
            )
            .cornerRadius(20)
            .padding()
            
            // Drills list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredDrills) { drill in
                        DrillRow(appModel: appModel, sessionModel: sessionModel,
                                 drill: drill
                        )
                        .padding(.horizontal)
                        Divider()
                    }
                }
            }
        }
    }
    
    // Filtered drills based on search text
    var filteredDrills: [DrillModel] {
        if searchText.isEmpty {
            return SessionGeneratorModel.testDrills
        } else {
            return SessionGeneratorModel.testDrills.filter { drill in
                drill.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
