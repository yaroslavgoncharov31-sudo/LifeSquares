import Foundation
public import TimeCore

public struct DayCellModel: Identifiable, Equatable {
    public init(id: Int, state: CellState, isAvailable: Bool, hasMilestone: Bool) {
        self.id = id
        self.state = state
        self.isAvailable = isAvailable
        self.hasMilestone = hasMilestone
    }
    public let id: Int
    public let state: CellState
    public let isAvailable: Bool
    public let hasMilestone: Bool

    public static func make(index: Int, snapshot: GoalSnapshot) -> DayCellModel? {
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
