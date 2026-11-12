import TimeCore
import Foundation

public enum GridWindow {
    public static let size = 30
    public static let daysBeforeToday = 9
}

public extension GoalSnapshot {
    func windowCells(size: Int = GridWindow.size, daysBeforeToday: Int = GridWindow.daysBeforeToday) -> [DayCellModel] {
        timeline.visibleRange(size: size, daysBeforeToday: daysBeforeToday).compactMap { DayCellModel.make(index: $0, snapshot: self) }
    }
}
