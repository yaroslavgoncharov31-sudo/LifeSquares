import SwiftUI

struct CharacterLimit: ViewModifier {
    @Binding var text: String
    let limit: Int

    func body(content: Content) -> some View {
        HStack {
            content
                .onChange(of: text) { _, new in
                    if new.count > limit { text = String(new.prefix(limit)) }
                }
            if text.count > limit - 10 {
                Text("\(text.count)/\(limit)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

extension View {
    func characterLimit(_ limit: Int, text: Binding<String>) -> some View {
        modifier(CharacterLimit(text: text, limit: limit))
    }
}
