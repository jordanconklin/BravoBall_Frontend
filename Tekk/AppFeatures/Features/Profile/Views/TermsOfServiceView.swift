//
//  TermsOfServiceView.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//
import SwiftUI

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
                                     content: "If you have any questions about these Terms, please contact us at team@conklinofficial.com.")
                        
                        termsSection(title: "12. Subscription and Payments",
                                     content: "If the App offers subscription services, you agree to pay all fees associated with your subscription. Subscriptions automatically renew unless cancelled.")
                        
                        termsSection(title: "13. Refund Policy",
                                     content: "Refund requests will be considered on a case-by-case basis. Contact us at team@conklinofficial.com for refund inquiries.")
                        
                        termsSection(title: "14. Dispute Resolution",
                                     content: "Any disputes shall be resolved through binding arbitration in accordance with the rules of the American Arbitration Association.")
                        
                        termsSection(title: "15. Training Safety",
                                     content: "You acknowledge that soccer training involves physical activity and potential risks. You agree to: (a) consult with a healthcare professional before beginning any training program; (b) use proper equipment and follow safety guidelines; (c) stop training if you experience pain or discomfort; and (d) take responsibility for your own safety during training sessions.")
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
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 18))
            Text(content)
                .font(.custom("Poppins-Regular", size: 14))
        }
    }
}
