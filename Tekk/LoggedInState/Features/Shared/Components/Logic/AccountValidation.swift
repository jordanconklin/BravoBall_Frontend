//
//  AccountValidation.swift
//  BravoBall
//
//  Created by Jordan on 6/8/25.
//

import Foundation

struct AccountValidation {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, 1 letter, 1 number
        let passwordRegEx = ".{8,}" // At least 8 chars
        let letterRegEx = ".*[A-Za-z]+.*"
        let numberRegEx = ".*[0-9]+.*"
        let passPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        let letterPred = NSPredicate(format: "SELF MATCHES %@", letterRegEx)
        let numberPred = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        return passPred.evaluate(with: password) && letterPred.evaluate(with: password) && numberPred.evaluate(with: password)
    }
    
    static func passwordError(_ password: String) -> String? {
        if password.isEmpty { return nil }
        if password.count < 8 { return "Password must be at least 8 characters." }
        if !password.contains(where: { $0.isLetter }) { return "Password must contain at least one letter." }
        if !password.contains(where: { $0.isNumber }) { return "Password must contain at least one number." }
        return nil
    }
}
