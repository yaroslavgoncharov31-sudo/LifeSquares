import SwiftUI

struct DemoGlow: ViewModifier {
    let isActive: Bool
    func body(content: Content) -> some View {
            content
                .overlay {
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(.blue, lineWidth: 20)
                        .blur(radius: 15)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .opacity(isActive ? 0.7 : 0)
                }
                .animation(.easeInOut(duration: 0.3), value: isActive)

    }
}

extension View {
    func demoGlow(isActive: Bool) -> some View {
        modifier(DemoGlow(isActive: isActive))
    }
}

#Preview {
    RootView()
}
