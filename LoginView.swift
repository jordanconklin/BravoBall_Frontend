import SwiftUI

struct LoginView: View {
    @StateObject private var globalSettings = GlobalSettings()
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = "" 
    @State private var conversations: [Conversation] = []
    @Binding var isLoggedIn: Bool
    @Binding var accessToken: String
    @Binding var showLoginPage: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    Haptic.light()
                    withAnimation(.spring()) {
                        showLoginPage = false
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(globalSettings.primaryDarkColor)
                        Text("Back")
                            .foregroundColor(globalSettings.primaryDarkColor)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                .padding(.leading)
                
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .medium))
                
                TextField("Enter your email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .frame(height: 44)
                    .padding(.horizontal)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .font(.system(size: 16))
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .medium))
                
                SecureField("Enter your password", text: $password)
                    .textContentType(.password)
                    .frame(height: 44)
                    .padding(.horizontal)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .font(.system(size: 16))
            }
            .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.horizontal)
            }

            Button(action: {
                Haptic.light()
                loginUser()
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(globalSettings.primaryYellowColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal)
            .accessibilityLabel("Login button")

            Button(action: {
                Haptic.light()
            }) {
                Text("Forgot Password")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(globalSettings.primaryDarkColor)
                    .cornerRadius(12)
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal)
            .accessibilityLabel("Forgot password button")

            Spacer()
        }
        .padding(.top)
        .background(Color(UIColor.systemBackground))
    }
    
    // Login function remains the same...
}

struct LoginView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        Group {
            LoginView(
                isLoggedIn: .constant(false),
                accessToken: .constant(""),
                showLoginPage: .constant(true)
            )
            .matchedGeometryEffect(id: "login", in: namespace)
            
            // Add dark mode preview
            LoginView(
                isLoggedIn: .constant(false),
                accessToken: .constant(""),
                showLoginPage: .constant(true)
            )
            .matchedGeometryEffect(id: "login", in: namespace)
            .preferredColorScheme(.dark)
        }
    }
} 