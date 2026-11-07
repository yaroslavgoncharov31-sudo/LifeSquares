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

    @Test func validation_newlinesOnlyTitle_returnsEmptyTitleIssue() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let vm = GoalAddView.ViewModel(calendar: calendar)

        vm.title = "\n\t \n"
        #expect(vm.validationIssues == [.emptyTitle])
    }

    @Test func addMilestoneDayNumber_trimsTitle_andSkipsBlank() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let vm = GoalAddView.ViewModel(calendar: calendar)

        vm.addMilestone(title: "   \n", dayNumber: 3)
        vm.addMilestone(title: "  Test  ", dayNumber: 3)

        #expect(vm.milestones.map(\.title) == ["Test"])
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
    @Test func save_validForm_persistsGoalWithMilestones() throws {
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

    @Test func editing_saveWithoutEditing_keepsAllFields() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 24, hour: 10, minute: 30, calendar: calendar)
        let create = GoalAddView.ViewModel(calendar: calendar, now: now)
        create.title = "Test"
        create.color = .green
        create.offWeekdays = [.saturday, .sunday]
        create.addOffDay(helper.makeDate(year: 2026, month: 10, day: 27, hour: 10, minute: 30, calendar: calendar))
        create.addMilestone(title: "Test1", dayNumber: 7)
        create.addMilestone(title: "Test2", dayNumber: 14)
        let goal = try create.save(in: context)

        let edit = GoalAddView.ViewModel(calendar: calendar, goal: goal)
        try edit.save(in: context)

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Goal>())
        #expect(fetched.count == 1)
        let saved = try #require(fetched.first)

        #expect(saved.title == "Test")
        #expect(saved.startDay == helper.makeDate(year: 2026, month: 10, day: 24, hour: 0, minute: 0, calendar: calendar))
        #expect(saved.endDay == helper.makeDate(year: 2026, month: 11, day: 22, hour: 0, minute: 0, calendar: calendar))
        #expect(saved.color == .green)
        #expect(saved.offWeekdays == [.saturday, .sunday])
        #expect(saved.offDays == [helper.makeDate(year: 2026, month: 10, day: 27, hour: 0, minute: 0, calendar: calendar)])
        let milestones = (saved.milestones ?? []).sorted { $0.targetDay < $1.targetDay }
        #expect(milestones.map(\.title) == ["Test1", "Test2"])
        #expect(milestones.map(\.targetDay) == [
            helper.makeDate(year: 2026, month: 10, day: 30, hour: 0, minute: 0, calendar: calendar),
            helper.makeDate(year: 2026, month: 11, day: 6, hour: 0, minute: 0, calendar: calendar),
        ])
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

    @Test(arguments: [
        (3650),
        (1)
    ])
    func duration_correctValues_returnsEmptyValidationIssueArray(duration: Int) {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "Test"
        vm.durationDays = duration

        #expect(vm.validationIssues == [])
    }

    @Test func duration_valueZero_returnsCorrectValidationIssueArray() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "Test"
        vm.durationDays = 0

        #expect(vm.validationIssues == [.durationOutOfRange])
    }

    @Test func duration_valueOutOFRange_returnsCorrectValidationIssue() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "Test"
        vm.durationDays = 3651

        #expect(vm.validationIssues == [.durationOutOfRange])
    }

    @Test(arguments: [
        (2, [2, 3, 4, 5, 6, 7, 1]),
        (1, [1, 2, 3, 4, 5, 6, 7]),
        (7, [7, 1, 2, 3, 4, 5, 6])
    ])
    func orderedWeekdays_returnsCorrectArray(day: Int, array: [Int]) {
        var calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        calendar.firstWeekday = day
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)

        #expect(vm.orderedWeekdays == array)
    }

    @Test(arguments: [
        ("en_US", 1, "S"),
        ("en_US", 2, "M"),
        ("pl_PL", 1, "N"),
        ("pl_PL", 2, "P")
    ])
    func weekdaySymbol_returnsCorrectValueDependingOnLocale(localeID: String, index: Int, symbol: String) {
        var calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        calendar.locale = Locale(identifier: localeID)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)

        let s = vm.weekdaySymbol(index)
        #expect(s == symbol)
    }

    @Test func isOff_toggle_returnCorrectValues() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        #expect(vm.isOff(2) == false)

        vm.toggleWeekday(2)
        #expect(vm.isOff(2) == true)
        #expect(vm.offWeekdays == [.monday])

        vm.toggleWeekday(2)
        #expect(vm.isOff(2) == false)
        #expect(vm.offWeekdays == [])

        vm.toggleWeekday(0)
        #expect(vm.isOff(0) == false)
        #expect(vm.offWeekdays == [])

        vm.toggleWeekday(8)
        #expect(vm.isOff(8) == false)
        #expect(vm.offWeekdays == [])
    }

    @Test func addMilestoneOn_on7thDay_returnsCorrectDayNumber() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)

        vm.addMilestone(title: "Test", on: helper.makeDate(year: 2026, month: 11, day: 1, hour: 10, minute: 30, calendar: calendar))
        #expect(vm.milestones.first?.dayNumber == 7)
    }

    @Test func addMilestoneOn_onStartDay_returnsCorrectDayNumber() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)

        vm.addMilestone(title: "Test", on: helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar))
        #expect(vm.milestones.first?.dayNumber == 1)
    }

    @Test func addMilestoneOn_on7thDay_normalization_returnsCorrectDayNumber() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)

        vm.addMilestone(title: "Test", on: helper.makeDate(year: 2026, month: 11, day: 1, hour: 23, minute: 59, calendar: calendar))
        #expect(vm.milestones.first?.dayNumber == 7)
    }

    @Test func initInEditMode_returnsViewModelWithCorrectValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .green,
            offWeekdays: [.saturday, .sunday],
            offDays: [helper.makeDate(year: 2026, month: 10, day: 13, hour: 10, minute: 30, calendar: calendar)],
            calendar: calendar
        )
        let m1 = Milestone(title: "Test1", targetDay: helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar), calendar: calendar)
        let m3 = Milestone(title: "Test3", targetDay: helper.makeDate(year: 2026, month: 10, day: 16, hour: 10, minute: 30, calendar: calendar), calendar: calendar)
        let m2 = Milestone(title: "Test2", targetDay: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar), calendar: calendar)
        m1.goal = goal
        m3.goal = goal
        m2.goal = goal

        let vm = GoalAddView.ViewModel(calendar: calendar, goal: goal)

        #expect(vm.title == "Test")
        #expect(vm.color == .green)
        #expect(vm.offWeekdays == [.saturday, .sunday])
        #expect(vm.offDays == [helper.makeDate(year: 2026, month: 10, day: 13, hour: 0, minute: 0, calendar: calendar)])
        #expect(vm.durationDays == 14)
        #expect(vm.milestones.map( { $0.title }) == ["Test1", "Test2", "Test3"])
        #expect(vm.milestones.map { $0.dayNumber } == [3, 4, 5])
        #expect(vm.milestones.map { $0.existing != nil } == [true, true, true])
    }

    private func makeStoredGoal(calendar: Calendar) throws -> Goal {
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .green,
            offWeekdays: [.saturday, .sunday],
            offDays: [helper.makeDate(year: 2026, month: 10, day: 13, hour: 10, minute: 30, calendar: calendar)],
            calendar: calendar
        )
        context.insert(goal)
        for (title, day) in [("Test1", 14), ("Test2", 15), ("Test3", 16)] {
            let target = helper.makeDate(year: 2026, month: 10, day: day, hour: 10, minute: 30, calendar: calendar)
            let milestone = Milestone(title: title, targetDay: target, calendar: calendar)
            context.insert(milestone)
            milestone.goal = goal
        }
        try context.save()
        return goal
    }

    @Test func syncMilestones_editedDraft_updatesExistingMilestone() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let goal = try makeStoredGoal(calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, goal: goal)
        let original = try #require(vm.milestones.first?.existing)
        let originalID = original.id

        vm.milestones[0].title = "TEST1"
        vm.milestones[0].dayNumber = 10
        try vm.save(in: context)

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Milestone>())
        #expect(fetched.count == 3)
        let edited = try #require(fetched.first { $0.id == originalID })
        #expect(edited.title == "TEST1")
        #expect(edited.targetDay == helper.makeDate(year: 2026, month: 10, day: 21, hour: 0, minute: 0, calendar: calendar))
    }

    @Test func changedStartDay_shiftsMilestonesKeepingDayNumbers() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let goal = try makeStoredGoal(calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, goal: goal)

        vm.startDay = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        try vm.save(in: context)

        #expect(vm.milestones.map(\.dayNumber) == [3, 4, 5])
        let read = ModelContext(container)
        let saved = try #require(try read.fetch(FetchDescriptor<Goal>()).first)
        #expect(saved.startDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
        #expect(saved.endDay == helper.makeDate(year: 2026, month: 10, day: 28, hour: 0, minute: 0, calendar: calendar))
        let targets = (saved.milestones ?? []).map(\.targetDay).sorted()
        #expect(targets == [
            helper.makeDate(year: 2026, month: 10, day: 17, hour: 0, minute: 0, calendar: calendar),
            helper.makeDate(year: 2026, month: 10, day: 18, hour: 0, minute: 0, calendar: calendar),
            helper.makeDate(year: 2026, month: 10, day: 19, hour: 0, minute: 0, calendar: calendar),
        ])
    }

    @Test func startDay_setWithTime_isNormalizedToStartOfDay() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)

        vm.startDay = helper.makeDate(year: 2026, month: 11, day: 3, hour: 18, minute: 45, calendar: calendar)

        #expect(vm.startDay == helper.makeDate(year: 2026, month: 11, day: 3, hour: 0, minute: 0, calendar: calendar))
    }

    @Test func trimmingTitle_returnsTrimmedTitle() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "     Test     "
        vm.addMilestone(title: "     TestMilestone     ", on: helper.makeDate(year: 2026, month: 10, day: 27, hour: 10, minute: 30, calendar: calendar))
        try vm.save(in: context)

        let read = ModelContext(container)
        let f = try read.fetch(FetchDescriptor<Goal>())
        #expect(f.first?.milestones?.first?.title == "TestMilestone")
        #expect(f.first?.title == "Test")
    }

    @Test func goalWithAllIssues_validationIssueArray_containsAllIssues() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = ""
        vm.durationDays = 0
        let d1 = MilestoneDraft(title: "Test", dayNumber: 800)
        vm.milestones.append(d1)
        vm.offWeekdays = [.saturday, .sunday, .monday, .tuesday, .wednesday, .thursday, .friday]

        #expect(vm.validationIssues == [.durationOutOfRange, .emptyTitle, .noWorkingDays, .milestoneOutOfRange(d1.id)])
    }

    @Test(arguments: [-1, 0, 1, 3650, 3651])
    func validationIssues_anyDuration_doesNotCrash(duration: Int) {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.durationDays = duration
        vm.milestones.append(MilestoneDraft(title: "M", dayNumber: 1))
        _ = vm.validationIssues
    }

    @Test func milestoneDayNumber_EqualsOne_hasNoProblem() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "Test"
        let d = MilestoneDraft(title: "Test", dayNumber: 1)
        vm.milestones.append(d)

        #expect(vm.validationIssues.isEmpty)
    }

    @Test func milestoneDayNumber_EqualsDurationDays_hasNoProblem() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 26, hour: 10, minute: 30, calendar: calendar)
        let vm = GoalAddView.ViewModel(calendar: calendar, now: now)
        vm.title = "Test"
        let d = MilestoneDraft(title: "Test", dayNumber: vm.durationDays)
        vm.milestones.append(d)

        #expect(vm.validationIssues.isEmpty)
    }
}

