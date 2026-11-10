import Foundation
import TimeCore

public extension Goal {
    func snapshot(now: Date, calendar: Calendar) -> GoalSnapshot {
        GoalSnapshot(
            start: startDay,
            end: endDay,
            now: now,
            calendar: calendar,
            offWeekdays: OffWeekdays(rawValue: offWeekdaysRaw),
            offDays: offDays,
            milestones: (milestones ?? []).map { MilestoneInput(targetDate: $0.targetDay, status: $0.status) }
        )
    }

}
