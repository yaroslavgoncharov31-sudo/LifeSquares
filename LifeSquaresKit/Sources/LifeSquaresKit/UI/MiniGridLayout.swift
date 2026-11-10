import TimeCore
public import Foundation

public struct MiniGridLayout: Equatable {
    let columns: Int
    let cellSize: CGFloat

    public static func make(totalDays: Int, side: CGFloat, spacing: CGFloat) -> MiniGridLayout {
        let columns = max(1, Int(ceil(sqrt(Double(totalDays)))))
        let cell = (side - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        return MiniGridLayout(columns: columns, cellSize: cell)
    }
}
