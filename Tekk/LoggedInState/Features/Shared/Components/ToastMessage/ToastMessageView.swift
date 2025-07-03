//
//  ToastMessageView.swift
//  BravoBall
//
//  Created by Joshua Conklin on 2/20/25.
//
import SwiftUI

// MARK: testing


// Toast view component
struct ToastView: View {
    let message: ToastMessage
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: message.type.icon)
                .foregroundColor(Color.white)
            Text(message.message)
                .font(.custom("Poppins-Medium", size: 18))
                .foregroundColor(Color.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(message.type.color)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(message.type.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// Overlay modifier for toast
struct ToastModifier: ViewModifier {
    @EnvironmentObject var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toastManager.toastMessage {
                VStack {
                    Spacer()
                    ToastView(message: toast)
                        .padding(.bottom, 32)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: toastManager.toastMessage)
    }
}

// Extension for easy usage, displays toastmodifier with toastview
extension View {
    func toastOverlay() -> some View {
        modifier(ToastModifier())
    }
}

#if DEBUG
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ToastView(message: .success("Success! Your action was completed."))
            ToastView(message: .notAllowed("Not allowed. Please try again."))
            ToastView(message: .unAdded("Item was not added."))
            ToastView(message: ToastMessage(type: .error, message: "An error occurred."))
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
#endif
