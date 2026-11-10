import TimeCore
import Foundation
import SwiftData

extension GoalAddView {

    enum ValidationIssue: Equatable {
        case emptyTitle
        case noWorkingDays
        case durationOutOfRange
        case titleTooLong
        case milestoneOutOfRange(MilestoneDraft.ID)
    }

    private struct FormState: Equatable {
        var title: String
        var startDay: Date
        var durationDays: Int
        var color: GoalColor
        var offWeekdays: OffWeekdays
        var offDays: [Date]
        var milestones: [MilestoneKey]
    }

    private struct MilestoneKey: Equatable {
        let title: String
        let dayNumber: Int
    }

    @MainActor
    @Observable
    final class ViewModel {
        private let calendar: Calendar
        private let editingGoal: Goal?
        private let initialState: FormState

        private init(calendar: Calendar, editingGoal: Goal?, title: String, startDay: Date,
                     durationDays: Int, color: GoalColor, offWeekdays: OffWeekdays,
                     offDays: [Date], milestones: [MilestoneDraft]) {
            self.calendar = calendar
            self.editingGoal = editingGoal
            self.title = title
            self.startDay = startDay
            self.durationDays = durationDays
            self.color = color
            self.offWeekdays = offWeekdays
            self.offDays = offDays
            self.milestones = milestones
            self.availability = Self.makeAvailability(calendar: calendar, start: startDay,
                                                      durationDays: durationDays,
                                                      offWeekdays: offWeekdays, offDays: offDays)
            self.initialState = Self.makeState(title: title, startDay: startDay, durationDays: durationDays, color: color, offWeekdays: offWeekdays, offDays: offDays, milestones: milestones)
        }

        convenience init(calendar: Calendar = .autoupdatingCurrent, goal: Goal) {
            let duration = (calendar.dateComponents([.day], from: goal.startDay, to: goal.endDay).day ?? 0) + 1
            let drafts = (goal.milestones ?? [])
                .sorted { ($0.targetDay, $0.title) < ($1.targetDay, $1.title) }
                .map { m in
                    MilestoneDraft(title: m.title,
                                   dayNumber: (calendar.dateComponents([.day], from: goal.startDay, to: m.targetDay).day ?? 0) + 1,
                                   existing: m)
                }
            self.init(calendar: calendar, editingGoal: goal, title: goal.title,
                      startDay: goal.startDay, durationDays: duration, color: goal.color,
                      offWeekdays: goal.offWeekdays, offDays: goal.offDays, milestones: drafts)
        }

        convenience init(calendar: Calendar = .autoupdatingCurrent, now: Date = .now) {
            self.init(calendar: calendar, editingGoal: nil, title: "",
                      startDay: calendar.startOfDay(for: now),
                      durationDays: 30, color: .blue,
                      offWeekdays: [], offDays: [],
                      milestones: [])
        }

        private var currentState: FormState {
            Self.makeState(title: title, startDay: startDay, durationDays: durationDays,
                           color: color, offWeekdays: offWeekdays, offDays: offDays,
                           milestones: milestones)
        }
        var hasChanges: Bool { currentState != initialState }
        var isEditing: Bool { editingGoal != nil }
        private var trimmingTitle: String {
            title.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var orderedWeekdays: [Int] {
            (0..<7).map { i in (calendar.firstWeekday - 1 + i) % 7 + 1 }
        }

        var title: String = ""
        var startDay: Date {
            didSet {
                let normalized = calendar.startOfDay(for: startDay)
                if normalized != startDay { startDay = normalized }
                updateAvailability()
            }
        }
        var durationDays: Int = 30 {
            didSet {
                updateAvailability()
            }
        }
        static let maxDuration = 3650
        var endDay: Date {
            let day = calendar.date(byAdding: .day, value: durationDays - 1, to: startDay)!
            return calendar.startOfDay(for: day)
        }

        var goalRange: ClosedRange<Date>? {
            guard startDay <= endDay else { return nil }
            return startDay...endDay
        }

        var color: GoalColor = .blue
        var milestones: [MilestoneDraft] = []

        var availability: Availability
        var offWeekdays: OffWeekdays = [] { didSet { updateAvailability() } }
        var offDays: [Date] = [] { didSet { updateAvailability() } }

        var validationIssues: [ValidationIssue] {
            var issues: [ValidationIssue] = []
            if durationDays > 3650 || durationDays < 1 {
                issues.append(.durationOutOfRange)
            }
            if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(.emptyTitle)
            }
            if availability.totalAvailable == 0 {
                issues.append(.noWorkingDays)
            }
            if trimmingTitle.count > Goal.maxTitleLength {
                issues.append(.titleTooLong)
            }
            for draft in milestones where draft.dayNumber < 1 || draft.dayNumber > durationDays {
                issues.append(.milestoneOutOfRange(draft.id))
            }
            return issues
        }
        var isValid: Bool { validationIssues.isEmpty }
        static let durationPresets = [30, 90, 180, 365]

        func weekdaySymbol(_ weekday: Int) -> String {
            calendar.veryShortWeekdaySymbols[weekday - 1].capitalized
        }

        func isOff(_ weekday: Int) -> Bool {
            guard let day = OffWeekdays.from(weekday: weekday) else { return false }
            return offWeekdays.contains(day)
        }

        func toggleWeekday(_ weekday: Int) {
            guard let day = OffWeekdays.from(weekday: weekday) else { return }
            offWeekdays.formSymmetricDifference(day)
        }

        func addOffDay(_ date: Date) {
            let day = calendar.startOfDay(for: date)
            guard !offDays.contains(day) else { return }
            offDays.append(day)
            offDays.sort()
        }

        func removeOffDay(_ date: Date) {
            offDays.removeAll { $0 == calendar.startOfDay(for: date) }
        }

        func addMilestone(title: String, on date: Date) {
            let days = calendar.dateComponents([.day], from: startDay, to: date).day
            let draft = MilestoneDraft(title: title.trimmingCharacters(in: .whitespacesAndNewlines), dayNumber: (days ?? 0) + 1)
            guard !draft.title.isEmpty, draft.title.count <= Milestone.maxTitleLimit else { return }
            milestones.append(draft)
        }

        func addMilestone(title: String, dayNumber: Int) {
            let draft = MilestoneDraft(title: title.trimmingCharacters(in: .whitespacesAndNewlines), dayNumber: dayNumber)
            guard !draft.title.isEmpty, draft.title.count <= Milestone.maxTitleLimit else { return }
            milestones.append(draft)
        }

        func removeMilestone(draft: MilestoneDraft) {
            milestones.removeAll { $0.id == draft.id }
        }

        private func updateAvailability() {
            availability = Self.makeAvailability(calendar: calendar, start: startDay, durationDays: durationDays, offWeekdays: offWeekdays, offDays: offDays)
        }

        private static func makeState(title: String, startDay: Date, durationDays: Int,
                                      color: GoalColor, offWeekdays: OffWeekdays,
                                      offDays: [Date], milestones: [MilestoneDraft]) -> FormState {
            FormState(title: title, startDay: startDay, durationDays: durationDays,
                      color: color, offWeekdays: offWeekdays, offDays: offDays,
                      milestones: milestones.map { MilestoneKey(title: $0.title, dayNumber: $0.dayNumber) })
        }

        private static func makeAvailability(calendar: Calendar, start: Date, durationDays: Int,
                                             offWeekdays: OffWeekdays, offDays: [Date]) -> Availability {
            let end = calendar.date(byAdding: .day, value: max(durationDays, 1) - 1, to: start)!
            let timeline = GoalTimeline(start: start, end: end, now: start, calendar: calendar)
            return Availability(timeline: timeline, offWeekdays: offWeekdays, offDays: offDays)
        }
        private func syncMilestones(of goal: Goal, in context: ModelContext) {
            let keptIDs = Set(milestones.compactMap { $0.existing?.persistentModelID })
            for old in goal.milestones ?? [] where !keptIDs.contains(old.persistentModelID) {
                context.delete(old)
            }
            for draft in milestones {
                let target = calendar.date(byAdding: .day, value: draft.dayNumber - 1, to: startDay)!
                if let existing = draft.existing {
                    existing.title = draft.title
                    existing.targetDay = calendar.startOfDay(for: target)
                } else {
                    goal.addMilestone(title: draft.title, on: target, calendar: calendar)
                }
            }
        }

        @discardableResult
        func save(in context: ModelContext) throws -> Goal {
            guard isValid else { throw GoalFormError.invalid }
            let goal: Goal
            if let editingGoal {
                goal = editingGoal
                goal.update(title: trimmingTitle, startDay: startDay, endDay: endDay, color: color, offWeekdays: offWeekdays, offDays: offDays, calendar: calendar)
            } else {
                goal = Goal(title: trimmingTitle, startDay: startDay, endDay: endDay, color: color, offWeekdays: offWeekdays, offDays: offDays, calendar: calendar)
                context.insert(goal)
            }
            syncMilestones(of: goal, in: context)

            do {
                try context.save()
            } catch {
                context.rollback()
                throw GoalFormError.saveFailed(underlying: error)
            }
            return goal
        }
    }
}
