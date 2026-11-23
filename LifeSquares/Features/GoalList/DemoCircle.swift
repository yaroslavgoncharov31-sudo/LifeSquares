import SwiftUI

struct DemoCircle: View {
    @GestureState(resetTransaction: Transaction(animation: .easeOut)) private var dragOffset: CGFloat = .zero
    @State private var hapticTrigger = false
    private var progress: CGFloat {
        let raw = dragOffset / threshold
        return min(max(0, raw), 1)
    }
    private var ringOffset: CGFloat {
        let permissible: CGFloat = max(0, dragOffset)
        return (1 - 1 / (permissible * 0.55 / limit + 1)) * limit
    }
    private var isArmed: Bool { progress >= 1 }
    private let threshold: CGFloat = 200
    private let limit: CGFloat = 150
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 5)
                Image(systemName: "arrow.up")
            }
            .opacity(0.2)
            ZStack {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "arrow.up")
                    .opacity(progress)
            }
            ZStack {
                Circle()
                    .fill()
                Image(systemName: "checkmark")
                    .foregroundStyle(.background)
            }
            .scaleEffect(isArmed ? 1.3 : 0.8)
            .opacity(isArmed ? 1 : 0)
            .animation(.spring(duration: 0.2, bounce: 0.6), value: isArmed)
        }
        .offset(y: -ringOffset)
        .contentShape(Rectangle().inset(by: -100))
        .foregroundStyle(.blue)
        .frame(width: 30, height: 30)
        .gesture (
            DragGesture()
                .updating($dragOffset) { value, state, transaction in
                    state = -value.translation.height
                }
                .onEnded { value in
                    if -value.translation.height >= threshold {
                        hapticTrigger.toggle()
                        onComplete()
                    }

                }
        )
        .sensoryFeedback(.impact(flexibility: .solid), trigger: isArmed)
        .sensoryFeedback(.success, trigger: hapticTrigger)
    }
}


#Preview {
    DemoCircle(onComplete: {})
}
