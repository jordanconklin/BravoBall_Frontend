//
//  AppDelegate.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//

import SwiftUI
//import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
