import SwiftUI

struct SelectableGlassCard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .frame(width: 52, height: 52)
                    .glassEffect(
                        isSelected ? .regular.tint(.accentColor).interactive() : .regular.interactive(),
                        in: .circle
                    )

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .glassEffect(
                isSelected ? .regular.tint(.accentColor.opacity(0.18)) : .regular,
                in: .rect(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
            }
            .scaleEffect(isSelected ? 1.03 : 1)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    GlassEffectContainer {
        HStack(spacing: 16) {
            SelectableGlassCard(icon: "figure.walk", title: "Andar", isSelected: false) {}
            SelectableGlassCard(icon: "figure.run", title: "Correr", isSelected: true) {}
            SelectableGlassCard(icon: "bicycle", title: "Bici", isSelected: false) {}
        }
        .padding()
    }
    .background(.gray.opacity(0.2))
}
