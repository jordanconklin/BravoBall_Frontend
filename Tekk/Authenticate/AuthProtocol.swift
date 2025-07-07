//
//  AuthProtocol.swift
//  BravoBall
//
//  Created by Joshua Conklin on 7/2/25.
//

protocol AuthenticationManaging: AnyObject {
    var isCheckingAuthentication: Bool { get }
    var isAuthenticated: Bool { get }
    var isCheckingAuth: Bool { get }
    func checkAuthenticationStatus() async -> Bool
    func updateAuthenticationStatus(onboardingModel: OnboardingModel, userManager: UserManager) async
    func clearInvalidTokens() async
}
