import SwiftUI

struct PrimaryButton: View {
    enum Style {
        case filled
        case outlined
    }
    
    var title: String
    var action: () -> Void
    var backgroundColor: Color = Color.accentColor
    var textColor: Color = .white
    var font: Font = .system(size: 16, weight: .semibold)
    var style: Style = .filled
    var cornerRadius: CGFloat = 20
    var height: CGFloat = 50
    var borderColor: Color = Color.accentColor
    var borderWidth: CGFloat = 2
    var disabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundColor(style == .filled ? textColor : backgroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    Group {
                        if style == .filled {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(backgroundColor)
                        } else {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(borderColor, lineWidth: borderWidth)
                        }
                    }
                )
        }
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1.0)
    }
}

// Preview
struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Filled Button", action: {})
            PrimaryButton(title: "Outlined Button", action: {}, backgroundColor: .blue, style: .outlined)
            PrimaryButton(title: "Disabled", action: {}, disabled: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
    }
} 