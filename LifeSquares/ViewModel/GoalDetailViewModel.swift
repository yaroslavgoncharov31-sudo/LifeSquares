import Foundation
import TimeCore
import SwiftData

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
        var visibleCells: [DayCellModel] {
            guard !isGridExpanded else { return cells }
            let columns = 10
            let todayRow = (snapshot.todayIndex ?? snapshot.timeline.elapsedDays) / columns
            let firstRow = max(0, todayRow - 1)
            let start = firstRow * columns
            let end = min(cells.count, start + columns * 3)
            guard start < end else { return cells }
            return Array(cells[start..<end])
        }
        var milestones: [Milestone] {
            (goal.milestones ?? []).sorted { $0.targetDay < $1.targetDay }
        }
        var milestoneLabelText: String? {
            if snapshot.progress.total == 0 {
                return nil
            } else {
                return "Milestones closed"
            }
        }
        var workingDayText: String { "\(snapshot.availability.remainingAvailable)/\(snapshot.availability.totalAvailable)" }

        var gridAccessibilityText: String {
            let t = snapshot.timeline
            if let days = t.daysUntilStart { return "Starting in \(days) days"}
            return "Total days \(t.totalDays), passed \(min(t.elapsedDays + 1, t.totalDays))"
        }
        var forecastValue: String {
            switch snapshot.forecast {
            case .notEnoughData:
                "-"
            case .completed:
                "✓"
            case .projected(let days):
                "~\(days)"
            }
        }
        var forecastLabel: String {
            switch snapshot.forecast {
            case .notEnoughData:
                "not enough data"
            case .completed:
                "all milestones closed"
            case .projected:
                "needed at this pace"
            }
        }

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
            try milestone.modelContext?.save()
        }

        func refresh() {
            snapshot = goal.snapshot(now: now(), calendar: calendar)
            cells = Self.makeCells(from: snapshot)
        }
        func deleteGoal() throws {
            let context = goal.modelContext
            context?.delete(goal)
            try context?.save()
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
