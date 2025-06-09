//
//  BravoBallApp.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

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
