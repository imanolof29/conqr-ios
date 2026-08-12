import SwiftUI

struct GlassFieldStyle: ViewModifier {
    var shape: AnyShape = AnyShape(RoundedRectangle(cornerRadius: 14))

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(.regular, in: shape)
    }
}

extension View {
    func glassFieldStyle(shape: some Shape = RoundedRectangle(cornerRadius: 14)) -> some View {
        modifier(GlassFieldStyle(shape: AnyShape(shape)))
    }
}
