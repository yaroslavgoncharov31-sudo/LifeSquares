import SwiftUI

struct GlassChip: ViewModifier {
    var useGlass: Bool
    func body(content: Content) -> some View {
        let padded = content.padding(.horizontal, 10).padding(.vertical, 6)
        if useGlass, #available(iOS 26, *) {
            padded.glassEffect(in: .rect(cornerRadius: 10))
        } else {
            padded.background(.ultraThinMaterial, in: .rect(cornerRadius: 10, style: .continuous))
        }
    }
}
extension View {
    func glassChip(useGlass: Bool = true) -> some View {
        modifier(GlassChip(useGlass: useGlass))
    }
}
