#if DEBUG
import SwiftUI
import SwiftData
import TimeCore
import LifeSquaresKit
// MARK: - Host

private struct GoalDetailPreview: View {
    let container: ModelContainer
    let goal: Goal
    let now: Date

    var body: some View {
        NavigationStack {
            GoalDetailView(goal: goal, calendar: DemoGoalFactory.calendar, now: { now })
        }
        .modelContainer(container)
    }
}

// MARK: - Variants
//
//// В процессе: день 45 из 180, 4 из 6 этапов, выходные сб/вс, есть прогноз.
//#Preview("In progress") {
//    let container = DemoGoalFactory.container()
//    let goal = DemoGoalFactory.makeGoal(
//        in: container.mainContext,
//        title: "Английский",
//        start: DemoGoalFactory.date(2026, 8, 31),
//        days: 180,
//        color: .blue,
//        offWeekdays: [.saturday, .sunday],
//        offDays: [DemoGoalFactory.date(2026, 11, 4)],
//        milestones: DemoGoalFactory.englishMilestones
//    )
//    GoalDetailPreview(container: container, goal: goal, now: GoalPreviewFactory.date(2026, 10, 14))
//}
//
//#Preview("In progress · dark") {
//    let container = GoalPreviewFactory.container()
//    let goal = GoalPreviewFactory.makeGoal(
//        in: container.mainContext,
//        title: "Английский",
//        start: GoalPreviewFactory.date(2026, 8, 31),
//        days: 180,
//        color: .blue,
//        offWeekdays: [.saturday, .sunday],
//        milestones: GoalPreviewFactory.englishMilestones
//    )
//    GoalDetailPreview(container: container, goal: goal, now: GoalPreviewFactory.date(2026, 10, 14))
//        .preferredColorScheme(.dark)
//}
//
//// Рано для прогноза: этап закрыт, но прошло меньше 20% рабочих дней.
//#Preview("Not enough data") {
//    let container = GoalPreviewFactory.container()
//    let goal = GoalPreviewFactory.makeGoal(
//        in: container.mainContext,
//        title: "Бег 10 км",
//        start: GoalPreviewFactory.date(2026, 10, 12),
//        days: 90,
//        color: .green,
//        offWeekdays: [.sunday],
//        milestones: [
//            .init(title: "5 км без остановки", day: 3, closed: true),
//            .init(title: "7 км", day: 40, closed: false),
//            .init(title: "10 км", day: 90, closed: false),
//        ]
//    )
//    GoalDetailPreview(container: container, goal: goal, now: GoalPreviewFactory.date(2026, 10, 19))
//}
//
//// Ещё не началась: «Starting in N days», все клетки будущие.
//#Preview("Not started") {
//    let container = GoalPreviewFactory.container()
//    let goal = GoalPreviewFactory.makeGoal(
//        in: container.mainContext,
//        title: "Ранний сон",
//        start: GoalPreviewFactory.date(2026, 11, 1),
//        days: 60,
//        color: .cyan,
//        milestones: [.init(title: "Неделя до 23:00", day: 7, closed: false)]
//    )
//    GoalDetailPreview(container: container, goal: goal, now: GoalPreviewFactory.date(2026, 10, 21))
//}
//
//// Срок вышел, все этапы закрыты.
//#Preview("Finished") {
//    let container = GoalPreviewFactory.container()
//    let goal = GoalPreviewFactory.makeGoal(
//        in: container.mainContext,
//        title: "Основы гитары",
//        start: GoalPreviewFactory.date(2026, 6, 1),
//        days: 90,
//        color: .magenta,
//        offWeekdays: [.saturday, .sunday],
//        milestones: [
//            .init(title: "Аккорды", day: 20, closed: true),
//            .init(title: "Бой", day: 45, closed: true),
//            .init(title: "Первая песня", day: 70, closed: true),
//            .init(title: "Песня целиком", day: 90, closed: true),
//        ]
//    )
//    GoalDetailPreview(container: container, goal: goal, now: GoalPreviewFactory.date(2026, 10, 21))
//}
//
//// Без этапов: «No milestones», прогноза нет.
//#Preview("No milestones") {
//    let container = GoalPreviewFactory.container()
//    let goal = GoalPreviewFactory.makeGoal(
//        in: container.mainContext,
//        title: "Читать чаще",
//        start: GoalPreviewFactory.date(2026, 9, 1),
//        days: 60,
//        color: .violet
//    )
//    GoalDetailPreview(container: container, goal: goal, now: GoalPreviewFactory.date(2026, 10, 21))
//}
//
//// Короткая цель на неделю с выходными: видно косые черты в будущем.
//#Preview("One week") {
//    let container = GoalPreviewFactory.container()
//    let goal = GoalPreviewFactory.makeGoal(
//        in: container.mainContext,
//        title: "Без сахара",
//        start: GoalPreviewFactory.date(2026, 10, 19),
//        days: 7,
//        color: .red,
//        offWeekdays: [.saturday, .sunday],
//        milestones: [.init(title: "Пять дней подряд", day: 5, closed: false)]
//    )
//    GoalDetailPreview(container: container, goal: goal, now: GoalPreviewFactory.date(2026, 10, 21))
//}
#endif
