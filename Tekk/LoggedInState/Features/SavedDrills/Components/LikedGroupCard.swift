//
//  LikedGroupCard.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct LikedGroupCard: View {
    @ObservedObject var sessionModel: SessionGeneratorModel
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 30))
                .foregroundColor(.black)
            
            Text("\(sessionModel.likedDrillsGroup.name)")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(.black)
                .lineLimit(1)
            
            
            Text("\(sessionModel.likedDrillsGroup.drills.count) drills")
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 170, height: 170)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}
