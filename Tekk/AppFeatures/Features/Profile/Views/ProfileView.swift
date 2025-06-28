//
//  ProfileView.swift
//  BravoBall
//
//  Created by Jordan on 1/7/25.
//

import SwiftUI
import SwiftKeychainWrapper

struct ProfileView: View {
    @ObservedObject var onboardingModel: OnboardingModel
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var sessionModel: SessionGeneratorModel
    @ObservedObject var userManager: UserManager
    
    @Environment(\.viewGeometry) var geometry
    @StateObject private var settingsModel = SettingsModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showEditDetails = false
    @State private var showChangePassword = false
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    
    var body: some View {
            ScrollView {
                LazyVStack(spacing: 25) {
                    profileHeader
                    
                    actionSection(title: "Account", buttons: [
                        customActionButton(title: "Edit your details", icon: "pencil"),
                        customActionButton(title: "Change Password", icon: "lock.fill"),
                        customActionButton(title: "Share With a Friend", icon: "square.and.arrow.up.fill")
                    ])
                    
                    actionSection(title: "Support", buttons: [
                        customActionButton(title: "Feature Requests", icon: "lightbulb.fill"),
                        customActionButton(title: "Privacy Policy", icon: "doc.text.fill"),
                        customActionButton(title: "Terms of Service", icon: "doc.fill"),
                        customActionButton(title: "Follow our Socials", icon: "link")
                    ])
                    
                    // App Version Info
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 12)

                    logoutButton
                        .padding(.horizontal)

                    deleteAccountButton
                        .padding(.horizontal)

                    // Moderate bottom padding so Delete Account is always visible
                    Spacer().frame(height: 60)
                }
                .padding(.vertical)
                .background(Color.white)
            }
            // The different alerts for logout or delete
            .edgesIgnoringSafeArea(.top)
            .alert(isPresented: $appModel.showAlert) {
                switch appModel.alertType {
                    case .logout:
                        return Alert(
                            title: Text("Logout"),
                            message: Text("Are you sure you want to Logout?"),
                            primaryButton: .destructive(Text("Logout")) {
                                userManager.clearUserKeychain()
                                logOutUser()

                            },
                            secondaryButton: .cancel()
                        )
                    case .delete:
                        return Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteAccount()
                            },
                            secondaryButton: .cancel()
                        )
                    case .none:
                        return Alert(title: Text(""))
                }
            }
            .sheet(isPresented: $showEditDetails) {
                EditDetailsView(globalSettings: appModel.globalSettings, settingsModel: settingsModel)
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView(globalSettings: appModel.globalSettings, settingsModel: settingsModel)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showTerms) {
                TermsOfServiceView()
            }
    }
    
     
    private var backButton: some View {
        Button(action: {
            Haptic.light()
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(appModel.globalSettings.primaryYellowColor)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 5) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(Color(hex:"86C9F7"))
            

            VStack(spacing: 0) {
                
                let email = userManager.getUserFromKeychain()
                
    
                
                Text("\(email)")
                    .font(.custom("Poppins-Bold", size: 18))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5) // Ensures text is legible
                    .padding(.bottom, 2)
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, geometry.safeAreaInsets.top)
        .background(Color.white)
    }
    
    private func actionSection(title: String, buttons: [AnyView]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
           Text(title)
               .font(.custom("Poppins-Bold", size: 20))
               .foregroundColor(appModel.globalSettings.primaryDarkColor)
               .padding(.leading)
               .padding(.bottom, 10)
            
            VStack(spacing: 0) {
                ForEach(buttons.indices, id: \.self) { index in
                    buttons[index]
                    
                    if index < buttons.count - 1 {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
    
    // Custom action button for each row in the profile view
    private func customActionButton(title: String, icon: String) -> AnyView {
        AnyView(
            // Button action
            Button(action: {
                Haptic.light()
                handleButtonAction(title)
            }) {
                // Custom button styling
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(appModel.globalSettings.primaryYellowColor)
                    Text(title)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(appModel.globalSettings.primaryDarkColor)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(appModel.globalSettings.primaryDarkColor.opacity(0.7))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        )
    }

    // Handle the button actions
    private func handleButtonAction(_ title: String) {
        switch title {
        case "Edit your details":
            showEditDetails = true
        case "Change Password":
            showChangePassword = true
        case "Feature Requests":
            if let url = URL(string: "https://bravoball.featurebase.app") {
                UIApplication.shared.open(url)
            }
        case "Follow our Socials":
            showSocialLinks()
        case "Share With a Friend":
            shareApp()
        case "Privacy Policy":
            showPrivacyPolicy = true
        case "Terms of Service":
            showTerms = true
        default:
            break
        }
    }

    // Show the social links
    private func showSocialLinks() {
        let alert = UIAlertController(title: "Follow Us", message: nil, preferredStyle: .actionSheet)
        
        for link in settingsModel.socialLinks {
            alert.addAction(UIAlertAction(title: link.platform, style: .default) { _ in
                if let url = URL(string: link.url) {
                    UIApplication.shared.open(url)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }

    // Share the app with a friend
    private func shareApp() {
        let text = "Check out BravoBall - Your personal soccer training companion!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            viewController.present(activityVC, animated: true)
        }
    }

    // Send email to the founder
    private func sendEmail(subject: String, to email: String, body: String = "") {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let emailEncoded = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "mailto:\(emailEncoded)?subject=\(subjectEncoded)&body=\(bodyEncoded)") else {
            print("❌ Failed to create email URL")
            return
        }
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        print("❌ Failed to open mail app")
                    }
                }
            } else {
                // Show alert that no mail app is configured
                let alert = UIAlertController(
                    title: "No Email App Found",
                    message: "Please make sure you have an email app set up on your device.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let viewController = windowScene.windows.first?.rootViewController {
                    viewController.present(alert, animated: true)
                }
            }
        }
    }

    private var logoutButton: some View {
        
        PrimaryButton(
            title: "Logout",
            action: {
                Haptic.light()
                appModel.alertType = .logout
                appModel.showAlert = true
            },
            frontColor: appModel.globalSettings.primaryYellowColor,
            backColor: appModel.globalSettings.primaryDarkYellowColor,
            textColor: Color.white,
            textSize: 18,
            width: .infinity,
            height: 50,
            disabled: false
                
        )
    }
    
    private var deleteAccountButton: some View {
        
        PrimaryButton(
            title: "Delete Account",
            action: {
                Haptic.light()
                appModel.alertType = .delete
                appModel.showAlert = true
            },
            frontColor: Color(hex: "#ed1818"),
            backColor: Color(hex: "#ba1818"),
            textColor: Color.white,
            textSize: 18,
            width: .infinity,
            height: 50,
            disabled: false
                
        )
    }
    
    private func logOutUser() {
        // Use the new clearLoginState method for consistency
        onboardingModel.clearLoginState()
        
        // Clear user's cache and data
        sessionModel.clearUserData()
        appModel.cleanupOnLogout()
        
        // Reset to home tab
        appModel.mainTabSelected = 0
        
        print("✅ User logged out successfully")
    }
    
    
    
    private func deleteAccount() {
        let endpoint = "/delete-account/"
        
        Task {
            do {
                let (data, response) = try await APIService.shared.request(
                    endpoint: endpoint,
                    method: "DELETE",
                    headers: ["Content-Type": "application/json"]
                )
                print("📥 Backend response status: \(response.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                
                if response.statusCode == 200 {
                    // Store email before clearing for logging
                    let userEmail = userManager.email
                    
                    // Clear all user data
                    print("\n🗑️ Deleting account for user: \(userEmail)")
                    
                    // 1. Clear cache first
                    CacheManager.shared.clearUserCache()
                    print("  ✓ Cleared user cache")
                    
                    // 2. Clear keychain data
                    userManager.clearUserKeychain()
                    print("  ✓ Cleared keychain data")
                    
                    // 3. Clear any remaining UserDefaults data
                    if let bundleID = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: bundleID)
                    }
                    print("  ✓ Cleared UserDefaults data")
                    
                    // 4. Log out user
                    logOutUser()
                    print("  ✓ Logged out user")
                    
                    print("✅ Account deleted and all data cleared successfully")
                } else {
                    print("❌ Failed to delete account: \(response.statusCode)")
                    // You might want to show an error message to the user here
                }
            } catch {
                print("❌ Error deleting account: \(error)")
            }
        }
    }
    
    
    
    
}


#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock models for preview
        let onboardingModel = OnboardingModel()
        let appModel = MainAppModel()
        let userManager = UserManager()
        let sessionModel = SessionGeneratorModel(appModel: appModel, onboardingData: .init())
        
        // Optionally set some mock data for a more realistic preview
        onboardingModel.isLoggedIn = true
        userManager.updateUserKeychain(
            email: "jordan@example.com"
        )
        
        return ProfileView(
            onboardingModel: onboardingModel,
            appModel: appModel,
            sessionModel: sessionModel,
            userManager: userManager
        )
    }
}
#endif
