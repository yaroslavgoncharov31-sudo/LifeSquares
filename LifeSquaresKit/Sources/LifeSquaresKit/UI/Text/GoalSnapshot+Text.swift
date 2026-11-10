import Foundation
public import TimeCore

public extension GoalSnapshot {
    var dayText: String {
        let t = timeline
        let passed = min(t.elapsedDays + 1, t.totalDays)
        if let days = t.daysUntilStart { return "Starting in \(days) days"}
        return  "\(passed)/\(t.totalDays)"
    }
    var milestoneText: String {
        guard progress.total > 0 else { return "No milestones" }
        return "\(progress.closed)/\(progress.total)"
    }
    var todayIndex: Int? { timeline.index(of: timeline.today) }
    var gridAccessibilityText: String {
        let t = timeline
        if let days = t.daysUntilStart { return "Starting in \(days) days"}
        return "Total days \(t.totalDays), passed \(min(t.elapsedDays + 1, t.totalDays))"
    }
}
