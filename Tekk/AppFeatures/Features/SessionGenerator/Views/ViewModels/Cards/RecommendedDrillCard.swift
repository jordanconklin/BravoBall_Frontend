////
////  RecommendedDrillCard.swift
////  BravoBall
////
////  Created by Joshua Conklin on 2/25/25.
////
//
//import SwiftUI
//import RiveRuntime
//
//
//// Immutable drill card
//
//// TODO: make this look diff from regular drill card
//struct RecommendedDrillCard: View {
//    @ObservedObject var appModel: MainAppModel
//    @ObservedObject var sessionModel: SessionGeneratorModel
//    let drill: DrillModel
//    private let layout = ResponsiveLayout.shared
//    
//    @State private var showingDrillDetail: Bool = false
//    
//    var body: some View {
//        Button(action: {
//            showingDrillDetail = true
//        }) {
//            ZStack {
//                // Background card
//                RiveViewModel(fileName: "Drill_Card_Incomplete").view()
//                    .frame(width: layout.isPad ? 640 : 320, height: layout.isPad ? 340 : 170)
//                
//                // Content container
//                HStack(spacing: layout.isPad ? 20 : 12) {
//                    // Left side content
//                    HStack(spacing: layout.isPad ? 16 : 12) {
//                        // Drag handle
//                        Image(systemName: "line.3.horizontal")
//                            .foregroundColor(appModel.globalSettings.primaryGrayColor)
//                            .font(.system(size: layout.isPad ? 16 : 14))
//                        
//                        // Soccer icon
//                        Image(systemName: "figure.soccer")
//                            .font(.system(size: layout.isPad ? 28 : 24))
//                            .padding(layout.isPad ? 12 : 8)
//                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(10)
//                    }
//                    .padding(.leading, layout.isPad ? 24 : 16)
//                    
//                    // Center content
//                    VStack(alignment: .leading, spacing: layout.isPad ? 8 : 6) {
//                        Text(drill.title)
//                            .font(.custom("Poppins-Bold", size: layout.isPad ? 18 : 16))
//                            .foregroundColor(appModel.globalSettings.primaryDarkColor)
//                            .lineLimit(2)
//                        Text("\(drill.sets) sets - \(drill.reps) reps - \(drill.duration)")
//                            .font(.custom("Poppins-Bold", size: layout.isPad ? 16 : 14))
//                            .foregroundColor(appModel.globalSettings.primaryGrayColor)
//                            .lineLimit(1)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    // Right arrow
//                    Image(systemName: "chevron.right")
//                        .foregroundColor(appModel.globalSettings.primaryGrayColor)
//                        .font(.system(size: layout.isPad ? 16 : 14, weight: .semibold))
//                        .padding(.trailing, layout.isPad ? 24 : 16)
//                }
//                .frame(maxWidth: layout.isPad ? 600 : 300)
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//        .sheet(isPresented: $showingDrillDetail) {
//            DrillDetailView(
//                appModel: appModel,
//                sessionModel: sessionModel,
//                drill: drill
//            )
//        }
//    }
//}
