//
//  ForgotPasswordModel.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//
import SwiftUI

class ForgotPasswordModel: ObservableObject {
    @Published var showForgotPasswordPage: Bool = false
    @Published var forgotPasswordMessage: String = ""
    @Published var forgotPasswordStep: Int = 1 // 1: email, 2: code, 3: new password
    @Published var forgotPasswordEmail: String = ""
    @Published var forgotPasswordCode: String = ""
    @Published var forgotPasswordNewPassword: String = ""
    @Published var forgotPasswordConfirmPassword: String = ""
    @Published var isNewPasswordVisible: Bool = false
    
    func resetForgotPasswordState() {
        forgotPasswordStep = 1
        forgotPasswordEmail = ""
        forgotPasswordCode = ""
        forgotPasswordNewPassword = ""
        forgotPasswordConfirmPassword = ""
        forgotPasswordMessage = ""
        showForgotPasswordPage = false
    }
}
