//
//  BravoTextField.swift
//  BravoBall
//
//  Created by Jordan on 6/8/25.
//

import SwiftUI

struct BravoTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var icon: Image? = nil
    var isSecure: Bool = false
    var font: Font = .custom("Poppins-Regular", size: 16)
    var backgroundColor: Color = Color.gray.opacity(0.08)
    var borderColor: Color = Color.yellow.opacity(0.3)
    var cornerRadius: CGFloat = 14
    
    var body: some View {
        HStack {
            if let icon = icon {
                icon
                    .foregroundColor(.gray)
            }
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(font)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .font(font)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(keyboardType)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(borderColor, lineWidth: 1))
    }
}

#if DEBUG
struct BravoTextField_Previews: PreviewProvider {
    static var previews: some View {
        BravoTextField(placeholder: "Email", text: .constant(""), keyboardType: .emailAddress)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif 
