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

        var dayText: String {
            let t = snapshot.timeline
            let passed = min(t.elapsedDays + 1, t.totalDays)
            if let days = t.daysUntilStart { return "Starting in \(days) days"}
            return  "\(passed)/\(t.totalDays)"
        }
        var milestoneText: String {
            guard snapshot.progress.total > 0 else { return "No milestones" }
            return "\(snapshot.progress.closed)/\(snapshot.progress.total)"
        }
        var workingDayText: String { "\(snapshot.availability.remainingAvailable)/\(snapshot.availability.totalAvailable)" }
        var gridAccessibilityText: String {
            let t = snapshot.timeline
            if let days = t.daysUntilStart { return "Starting in \(days) days"}
            return "Total days \(t.totalDays), passed \(min(t.elapsedDays + 1, t.totalDays))"
        }
        var forecastText: String {
            switch snapshot.forecast {
            case .notEnoughData:
                "Not enough data for forecast yet"
            case .completed:
                "You have closed all milestones"
            case .projected(let workingDaysNeeded):
                "At current pace: ~\(workingDaysNeeded) working days for remaining milestones, \(snapshot.availability.remainingAvailable) left"
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
        private static func makeCells(from snapshot: GoalSnapshot) -> [DayCellModel] {
            (0..<snapshot.timeline.totalDays).compactMap {
                DayCellModel.make(index: $0, snapshot: snapshot)
            }
        }
    }
}
