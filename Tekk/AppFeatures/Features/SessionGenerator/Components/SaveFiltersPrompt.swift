//
//  SaveFiltersPrompt.swift
//  BravoBall
//
//  Created by Jordan on 4/18/25.
//

import SwiftUI

// MARK: - Save Filters Prompt Component
struct SaveFiltersPrompt: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @State private var savedFiltersName: String = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    appModel.viewState.showSaveFiltersPrompt = false
                }
            
            VStack {
                HStack {
                    // Exit the prompt
                    Button(action: {
                        withAnimation {
                            appModel.viewState.showSaveFiltersPrompt = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Text("Save filter")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                TextField("Name", text: $savedFiltersName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Save filters button
                Button(action: {
                    withAnimation {
                        sessionModel.saveFiltersInGroup(name: savedFiltersName)
                        appModel.viewState.showSaveFiltersPrompt = false
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
                .disabled(savedFiltersName.isEmpty)
                .padding(.top, 16)
            }
            .padding()
            .frame(width: 300, height: 170)
            .background(Color.white)
            .cornerRadius(15)
        }
        .onDisappear {
            savedFiltersName = ""
        }
    }
} 
