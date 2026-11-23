import TimeCore
import Foundation
import SwiftData
import LifeSquaresKit

@MainActor
enum DemoGoalFactory {
    static let calendar: Calendar = Calendar.autoupdatingCurrent

    struct MilestoneSpec {
        let title: String
        let day: Int
        let closed: Bool
    }

    static func container(now: Date = .now, calendar: Calendar = .autoupdatingCurrent) -> ModelContainer {
        let container = SharedModelContainer.make(inMemory: true)
        seed(into: container.mainContext, now: now, calendar: calendar)
        return container
    }

    static func seed(into context: ModelContext, now: Date, calendar: Calendar) {
        _ = makeGoal(in: context, calendar: calendar, title: "Pass Final Exams", currentDay: 45, days: 60, now: now, color: .red, milestones: examsMilestones)
        _ = makeGoal(in: context, calendar: calendar, title: "Learn to Play Guitar", currentDay: 50, days: 120, now: now, color: .magenta, milestones: guitarMilestones)
        _ = makeGoal(in: context, calendar: calendar, title: "5 km Run", currentDay: 39, days: 42, now: now, color: .green, milestones: runMilestones)
        _ = makeGoal(in: context, calendar: calendar, title: "Launch a side project", currentDay: -3, days: 90, now: now, color: .blue, milestones: sideProjectMilestones)
    }

    static func makeGoal(
        in context: ModelContext,
        calendar: Calendar,
        title: String,
        currentDay: Int,
        days: Int,
        now: Date,
        color: GoalColor,
        offWeekdays: OffWeekdays = [],
        offDays: [Date] = [],
        milestones: [MilestoneSpec] = []
    ) -> Goal {
        let today = calendar.startOfDay(for: now)
        let start = calendar.date(byAdding: .day, value: 1 - currentDay, to: today)!
        let end = calendar.date(byAdding: .day, value: days - 1, to: start)!
        let goal = Goal(
            title: title, startDay: start, endDay: end, color: color,
            offWeekdays: offWeekdays, offDays: offDays, calendar: calendar
        )
        context.insert(goal)

        for spec in milestones {
            let target = calendar.date(byAdding: .day, value: spec.day - 1, to: start)!
            let milestone = Milestone(title: spec.title, targetDay: target)
            context.insert(milestone)
            milestone.goal = goal
            if spec.closed {
                milestone.status = .closed
                milestone.closedAt = target
            }
        }
        return goal
    }

    // days: 120, currentDay: 50 — середина пути
    static let guitarMilestones: [MilestoneSpec] = [
        .init(title: "Learn basic chords", day: 10, closed: true),
        .init(title: "Switch chords smoothly", day: 21, closed: true),
        .init(title: "Play first full song", day: 35, closed: true),
        .init(title: "Keep tempo at 80 bpm", day: 60, closed: false),
        .init(title: "Learn barre chords", day: 90, closed: false),
        .init(title: "Play a song for friends", day: 120, closed: false),
    ]

    // days: 60, currentDay: 45 — финишная прямая
    static let examsMilestones: [MilestoneSpec] = [
        .init(title: "Make a study schedule", day: 3, closed: true),
        .init(title: "Finish math review", day: 20, closed: true),
        .init(title: "Finish physics review", day: 35, closed: true),
        .init(title: "Complete practice tests", day: 50, closed: false),
        .init(title: "Sit the final exams", day: 60, closed: false),
    ]

    // days: 90, currentDay: 0 будущее
    static let sideProjectMilestones: [MilestoneSpec] = [
        .init(title: "Pick an idea", day: 5, closed: false),
        .init(title: "Design main screens", day: 14, closed: false),
        .init(title: "Build the MVP", day: 45, closed: false),
        .init(title: "Beta test with friends", day: 70, closed: false),
        .init(title: "Ship it", day: 90, closed: false),
    ]

    // days: 42, currentDay: 43 — завершена вчера, все этапы закрыты
    static let runMilestones: [MilestoneSpec] = [
        .init(title: "Run 1 km without stopping", day: 7, closed: true),
        .init(title: "Run 2 km", day: 14, closed: true),
        .init(title: "Run 3 km", day: 24, closed: true),
        .init(title: "Run 5 km", day: 42, closed: false),
    ]
}
