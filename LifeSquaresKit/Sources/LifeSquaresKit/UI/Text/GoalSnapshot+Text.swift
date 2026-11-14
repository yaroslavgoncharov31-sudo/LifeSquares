import Foundation
public import TimeCore

public extension GoalSnapshot {
    var passedDays: Int { timeline.elapsedDays }
    var dayText: String {
        if let days = timeline.daysUntilStart { return String(localized: "Starting in \(days) days", bundle: .module) }
        return "\(passedDays)/\(timeline.totalDays)"
    }
    var compactDayText: String {
        if let days = timeline.daysUntilStart { return String(localized: "in \(days)d", bundle: .module) }
        return "\(passedDays)/\(timeline.totalDays)"
    }
    var milestoneText: String {
        guard progress.total > 0 else { return String(localized: "No milestones", bundle: .module) }
        return "\(progress.closed)/\(progress.total)"
    }
    var todayIndex: Int? { timeline.index(of: timeline.today) }
    var gridAccessibilityText: String {
        let t = timeline
        if let days = t.daysUntilStart { return String(localized: "Starting in \(days) days", bundle: .module)}
        return String(localized: "Total days \(t.totalDays), passed \(passedDays)", bundle: .module)
    }
    var compactMilestoneText: String? {
        guard progress.total > 0 else { return nil }
        return "\(progress.closed)/\(progress.total)"
    }
    var milestoneLabelText: String {
        guard progress.total != 0 else { return "" }
        return String(localized: "Milestones closed", bundle: .module)
    }
    var workingDayText: String { "\(availability.remainingAvailable)/\(availability.totalAvailable)" }
}
