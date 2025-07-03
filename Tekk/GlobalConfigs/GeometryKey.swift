//
//  GeometryKey.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/18/25.
//
import Foundation
import SwiftUI

struct ViewGeometry {
    let size: CGSize
    let safeAreaInsets: EdgeInsets
    
    static var defaultValue: ViewGeometry {
        ViewGeometry(
            size: UIScreen.main.bounds.size,
            safeAreaInsets: EdgeInsets()
        )
    }
}

// Environment key definition
private struct GeometryKey: EnvironmentKey {
    static let defaultValue = ViewGeometry.defaultValue
}

// Environment value extension
extension EnvironmentValues {
    var viewGeometry: ViewGeometry {
        get { self[GeometryKey.self] }
        set { self[GeometryKey.self] = newValue }
    }
}
