//
//  ToastMessageModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/24/25.
//

import SwiftUI


struct ToastMessage: Equatable {
    let type: ToastType
    let message: String
    
    static func success(_ message: String) -> ToastMessage {
        ToastMessage(type: .success, message: message)
    }
    
    static func notAllowed(_ message: String) -> ToastMessage {
        ToastMessage(type: .notAllowed, message: message)
    }
    
    static func unAdded(_ message: String) -> ToastMessage {
        ToastMessage(type: .unAdded, message: message)
    }
    
    enum ToastType {
        case success
        case notAllowed
        case unAdded
        case error // need this for server error message?
        
        var color: Color {
            switch self {
            case .success: return .green
            case .notAllowed: return .red
            case .unAdded: return .green
            case .error: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark"
            case .notAllowed: return "xmark"
            case .unAdded: return "checkmark"
            case .error: return "info.circle.fill"
            }
        }
    }
}
