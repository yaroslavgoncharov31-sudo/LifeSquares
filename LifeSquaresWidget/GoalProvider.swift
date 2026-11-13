import LifeSquaresKit
import TimeCore
import WidgetKit
import Foundation
import SwiftData
import os

struct GoalProvider: AppIntentTimelineProvider {
    typealias Entry = GoalEntry
    typealias Intent = SelectGoalIntent

    func placeholder(in context: Context) -> GoalEntry {
        GoalEntry.makeSample()
    }

    func snapshot(for configuration: SelectGoalIntent, in context: Context) async -> GoalEntry {
        if context.isPreview { return GoalEntry.makeSample() }
        return makeEntries(goalID: configuration.goal?.id ,from: .now, days: 1).first ?? GoalEntry.makeSample()
    }

    func timeline(for configuration: SelectGoalIntent, in context: Context) async -> Timeline<GoalEntry> {
        let entries = makeEntries(goalID: configuration.goal?.id, from: .now, days: 7)
        let hasGoal = entries.contains { if case .goal = $0.content { true } else { false } }
        return Timeline(entries: entries, policy: hasGoal ? .atEnd : .never)
    }

    private func makeEntries(goalID: UUID?, from now: Date, days: Int) -> [GoalEntry] {
        let calendar: Calendar = Calendar.autoupdatingCurrent
        let today: Date = calendar.startOfDay(for: now)

        let modelContext = ModelContext(SharedModelContainer.shared)
        var descriptor: FetchDescriptor<Goal>
        if let goalID {
            descriptor = FetchDescriptor<Goal>(predicate: #Predicate{ $0.id == goalID } )
        } else {
            var d = FetchDescriptor<Goal>(predicate: #Predicate{ $0.endDay >= today }, sortBy: [SortDescriptor(\.startDay)] )
            d.fetchLimit = 1
            descriptor = d
        }

        let goals: [Goal]
        do {
            goals = try modelContext.fetch(descriptor)
        } catch {
            Logger.widget.error("Failed to fetch goal: \(error.localizedDescription, privacy: .public)")
            return [GoalEntry(date: .now, content: .noGoal)]
        }
        guard let goal = goals.first else {
            Logger.widget.info("No goal found (selected ID: \((goalID?.uuidString ?? "none"), privacy: .public))")
            return [GoalEntry(date: .now, content: .noGoal)]
        }
        return (0..<days).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }
            let date = offset == 0 ? now : day
            return GoalEntry(date: date, content: .goal(
                title: goal.title,
                color: goal.color,
                snapshot: goal.snapshot(now: date, calendar: calendar)))
        }
    }

}
