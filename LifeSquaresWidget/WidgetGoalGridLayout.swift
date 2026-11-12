import SwiftUI
import Foundation
import TimeCore
import LifeSquaresKit

struct GoalGridLayout: View {
    let color: GoalColor
    let snapshot: GoalSnapshot
    let columnCount: Int

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount), spacing: 2) {
            ForEach(snapshot.windowCells()) {
                DayCell(cell: $0, color: color)
            }
        }
    }
}
