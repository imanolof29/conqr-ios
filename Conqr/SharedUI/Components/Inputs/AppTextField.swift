import SwiftUI

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
            }
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
        }
        .glassFieldStyle()
    }
}

#Preview {
    VStack(spacing: 16) {
        AppTextField(placeholder: "Email", text: .constant(""), icon: "envelope")
        AppTextField(placeholder: "Password", text: .constant(""), icon: "lock", isSecure: true)
    }
    .padding()
    .background(.gray.opacity(0.2))
}
