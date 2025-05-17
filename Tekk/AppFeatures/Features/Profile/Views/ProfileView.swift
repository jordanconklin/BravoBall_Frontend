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
                        customActionButton(title: "Notification Settings", icon: "bell.fill"),
                        customActionButton(title: "Share With a Friend", icon: "square.and.arrow.up.fill")
                    ])
                    
                    actionSection(title: "Support", buttons: [
                        customActionButton(title: "Report an Error", icon: "exclamationmark.bubble.fill"),
                        customActionButton(title: "Privacy Policy", icon: "doc.text.fill"),
                        customActionButton(title: "Terms of Service", icon: "doc.fill"),
                        customActionButton(title: "Follow our Socials", icon: "link")
                    ])
                    
                    // App Version Info
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                    
                    logoutButton
                        .padding(.top, 30)
                        .padding(.horizontal)
                    deleteAccountButton
                        .padding(.horizontal)
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
        .padding()
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
    
    // Custom action button
    private func customActionButton(title: String, icon: String) -> AnyView {
        AnyView(
            // Button action
            Button(action: {
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
        case "Notification Settings":
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case "Follow our Socials":
            showSocialLinks()
        case "Share With a Friend":
            shareApp()
        case "Report an Error":
            sendEmail(subject: "BravoBall Error Report", to: "conklinofficialsoccer@gmail.com")
        case "Talk to a Founder":
            sendEmail(subject: "BravoBall Inquiry", to: "conklinofficialsoccer@gmail.com")
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
        .padding(.top, 20)
    }
    
    private var deleteAccountButton: some View {
        Button(action: {
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
        .padding(.top, 20)
    }
    
    private func logOutUser() {
        // Reset login property
        onboardingModel.authToken = "" // TODO: make it so authToken isnt stored here
        onboardingModel.errorMessage = ""
        onboardingModel.isLoggedIn = false
        
        // Clear Keychain tokens
        let keychain = KeychainWrapper.standard
        keychain.removeObject(forKey: "authToken")
        
        // Clear user's cache and data
        sessionModel.clearUserData()
        appModel.cleanupOnLogout()
        
        // Reset to home tab
        appModel.mainTabSelected = 0
    }
    
    
    
    private func deleteAccount() {
        // Create URL for the delete endpoint
        guard let url = URL(string: "http://127.0.0.1:8000/delete-account/") else {
            print("❌ Invalid URL")
            return
        }
        
        // Get the access token from Keychain storage
        guard let authToken = KeychainWrapper.standard.string(forKey: "authToken") else {
            print("❌ No access token found")
            return
        }
        
        // set DELETE method w/ access token stored in the request's value
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        // debug to make sure token is created
        print("\n🔍 Request Details:")
        print("URL: \(url)")
        print("Method: \(request.httpMethod ?? "")")
        
        print("headers:")
        // ?
        request.allHTTPHeaderFields?.forEach { key, value in
                print("\(key): \(value)")
            }
        
        
        // Make the network request to the backend with the created "request"
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error deleting account: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    return
                }
                
                // Debug print the response
                print("📥 Backend response status: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
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
                    print("❌ Failed to delete account: \(httpResponse.statusCode)")
                    // You might want to show an error message to the user here
                }
            }
        }.resume()
    }
    
    
    
    
}

// Preview code
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        let mockOnboardModel = OnboardingModel()
//        let mockAppModel = MainAppModel()
//        let mockUserManager = UserManager()
//                
//        // Create a User instance first
//        mockUserManager.updateUserKeychain(
//            email: "jordinhoconk@gmail.com",
//            firstName: "Jordan",
//            lastName: "Conklin"
//        )
//        
//        return Group {
//            ProfileView(onboardingModel: mockOnboardModel, appModel: mockAppModel, userManager: mockUserManager, sessionModel: SessionGeneratorModel())
//                .previewDisplayName("Light Mode")
//            
//            ProfileView(onboardingModel: mockOnboardModel, appModel: mockAppModel, userManager: mockUserManager, sessionModel: SessionGeneratorModel())
//                .preferredColorScheme(.dark)
//                .previewDisplayName("Dark Mode")
//        }
//    }
//}

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
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    
                    Group {
                        policySection(title: "Information We Collect",
                                    content: "We collect information that you provide directly to us, including name, email address, and training preferences.")
                        
                        policySection(title: "How We Use Your Information",
                                    content: "We use the information we collect to provide and improve our services, communicate with you, and personalize your training experience.")
                        
                        policySection(title: "Data Security",
                                    content: "We implement appropriate security measures to protect your personal information.")
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
                        termsSection(title: "Agreement to Terms",
                                   content: "By accessing or using BravoBall, you agree to be bound by these Terms.")
                        
                        termsSection(title: "User Responsibilities",
                                   content: "You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account.")
                        
                        termsSection(title: "Acceptable Use",
                                   content: "You agree to use the app only for lawful purposes and in accordance with these Terms of Service.")
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
