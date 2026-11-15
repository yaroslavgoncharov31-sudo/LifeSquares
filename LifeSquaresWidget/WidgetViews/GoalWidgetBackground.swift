import SwiftUI
import TimeCore
import LifeSquaresKit

struct GoalWidgetBackground: View {
    var color: GoalColor
    let startPoint: UnitPoint
    let endPoint: UnitPoint

    var body: some View {
        ZStack {
            Color(.systemBackground)
            LinearGradient(
                stops: [
                    .init(color: color.color.opacity(0.7), location: 0),
                    .init(color: color.color.opacity(0.4), location: 0.3),
                    .init(color: color.color.opacity(0.2), location: 0.5),
                    .init(color: color.color.opacity(0.1), location: 0.8),
                    .init(color: .clear, location: 0.9)
                ],
                startPoint: startPoint,
                endPoint: endPoint)
        }
    }
}

#Preview {
    GoalWidgetBackground(color: .green, startPoint: .topLeading, endPoint: .bottomTrailing)
}
