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
    @Published var primaryYellowColor: Color = Color(hex: "F6C356")
    @Published var secondaryYellowColor: Color = Color(hex: "C8A369")
    @Published var primaryGreenColor: Color = Color(hex:"3ab542")
    @Published var primaryDarkColor: Color = Color(hex:"4F4F4F")
    @Published var primaryGrayColor: Color = Color(hex:"858585")
    @Published var primaryLightGrayColor: Color = Color(hex:"d6d6d6")
    @Published var primaryLightestGrayColor: Color = Color(hex:"f0f0f0")
}

// settings for services, dont need ObservableObject annotation
struct AppSettings {
    static var baseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? "http://10.0.3.169:8000"
    }
}
