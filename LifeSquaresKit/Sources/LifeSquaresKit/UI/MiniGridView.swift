import TimeCore
public import SwiftUI

public struct MiniGridView: View {
    public init(totalDays: Int, elapsedDays: Int, todayIndex: Int?, color: GoalColor) {
        self.totalDays = totalDays
        self.elapsedDays = elapsedDays
        self.todayIndex = todayIndex
        self.color = color
    }
    public let totalDays: Int
    public let elapsedDays: Int
    public let todayIndex: Int?
    public let color: GoalColor

    private let spacing: CGFloat = 1.5

    public var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            let layout = MiniGridLayout.make(totalDays: totalDays, side: side, spacing: spacing)
            let fill = color.color

            for index in 0..<totalDays {
                let row = index / layout.columns
                let col = index % layout.columns
                let rect = CGRect(
                    x: CGFloat(col) * (layout.cellSize + spacing),
                    y: CGFloat(row) * (layout.cellSize + spacing),
                    width: layout.cellSize,
                    height: layout.cellSize
                )
                let path = Path(roundedRect: rect, cornerRadius: layout.cellSize * 0.2)

                if index == todayIndex {
                    context.stroke(path, with: .color(.primary), lineWidth: 1)
                } else if index < elapsedDays {
                    context.fill(path, with: .color(fill))
                } else {
                    context.stroke(path, with: .color(fill.opacity(0.35)), lineWidth: 0.5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel(String(localized: "\(elapsedDays) of \(totalDays) days passed", bundle: .module))
    }
}

#Preview {
    MiniGridView(totalDays: 42, elapsedDays: 45, todayIndex: 60, color: .magenta)
}
