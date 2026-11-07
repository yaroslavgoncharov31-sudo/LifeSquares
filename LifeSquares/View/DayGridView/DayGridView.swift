import SwiftUI
import TimeCore

struct DayGridView: View {
    let cells: [DayCellModel]
    let color: GoalColor
    let accessibilityText: String
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 10)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(cells) { DayCell(cell: $0, color: color) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }
}
