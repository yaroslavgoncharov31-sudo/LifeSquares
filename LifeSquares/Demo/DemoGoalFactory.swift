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
        _ = makeGoal(in: context, calendar: calendar, title: String(localized: "Pass Final Exams"), currentDay: 45, days: 60, now: now, color: .red, milestones: examsMilestones)
        _ = makeGoal(in: context, calendar: calendar, title: String(localized: "Learn to Play Guitar"), currentDay: 50, days: 120, now: now, color: .magenta, milestones: guitarMilestones)
        _ = makeGoal(in: context, calendar: calendar, title: String(localized: "5 km Run"), currentDay: 39, days: 42, now: now, color: .green, milestones: runMilestones)
        _ = makeGoal(in: context, calendar: calendar, title: String(localized: "Launch a side project"), currentDay: -3, days: 90, now: now, color: .blue, milestones: sideProjectMilestones)
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
        .init(title: String(localized: "Learn basic chords"), day: 10, closed: true),
        .init(title: String(localized: "Switch chords smoothly"), day: 21, closed: true),
        .init(title: String(localized: "Play first full song"), day: 35, closed: true),
        .init(title: String(localized: "Keep tempo at 80 bpm"), day: 60, closed: false),
        .init(title: String(localized: "Learn barre chords"), day: 90, closed: false),
        .init(title: String(localized: "Play a song for friends"), day: 120, closed: false),
    ]

    // days: 60, currentDay: 45 — финишная прямая
    static let examsMilestones: [MilestoneSpec] = [
        .init(title: String(localized: "Make a study schedule"), day: 3, closed: true),
        .init(title: String(localized: "Finish math review"), day: 20, closed: true),
        .init(title: String(localized: "Finish physics review"), day: 35, closed: true),
        .init(title: String(localized: "Complete practice tests"), day: 50, closed: false),
        .init(title: String(localized: "Sit the final exams"), day: 60, closed: false),
    ]

    // days: 90, currentDay: 0 будущее
    static let sideProjectMilestones: [MilestoneSpec] = [
        .init(title: String(localized: "Pick an idea"), day: 5, closed: false),
        .init(title: String(localized: "Design main screens"), day: 14, closed: false),
        .init(title: String(localized: "Build the MVP"), day: 45, closed: false),
        .init(title: String(localized: "Beta test with friends"), day: 70, closed: false),
        .init(title: String(localized: "Ship it"), day: 90, closed: false),
    ]

    // days: 42, currentDay: 43 — завершена вчера, все этапы закрыты
    static let runMilestones: [MilestoneSpec] = [
        .init(title: String(localized: "Run 1 km without stopping"), day: 7, closed: true),
        .init(title: String(localized: "Run 2 km"), day: 14, closed: true),
        .init(title: String(localized: "Run 3 km"), day: 24, closed: true),
        .init(title: String(localized: "Run 5 km"), day: 42, closed: false),
    ]
}
