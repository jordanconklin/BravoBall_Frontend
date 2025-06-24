//
//  PrivacyPolicyView.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//
import SwiftUI

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
            .navigationBarItems(trailing: Button("Done") {
                Haptic.light()
                dismiss()
            })
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
