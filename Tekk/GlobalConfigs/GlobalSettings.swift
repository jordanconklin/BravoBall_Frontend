//
//  GlobalSettings.swift
//  BravoBall
//
//  Created by Jordan on 10/30/24.
//

import SwiftUI
import Foundation

// global view settings
class GlobalSettings: ObservableObject {
    static let shared = GlobalSettings()
    
    @Published var primaryYellowColor: Color = Color(hex: "F6C356")
    @Published var primaryDarkYellowColor: Color = Color(hex: "c2983e")
    @Published var secondaryYellowColor: Color = Color(hex: "C8A369")
    @Published var primaryGreenColor: Color = Color(hex:"3ab542")
    @Published var primaryDarkGreenColor: Color = Color(hex:"288a2e")
    @Published var primaryLightBlueColor: Color = Color(hex:"86C9F7")
    @Published var primaryDarkBlueColor: Color = Color(hex:"508fba")
    @Published var primaryPurpleColor: Color = Color(hex:"A863CF")
    @Published var primaryDarkColor: Color = Color(hex:"4F4F4F")
    @Published var primaryGrayColor: Color = Color(hex:"858585")
    @Published var primaryLightGrayColor: Color = Color(hex:"d6d6d6")
    @Published var primaryLightestGrayColor: Color = Color(hex:"f0f0f0")
}


// Settings for services, no need for ObservableObject


struct AppSettings {
    /// Testing cases
    /// 1: Production
    /// 2: Computer (localhost)
    /// 3: Phone (Wi-Fi IP via Info.plist)
    static let appDevCase = 2
    static let debug = false // for testing; set false in production


    static var baseURL: String {
        #if DEBUG
        switch appDevCase {
        case 1:
            // Production (simulated during debug)
            return "https://bravoball-backend.onrender.com"
        case 2:
            // Localhost for simulator or Mac
            return "http://127.0.0.1:8000"
        case 3:
            // Wi-Fi IP for phone, pulled from Info.plist under key "PHONE_WIFI_IP"
            let wifiIP = Bundle.main.object(forInfoDictionaryKey: "PHONE_WIFI_IP") as? String
            return wifiIP.map { "http://\($0):8000" } ?? "http://127.0.0.1:8000"
        default:
            return "http://127.0.0.1:8000"
        }
        #else
        // Real production build (release)
        return "https://bravoball-backend.onrender.com"
        #endif
    }
}


