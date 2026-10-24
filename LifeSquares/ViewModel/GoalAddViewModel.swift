import TimeCore
import Foundation
import SwiftData

extension GoalAddView {
    @MainActor
    @Observable
    final class ViewModel {

        enum ValidationIssue: Equatable {
            case emptyTitle
            case noWorkingDays
            case milestoneOutOfRange(MilestoneDraft.ID)
        }

        

        private let calendar: Calendar
        private let editingGoal: Goal?

        init(calendar: Calendar = .autoupdatingCurrent, goal: Goal) {
            self.calendar = calendar
            self.editingGoal = goal
            self.title = goal.title
            self.startDay = goal.startDay
            self.color = goal.color
            self.durationDays = (calendar.dateComponents([.day], from: goal.startDay, to: goal.endDay).day ?? 0) + 1
            self.milestones = (goal.milestones ?? [])
                .sorted {$0.targetDay < $1.targetDay}
                .map { m in
                    let day = (calendar.dateComponents([.day], from: goal.startDay, to: m.targetDay).day ?? 0) + 1
                    return MilestoneDraft(title: m.title, dayNumber: day, existing: m)
                }
        }

        init(calendar: Calendar = .autoupdatingCurrent, now: Date = .now) {
            self.calendar = calendar
            self.startDay = calendar.startOfDay(for: now)
            self.editingGoal = nil
        }
        private var trimmingTitle: String {
            title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        var title: String = ""
        var startDay: Date
        var durationDays: Int = 30
        var endDay: Date {
            let day = calendar.date(byAdding: .day, value: durationDays - 1, to: startDay)!
            return calendar.startOfDay(for: day)
        }
        var color: GoalColor = .blue
        var offWeekdays: OffWeekdays = []
        var offDays: [Date] = []
        var milestones: [MilestoneDraft] = []
        var availability: Availability {
            let timeline = GoalTimeline(start: startDay, end: endDay, now: startDay, calendar: calendar)
            return Availability(timeline: timeline, offWeekdays: offWeekdays, offDays: offDays)
        }
        var validationIssues: [ValidationIssue] {
            var issues: [ValidationIssue] = []
            if title.trimmingCharacters(in: .whitespaces).isEmpty {
                issues.append(.emptyTitle)
            }
            if availability.totalAvailable == 0 {
                issues.append(.noWorkingDays)
            }
            for draft in milestones where !(1...durationDays).contains(draft.dayNumber) {
                issues.append(.milestoneOutOfRange(draft.id))
            }
            return issues
        }
        var isValid: Bool { validationIssues.isEmpty }


        func addOffDay(_ date: Date) {
            let day = calendar.startOfDay(for: date)
            guard !offDays.contains(day) else { return }
            offDays.append(day)
            offDays.sort()
        }
        func removeOffDay(_ date: Date) {
            offDays.removeAll { $0 == calendar.startOfDay(for: date) }
        }

        func addMilestone(title: String, dayNumber: Int) {
            let draft = MilestoneDraft(title: title, dayNumber: dayNumber)
            guard !draft.title.isEmpty else { return }
            milestones.append(draft)
        }
        func removeMilestone(draft: MilestoneDraft) {
            milestones.removeAll { $0.id == draft.id }
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
                    existing.targetDay = target
                } else {
                    let milestone = Milestone(title: draft.title, targetDay: target, weight: 1)
                    context.insert(milestone)
                    milestone.goal = goal
                }
            }
        }

        @discardableResult
        func save(in context: ModelContext) throws -> Goal {
            guard isValid else { throw GoalFormError.invalid }
            let goal: Goal
            if let editingGoal {
                goal = editingGoal
                goal.update(title: trimmingTitle, startDay: startDay, endDay: endDay, color: color, offWeekday: offWeekdays, offDays: offDays)
            } else {
                goal = Goal(title: trimmingTitle, startDay: startDay, endDay: endDay, color: color, offWeekdays: offWeekdays, offDays: offDays)
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
