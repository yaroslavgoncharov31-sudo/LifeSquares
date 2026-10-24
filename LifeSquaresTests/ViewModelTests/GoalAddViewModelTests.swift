internal import Foundation
import SwiftData
@testable import LifeSquares
import Testing
internal import TimeCore

@MainActor
struct GoalAddViewModelTests {

    let helper = DateTesterHelper()
    let container: ModelContainer
    let context: ModelContext
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Milestone.self, Goal.self, configurations: config)
        context = ModelContext(container)
    }

    @Test func goal_byDefault_hasCorrect_startDay_endDay() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)


        #expect(vm.startDay == helper.makeDate(year: 2026, month: 10, day: 24, hour: 0, minute: 0, calendar: calendar))
        #expect(vm.endDay == helper.makeDate(year: 2026, month: 11, day: 22, hour: 0, minute: 0, calendar: calendar))
    }

    @Test func endDay_calculatesCorrectDay() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 8, day: 31, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 8, day: 31, hour: 10, minute: 30, calendar: calendar)
        vm.durationDays = 180

        #expect(vm.endDay == helper.makeDate(year: 2027, month: 2, day: 26, hour: 0, minute: 0, calendar: calendar))
    }

    @Test func ifDurationEquals1_endDayEquals_startDay() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let vm = GoalAddView.ViewModel(calendar: calendar)
        vm.durationDays = 1

        #expect(vm.endDay == vm.startDay)
    }

    @Test func validation_emptyTitle_returnsCorrectValidationIssue() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let vm = GoalAddView.ViewModel(calendar: calendar)

        vm.title = "     "
        #expect(vm.validationIssues == [.emptyTitle])
    }
    @Test func validation_allDays_areOffWeekdays_returnsCorrectValidationIssue() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        vm.title = "Test"
        vm.durationDays = 7
        vm.offWeekdays = [.saturday, .sunday, .monday, .tuesday, .wednesday, .thursday, .friday]

        #expect(vm.validationIssues == [.noWorkingDays])
    }

    @Test func validation_allDays_areOffDays_returnsCorrectValidationIssue() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        vm.durationDays = 3
        vm.title = "Test"
        vm.offDays = [
            helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar),
            helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        ]

        #expect(vm.validationIssues == [.noWorkingDays])
    }

    @Test func validation_milestone_putAtOutOfGoalScopeDay_returnsCorrectValidationIssue() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        vm.durationDays = 30
        vm.title = "Test"

        let draft = MilestoneDraft(title: "Test", dayNumber: 40)
        vm.milestones.append(draft)
        #expect(vm.validationIssues == [.milestoneOutOfRange(draft.id)])
    }

    @Test func validation_allFieldsFilledCorrectly_returnsValid() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "Test"
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        vm.durationDays = 7
        vm.offWeekdays = [.saturday, .sunday]

        #expect(vm.isValid == true)
    }

    @Test func addOffDay_oneDayAddedTwoTimesWithDifferentTime_offDayArrayContainsOneNormalizedCopy() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)

        vm.addOffDay(helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar))
        vm.addOffDay(helper.makeDate(year: 2026, month: 10, day: 25, hour: 18, minute: 30, calendar: calendar))

        #expect(vm.offDays.count == 1)
        let first = vm.offDays.first
        #expect(first == helper.makeDate(year: 2026, month: 10, day: 25, hour: 0, minute: 0, calendar: calendar))
    }

    @Test func addOffDay_addedInDescendingOrder_returnsArrayCorrectlySorted() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)

        vm.addOffDay(helper.makeDate(year: 2026, month: 10, day: 29, hour: 10, minute: 30, calendar: calendar))
        vm.addOffDay(helper.makeDate(year: 2026, month: 10, day: 31, hour: 10, minute: 30, calendar: calendar))
        vm.addOffDay(helper.makeDate(year: 2026, month: 10, day: 30, hour: 10, minute: 30, calendar: calendar))
        vm.addOffDay(helper.makeDate(year: 2026, month: 10, day: 26, hour: 18, minute: 30, calendar: calendar))

        #expect(vm.offDays == [
            helper.makeDate(year: 2026, month: 10, day: 26, hour: 0, minute: 0, calendar: calendar),
            helper.makeDate(year: 2026, month: 10, day: 29, hour: 0, minute: 0, calendar: calendar),
            helper.makeDate(year: 2026, month: 10, day: 30, hour: 0, minute: 0, calendar: calendar),
            helper.makeDate(year: 2026, month: 10, day: 31, hour: 0, minute: 0, calendar: calendar)
        ])
    }

    @Test func removeOffDay_removesSameDayWithAnotherTime() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)

        vm.addOffDay(helper.makeDate(year: 2026, month: 10, day: 29, hour: 10, minute: 30, calendar: calendar))
        vm.removeOffDay(helper.makeDate(year: 2026, month: 10, day: 29, hour: 18, minute: 30, calendar: calendar))

        #expect(vm.offDays.count == 0)
    }

    @Test func save_invalidForm_throwsInvalidError() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        vm.title = ""

        let error = #expect(throws: GoalFormError.self) {
            try vm.save(in: context)
        }
        guard case .invalid = error else {
            Issue.record("Expected .invalid, got \(String(describing: error))")
            return
        }
    }
    @Test func save_validForm_returnsValid() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        vm.title = "Test"
        vm.addMilestone(title: "Test1", dayNumber: 7)
        vm.addMilestone(title: "Test2", dayNumber: 14)

        try vm.save(in: context)

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Goal>())
        #expect(fetched.count == 1)
        let goal = try #require(fetched.first)
        #expect(goal.title == "Test")
        let targets = (goal.milestones ?? []).map(\.targetDay).sorted()

        #expect(goal.milestones?.count == 2)
        #expect(targets == [
            helper.makeDate(year: 2026, month: 10, day: 30, hour: 0, minute: 0, calendar: calendar),
            helper.makeDate(year: 2026, month: 11, day: 6, hour: 0, minute: 0, calendar: calendar),
        ])
    }

    @Test func editing_goalTitle_fetchedFromNewContext_hasEditedTitle() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        var vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "Test"
        try vm.save(in: context)
        let goals = try context.fetch(FetchDescriptor<Goal>())
        let goal = try #require(goals.first)

        vm = GoalAddView.ViewModel(calendar: calendar, goal: goal)
        vm.title = "TEST"
        try vm.save(in: context)

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Goal>())
        let first = try #require(fetched.first)

        #expect(first.title == "TEST")
    }

    @Test func editing_saveWithoutEditing_returnsCorrectFields() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "Test"
        vm.addMilestone(title: "Test1", dayNumber: 7)
        vm.addMilestone(title: "Test2", dayNumber: 14)
        try vm.save(in: context)

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Goal>())
        let goal = try #require(fetched.first)

        #expect(goal.title == "Test")
        #expect(goal.startDay == helper.makeDate(year: 2026, month: 10, day: 24, hour: 0, minute: 0, calendar: calendar))
        #expect(goal.endDay == helper.makeDate(year: 2026, month: 11, day: 22, hour: 0, minute: 0, calendar: calendar))
        #expect(goal.color == GoalColor.blue)
        #expect(goal.milestones?.count == 2)
    }

    @Test func editing_delete_addDraft_fetchedGoalHasSameMilestones() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)

        let create = GoalAddView.ViewModel(calendar: calendar, now: now)
        create.title = "Test"
        create.addMilestone(title: "Test1", dayNumber: 1)
        create.addMilestone(title: "Test2", dayNumber: 2)
        let goal = try create.save(in: context)

        let edit = GoalAddView.ViewModel(calendar: calendar, goal: goal)
        let test1 = try #require(edit.milestones.first { $0.title == "Test1" })
        edit.removeMilestone(draft: test1)
        edit.addMilestone(title: "Test3", dayNumber: 3)
        try edit.save(in: context)

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Goal>())
        #expect(fetched.count == 1)
        let saved = try #require(fetched.first)

        let milestones = (saved.milestones ?? []).sorted { $0.targetDay < $1.targetDay }
        #expect(milestones.map(\.title) == ["Test2", "Test3"])
        #expect(milestones.map(\.targetDay) == [
            helper.makeDate(year: 2026, month: 10, day: 25, hour: 0, minute: 0, calendar: calendar),
            helper.makeDate(year: 2026, month: 10, day: 26, hour: 0, minute: 0, calendar: calendar),
        ])
    }
}
