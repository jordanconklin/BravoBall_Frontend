//
//  GroupCard.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/25/25.
//

import SwiftUI

struct GroupCard: View {
    let group: GroupModel
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.soccer")
                .font(.system(size: 30))
                .foregroundColor(.black)
            
            Text(group.name)
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(group.description)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("\(group.drills.count) drills")
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
