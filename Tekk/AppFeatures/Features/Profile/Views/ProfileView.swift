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
                EditDetailsView(settingsModel: settingsModel)
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
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
                .foregroundColor(appModel.globalSettings.primaryYellowColor)
            

            VStack(spacing: 0) {
                
                let userData = userManager.getUserFromKeychain()
                
    
                
                Text("\(userData.firstName) \(userData.lastName)")
                    .font(.custom("Poppins-Bold", size: 18))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5) // Ensures text is legible
                    .padding(.bottom, 2)
                    .foregroundColor(appModel.globalSettings.primaryDarkColor)
                
                Text("\(userData.email)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5) // Ensures text is legible
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
        Button(action: {
            Haptic.light()
            appModel.alertType = .logout
            appModel.showAlert = true
            
        }) {
            Text("Logout")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(onboardingModel.globalSettings.primaryYellowColor)
                .cornerRadius(10)
        }
        .padding(.top, 5)
    }
    
    private var deleteAccountButton: some View {
        Button(action: {
            Haptic.light()
            appModel.alertType = .delete
            appModel.showAlert = true
        }) {
            Text("Delete Account")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
        }
    }
    
    private func logOutUser() {
        // Reset login property and clear onboarding data
        onboardingModel.accessToken = "" // TODO: make it so accessToken isnt stored here
        onboardingModel.errorMessage = ""
        onboardingModel.isLoggedIn = false
        onboardingModel.onboardingComplete = false
        
        // Reset skiponboarding for when testing with skiponboarding set to true
        onboardingModel.skipOnboarding = false

        // Clear Keychain tokens
        let keychain = KeychainWrapper.standard
        keychain.removeObject(forKey: "accessToken")
        
        // Clear user's cache and data
        sessionModel.clearUserData()
        appModel.cleanupOnLogout()
        
        // Reset to home tab
        appModel.mainTabSelected = 0
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

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Change Password")) {
                    SecureField("Current Password", text: $currentPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                }
            }
            .navigationTitle("Security")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if newPassword == confirmPassword {
                        // TODO: Implement password change logic
                        alertMessage = "Password updated successfully"
                        showAlert = true
                    } else {
                        alertMessage = "New passwords don't match"
                        showAlert = true
                    }
                }
            )
            .alert("Password Update", isPresented: $showAlert) {
                Button("OK") {
                    if newPassword == confirmPassword {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.custom("Poppins-Bold", size: 24))
                    
                    Text("Last updated: May 2025")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    
                    Group {
                        policySection(title: "1. Introduction",
                                      content: "BravoBall (the \"App\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our App.")
                        
                        policySection(title: "2. Information We Collect",
                                      content: "We collect information you provide directly to us, such as your name, email address, and soccer training preferences including your position, experience level, training goals, available equipment, and training schedule. We also collect usage data to improve your training experience and track your progress.")
                        
                        policySection(title: "3. How We Use Your Information",
                                      content: "We use your information to: (a) create personalized training sessions; (b) track your progress and achievements; (c) save your training preferences and history; (d) communicate with you about your training; (e) improve our training programs; and (f) ensure the security of your account.")
                        
                        policySection(title: "4. Sharing Your Information",
                                      content: "We do not sell your personal information. We may share your information with trusted third-party service providers who assist us in operating the App, as required by law, or to protect our rights. All third parties are required to protect your information and use it only for the purposes we specify.")
                        
                        policySection(title: "5. Data Security",
                                      content: "We implement industry-standard security measures to protect your personal information and training data. This includes secure storage of your account credentials, encrypted data transmission, and regular security updates. Your training progress and preferences are stored securely on our servers.")
                        
                        policySection(title: "6. Your Rights",
                                      content: "You may access, update, or delete your personal information at any time by contacting us at conklinofficialsoccer@gmail.com. You may also request that we stop using your information for certain purposes.")
                        
                        policySection(title: "7. Children's Privacy",
                                      content: "BravoBall is designed to be accessible to soccer players of all ages. For users under 13, we recommend parental supervision and guidance. Parents or guardians can contact us at conklinofficialsoccer@gmail.com to manage their child's account and data.")
                        
                        policySection(title: "8. Changes to This Policy",
                                      content: "We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the App. Your continued use of the App after changes are posted constitutes your acceptance of those changes.")
                        
                        policySection(title: "9. Contact Us",
                                      content: "If you have any questions or concerns about this Privacy Policy, please contact us at conklinofficialsoccer@gmail.com.")
                        
                        policySection(title: "10. Data Retention",
                                      content: "We retain your personal information for as long as necessary to provide our services and comply with legal obligations. You can request deletion of your data at any time.")
                        
                        policySection(title: "11. International Data Transfers",
                                      content: "Your information may be transferred to and processed in countries other than your country of residence. We ensure appropriate safeguards are in place to protect your data.")
                        
                        policySection(title: "12. Third-Party Services",
                                      content: "We use the following third-party services in our app:\n\n" +
                                      "• Rive Runtime: For training animations and interactive elements\n" +
                                      "• SwiftKeychainWrapper: For secure storage of your account information\n\n" +
                                      "We also use our own backend services to manage your training data, progress tracking, and personalized training sessions. " +
                                      "All data is processed in accordance with our privacy standards and applicable laws.")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 18))
            Text(content)
                .font(.custom("Poppins-Regular", size: 14))
        }
    }
}

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.custom("Poppins-Bold", size: 24))
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    
                    Group {
                        termsSection(title: "1. Acceptance of Terms",
                                     content: "By accessing or using BravoBall, you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree, please do not use the App.")
                        
                        termsSection(title: "2. Use of the App",
                                     content: "You agree to use the App only for lawful purposes and in accordance with these Terms. You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account.")
                        
                        termsSection(title: "3. User Content",
                                     content: "You retain ownership of your training data, progress, and preferences. You grant us a non-exclusive license to use this information to provide and improve your training experience. This includes your training history, saved drills, and performance metrics.")
                        
                        termsSection(title: "4. Prohibited Conduct",
                                     content: "You agree not to: (a) use the App for any unlawful purpose; (b) attempt to gain unauthorized access to any part of the App; (c) interfere with or disrupt the App or its servers; (d) upload viruses or malicious code; (e) share your account credentials; (f) manipulate training data or progress metrics; or (g) violate any applicable laws or regulations.")
                        
                        termsSection(title: "5. Intellectual Property",
                                     content: "All content, features, and functionality of the App (excluding user content) are the exclusive property of BravoBall and its licensors. You may not copy, modify, or distribute any part of the App without our prior written consent.")
                        
                        termsSection(title: "6. Termination",
                                     content: "We reserve the right to suspend or terminate your access to the App at any time, without notice, for conduct that we believe violates these Terms or is otherwise harmful to other users or the App.")
                        
                        termsSection(title: "7. Disclaimer of Warranties",
                                     content: "The App is provided on an \"as is\" and \"as available\" basis. We make no warranties, express or implied, regarding the App's operation or availability. We do not guarantee that the training programs will achieve specific results, and users should exercise proper judgment and safety precautions while training.")
                        
                        termsSection(title: "8. Limitation of Liability",
                                     content: "To the fullest extent permitted by law, BravoBall and its affiliates shall not be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the App. This includes any injuries or accidents that may occur during training exercises. Users are responsible for their own safety and should consult with healthcare professionals before beginning any training program.")
                        
                        termsSection(title: "9. Changes to Terms",
                                     content: "We may update these Terms of Service from time to time. We will notify you of any material changes by posting the new terms in the App. Your continued use of the App after changes are posted constitutes your acceptance of those changes.")
                        
                        termsSection(title: "10. Governing Law",
                                     content: "These Terms are governed by the laws of the United States and the State of California, without regard to conflict of law principles.")
                        
                        termsSection(title: "11. Contact Us",
                                     content: "If you have any questions about these Terms, please contact us at conklinofficialsoccer@gmail.com.")
                        
                        termsSection(title: "12. Subscription and Payments",
                                     content: "If the App offers subscription services, you agree to pay all fees associated with your subscription. Subscriptions automatically renew unless cancelled.")
                        
                        termsSection(title: "13. Refund Policy",
                                     content: "Refund requests will be considered on a case-by-case basis. Contact us at conklinofficialsoccer@gmail.com for refund inquiries.")
                        
                        termsSection(title: "14. Dispute Resolution",
                                     content: "Any disputes shall be resolved through binding arbitration in accordance with the rules of the American Arbitration Association.")
                        
                        termsSection(title: "15. Training Safety",
                                     content: "You acknowledge that soccer training involves physical activity and potential risks. You agree to: (a) consult with a healthcare professional before beginning any training program; (b) use proper equipment and follow safety guidelines; (c) stop training if you experience pain or discomfort; and (d) take responsibility for your own safety during training sessions.")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 18))
            Text(content)
                .font(.custom("Poppins-Regular", size: 14))
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
            email: "jordan@example.com",
            firstName: "Jordan",
            lastName: "Conklin"
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
