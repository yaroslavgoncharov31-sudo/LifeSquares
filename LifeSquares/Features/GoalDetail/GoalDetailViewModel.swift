import Foundation
import TimeCore
import SwiftData
import LifeSquaresKit
import WidgetKit
import os

extension GoalDetailView {
    @MainActor
    @Observable
    final class ViewModel {
        let goal: Goal
        private let calendar: Calendar
        private let now: () -> Date

        private(set) var snapshot: GoalSnapshot
        private(set) var cells: [DayCellModel]
        var isGridExpanded: Bool = true
        var goalRange: ClosedRange<Date>? {
            guard goal.startDay <= goal.endDay else { return nil }
            return goal.startDay...goal.endDay
        }
        var milestones: [Milestone] {
            (goal.milestones ?? []).sorted { $0.targetDay < $1.targetDay }
        }
        var isReadOnly: Bool { snapshot.timeline.isFinished }
        

        init(goal: Goal, calendar: Calendar, now: @escaping () -> Date = Date.init) {
            self.goal = goal
            self.calendar = calendar
            self.now = now
            let snapshot = goal.snapshot(now: now(), calendar: calendar)
            self.snapshot = snapshot
            self.cells = Self.makeCells(from: snapshot)
        }
        func toggle(_ milestone: Milestone) throws {
            switch milestone.status {
            case .open:
                milestone.status = .closed
                milestone.closedAt = now()
            case .closed:
                milestone.status = .open
                milestone.closedAt = nil
            }
            defer { refresh() }
            do {
                try milestone.modelContext?.save()
            } catch {
                Logger.persistence.error("Failed to toggle: \(error.localizedDescription, privacy: .public)")
                throw error
            }
        }

        func refresh() {
            snapshot = goal.snapshot(now: now(), calendar: calendar)
            cells = Self.makeCells(from: snapshot)
        }
        func deleteGoal() throws {
            let context = goal.modelContext
            context?.delete(goal)
            do {
                try context?.save()
            } catch {
                Logger.persistence.warning("Failed to delete goal: \(error.localizedDescription, privacy: .public)")
                throw error
            }
        }
        private static func makeCells(from snapshot: GoalSnapshot) -> [DayCellModel] {
            (0..<snapshot.timeline.totalDays).compactMap {
                DayCellModel.make(index: $0, snapshot: snapshot)
            }
        }
        func subtitle(for m: Milestone) -> String {
            var parts = ["Day \(snapshot.timeline.index(of: m.targetDay) ?? 0)", m.targetDay.formatted(date: .abbreviated, time: .omitted)]
            if let closedAt = m.closedAt {
                parts.append("closed \(closedAt.formatted(date: .abbreviated, time: .omitted))")
            }
            return parts.joined(separator: " · ")
        }
    }
}
