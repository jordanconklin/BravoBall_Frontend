//
//  LoginModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//
import SwiftUI

class LoginModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isPasswordVisible: Bool = false
    
    // Resets login info and error message when user cancels login page
    func resetLoginInfo() {
        email = ""
        password = ""
        errorMessage = ""
    }
}
