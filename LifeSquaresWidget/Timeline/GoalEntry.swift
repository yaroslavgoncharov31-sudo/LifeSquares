import WidgetKit
import Foundation
import TimeCore
import LifeSquaresKit

struct GoalEntry: TimelineEntry {
    let date: Date
    let content: Content

    enum Content {
        case noGoal
        case goal(title: String, color: GoalColor, snapshot: GoalSnapshot)
    }
}

extension GoalEntry {
    static func makeSample() -> GoalEntry {
        let calendar = Calendar.current
        return GoalEntry(
            date: calendar.date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 9, minute: 31))!,
            content: .goal(title: "Run 10 km", color: .violet, snapshot:
                            GoalSnapshot(
                                start: calendar.date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 9, minute: 31))!,
                                end: calendar.date(from: DateComponents(year: 2026, month: 12, day: 14, hour: 9, minute: 31))!,
                                now: calendar.date(from: DateComponents(year: 2026, month: 10, day: 31, hour: 9, minute: 31))!,
                                calendar: calendar,
                                offWeekdays: [.saturday,.sunday],
                                offDays: [],
                                milestones: [
                                    MilestoneInput(targetDate: calendar.date(from: DateComponents(year: 2026, month: 10, day: 21, hour: 9, minute: 31)) ?? .now, status: .closed),
                                    MilestoneInput(targetDate: calendar.date(from: DateComponents(year: 2026, month: 10, day: 31, hour: 9, minute: 31)) ?? .now, status: .closed),
                                    MilestoneInput(targetDate: calendar.date(from: DateComponents(year: 2026, month: 11, day: 9, hour: 9, minute: 31)) ?? .now, status: .open)
                                ]
                            )
                          )
        )
    }
}
