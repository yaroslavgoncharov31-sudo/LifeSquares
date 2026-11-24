import SwiftUI

struct DemoExitButton: View {
    let onExitDemo: () -> Void
    var body: some View {
        Button("Exit demo", systemImage: "arrow.uturn.backward") { onExitDemo() }
            .buttonStyle(.glassProminent)
            .padding(.bottom)
    }
}

#Preview {
    DemoExitButton(onExitDemo: {})
}
