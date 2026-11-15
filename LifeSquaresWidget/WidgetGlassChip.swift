import SwiftUI
import WidgetKit

struct WidgetGlassChip: ViewModifier {
    @Environment(\.widgetRenderingMode) var mode

    func body(content: Content) -> some View {
        if mode == .fullColor {
            content
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.primary.opacity(0.08), in: .rect(cornerRadius: 10, style: .continuous))
        } else {
            content
        }
    }
}

extension View {
    func widgetGlassChip() -> some View { modifier(WidgetGlassChip()) }
}
