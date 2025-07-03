//
//  BravoSecureField.swift
//  BravoBall
//
//  Created by Jordan on 6/8/25.
//

import SwiftUI

struct BravoSecureField: View {
    var placeholder: String
    @Binding var text: String
    var font: Font = .custom("Poppins-Regular", size: 16)
    var backgroundColor: Color = Color.gray.opacity(0.08)
    var borderColor: Color = Color.yellow.opacity(0.3)
    var cornerRadius: CGFloat = 14
    
    @State private var isVisible: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isVisible {
                TextField(placeholder, text: $text)
                    .font(font)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                SecureField(placeholder, text: $text)
                    .font(font)
            }
            Button(action: { isVisible.toggle() }) {
                Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(.yellow)
            }
            .padding(.trailing, 10)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(borderColor, lineWidth: 1))
    }
}

#if DEBUG
struct BravoSecureField_Previews: PreviewProvider {
    static var previews: some View {
        BravoSecureField(placeholder: "Password", text: .constant(""))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif 
