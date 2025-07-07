//
//  BravoBallApp.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//

import SwiftUI

@main
struct BravoBallApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var toastManager = ToastManager()

    var body: some Scene {
        WindowGroup {
            // Your root view here
            ContentView()
                .environmentObject(toastManager)
        }
    }
}
