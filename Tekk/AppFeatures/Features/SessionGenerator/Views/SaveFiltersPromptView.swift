//
//  SaveFiltersPromptView.swift
//  BravoBall
//
//  Created by Jordan on 5/15/25.
//

import SwiftUI

struct SaveFiltersPromptView: View {
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    @EnvironmentObject var toastManager: ToastManager
    @Binding var savedFiltersName: String
    var dismiss: () -> Void
    
    private let layout = ResponsiveLayout.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            VStack {
                HStack {
                    // Exit the prompt
                    Button(action: {
                        Haptic.light()
                        withAnimation {
                            dismiss()
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
                    Haptic.light()
                    withAnimation {
                        dismiss()
                        sessionModel.saveFiltersInGroup(name: savedFiltersName)
                        toastManager.showToast(.success("Filters saved as \"\(savedFiltersName)\""))
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

#if DEBUG
struct SaveFiltersPromptView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = MainAppModel()
        let sessionModel = SessionGeneratorModel()
        @State var name = ""
        return SaveFiltersPromptView(appModel: appModel, sessionModel: sessionModel, savedFiltersName: .constant("")) {
            // Dismiss closure for preview
        }
    }
}
#endif
