import Foundation
public import TimeCore

public extension GoalSnapshot {
    var passedDays: Int { timeline.elapsedDays }
    var dayText: String {
        if let days = timeline.daysUntilStart { return "Starting in \(days) days" }
        return "\(passedDays)/\(timeline.totalDays)"
    }
    var compactDayText: String {
        if let days = timeline.daysUntilStart { return "in \(days)d" }
        return "\(passedDays)/\(timeline.totalDays)"
    }
    var milestoneText: String {
        guard progress.total > 0 else { return "No milestones" }
        return "\(progress.closed)/\(progress.total)"
    }
    var todayIndex: Int? { timeline.index(of: timeline.today) }
    var gridAccessibilityText: String {
        let t = timeline
        if let days = t.daysUntilStart { return "Starting in \(days) days"}
        return "Total days \(t.totalDays), passed \(passedDays)"
    }
    var compactMilestoneText: String? {
        guard progress.total > 0 else { return nil }
        return "\(progress.closed)/\(progress.total)"
    }
}
