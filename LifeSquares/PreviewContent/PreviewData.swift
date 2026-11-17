#if DEBUG
import SwiftUI
import SwiftData
import TimeCore
import LifeSquaresKit

// MARK: - Factory

@MainActor
enum GoalPreviewFactory {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Warsaw")!
        calendar.firstWeekday = 2
        return calendar
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 10))!
    }

    /// Этап: номер дня цели (1 = день старта) и закрыт ли он.
    struct MilestoneSpec {
        let title: String
        let day: Int
        let closed: Bool
    }

    static func container() -> ModelContainer {
        try! ModelContainer(
            for: Goal.self, Milestone.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    /// Цель на `days` дней от `start`, вставленная в контекст вместе с этапами.
    static func makeGoal(
        in context: ModelContext,
        title: String,
        start: Date,
        days: Int,
        color: GoalColor,
        offWeekdays: OffWeekdays = [],
        offDays: [Date] = [],
        milestones: [MilestoneSpec] = []
    ) -> Goal {
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

    // Этапы как в макете «Английский»: 4 из 6 закрыты.
    static let englishMilestones: [MilestoneSpec] = [
        .init(title: "Выбрать курс", day: 7, closed: true),
        .init(title: "Освоить базовые слова", day: 14, closed: true),
        .init(title: "Пройти первый модуль", day: 28, closed: true),
        .init(title: "Первый разговор", day: 42, closed: true),
        .init(title: "Книга без перевода", day: 90, closed: false),
        .init(title: "Итоговый тест", day: 180, closed: false),
    ]
}

#endif
