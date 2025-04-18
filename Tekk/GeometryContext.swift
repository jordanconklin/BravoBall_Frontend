//
//  GeometryContext.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/17/25.
//

import SwiftUI
import Foundation

// Setting gemoetry of app based off of user's current screen size
struct GeometryContextProvider<Content: View>: View {
    let content: Content
    @StateObject var layout = ResponsiveLayout()
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .onAppear {
                    layout.updateGeometry(geometry)
                }
                .onChange(of: geometry.size) {
                    layout.updateGeometry(geometry)
                }
        }
    }
}
