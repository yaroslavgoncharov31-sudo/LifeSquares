import Foundation
import TimeCore

struct DayCellModel: Identifiable, Equatable {
    let id: Int
    let state: CellState
    let isAvailable: Bool
    let hasMilestone: Bool

    static func make(index: Int, snapshot: GoalSnapshot) -> DayCellModel? {
        guard let state = snapshot.timeline.cellState(at: index),
              let isAvailable = snapshot.availability.isAvailable(at: index) else { return nil }

        return DayCellModel(
            id: index,
            state: state,
            isAvailable: isAvailable,
            hasMilestone: snapshot.milestoneDays.contains(index)
        )
    }

}
