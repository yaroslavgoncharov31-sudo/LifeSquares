internal import Foundation
internal import TimeCore
@testable import LifeSquares
import SwiftData
import Testing
internal import LifeSquaresKit

@MainActor
struct GoalDetailViewModelTests {

    let helper = DateTesterHelper()
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Goal.self, Milestone.self, configurations: config)
        context = container.mainContext
    }

    @Test func futureGoal_returnsCorrectText() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 8, day: 26, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 8, day: 31, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2027, month: 2, day: 26, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [],
            offDays: []
        )
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.snapshot.dayText == "Starting in 5 days")
    }

    @Test(arguments:[
        (2026, 10, 14, "44/180"),
        (2026, 8, 31, "0/180"),
        (2027, 2, 26, "179/180"),
        (2027, 3, 5, "180/180")
    ])
    func dayText_duringAndAfterGoal(year: Int, month: Int, day: Int, expected: String) {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: year, month: month, day: day, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 8, day: 31, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2027, month: 2, day: 26, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [],
            offDays: []
        )
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })
        #expect(vm.snapshot.dayText == expected)
    }

    @Test func milestoneText_withMilestones_returnsCorerctText() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 8, day: 31, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2027, month: 2, day: 26, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [],
            offDays: []
        )
        let target1 = helper.makeDate(year: 2026, month: 10, day: 16, hour: 10, minute: 30, calendar: calendar)
        let target2 = helper.makeDate(year: 2026, month: 10, day: 17, hour: 10, minute: 30, calendar: calendar)
        let target3 = helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar)
        let target4 = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let target5 = helper.makeDate(year: 2026, month: 10, day: 20, hour: 10, minute: 30, calendar: calendar)
        let target6 = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let m1 = Milestone(title: "Test1", targetDay: target1)
        let m2 = Milestone(title: "Test2", targetDay: target2)
        let m3 = Milestone(title: "Test3", targetDay: target3)
        let m4 = Milestone(title: "Test4", targetDay: target4)
        let m5 = Milestone(title: "Test5", targetDay: target5)
        let m6 = Milestone(title: "Test6", targetDay: target6)
        m1.goal = goal
        m2.goal = goal
        m3.goal = goal
        m4.goal = goal
        m5.goal = goal
        m6.goal = goal
        m1.status = .closed
        m2.status = .closed
        m3.status = .closed
        m4.status = .closed
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.snapshot.milestoneText == "4/6")
    }

    @Test func milestoneText_withoutMilestones_returnsCorrectText() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 8, day: 31, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2027, month: 2, day: 26, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [],
            offDays: []
        )
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.snapshot.milestoneText == "No milestones")
    }

    @Test func workingDaysText_returnsCorrectText() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [.saturday, .sunday],
            offDays: [offDay]
        )
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.workingDayText == "5/9")
    }

    @Test func forecast_allMilestonesOpen_returnsCorrectValues() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [.saturday, .sunday],
            offDays: [offDay]
        )
        let target1 = helper.makeDate(year: 2026, month: 10, day: 16, hour: 10, minute: 30, calendar: calendar)
        let target2 = helper.makeDate(year: 2026, month: 10, day: 17, hour: 10, minute: 30, calendar: calendar)
        let target3 = helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar)
        let target4 = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let m1 = Milestone(title: "Test1", targetDay: target1)
        let m2 = Milestone(title: "Test2", targetDay: target2)
        let m3 = Milestone(title: "Test3", targetDay: target3)
        let m4 = Milestone(title: "Test4", targetDay: target4)
        m1.goal = goal
        m2.goal = goal
        m3.goal = goal
        m4.goal = goal
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.snapshot.forecast.forecastValue == "-")
        #expect(vm.snapshot.forecast.forecastLabel == "not enough data")
    }

    @Test func forecast_allMilestonesClosed_returnsCorrectValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [.saturday, .sunday],
            offDays: [offDay]
        )
        let target1 = helper.makeDate(year: 2026, month: 10, day: 16, hour: 10, minute: 30, calendar: calendar)
        let target2 = helper.makeDate(year: 2026, month: 10, day: 17, hour: 10, minute: 30, calendar: calendar)
        let target3 = helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar)
        let target4 = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let m1 = Milestone(title: "Test1", targetDay: target1)
        let m2 = Milestone(title: "Test2", targetDay: target2)
        let m3 = Milestone(title: "Test3", targetDay: target3)
        let m4 = Milestone(title: "Test4", targetDay: target4)
        m1.goal = goal
        m2.goal = goal
        m3.goal = goal
        m4.goal = goal
        m1.status = .closed
        m2.status = .closed
        m3.status = .closed
        m4.status = .closed
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.snapshot.forecast.forecastValue == "✓")
        #expect(vm.snapshot.forecast.forecastLabel == "all milestones closed")
    }

    @Test func forecast_halfMilestonesClosed_returnsCorrectValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [.saturday, .sunday],
            offDays: [offDay]
        )
        let target1 = helper.makeDate(year: 2026, month: 10, day: 16, hour: 10, minute: 30, calendar: calendar)
        let target2 = helper.makeDate(year: 2026, month: 10, day: 17, hour: 10, minute: 30, calendar: calendar)
        let target3 = helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar)
        let target4 = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let m1 = Milestone(title: "Test1", targetDay: target1)
        let m2 = Milestone(title: "Test2", targetDay: target2)
        let m3 = Milestone(title: "Test3", targetDay: target3)
        let m4 = Milestone(title: "Test4", targetDay: target4)
        m1.goal = goal
        m2.goal = goal
        m3.goal = goal
        m4.goal = goal
        m1.status = .closed
        m2.status = .closed
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.snapshot.forecast.forecastValue == "~4")
        #expect(vm.snapshot.forecast.forecastLabel == "needed at this pace")
    }

    @Test(arguments:[
        (7, "Starting in 5 days"),
        (14, "Total days 14, passed 2"),
        (26, "Total days 14, passed 14")
    ])
    func gridAccessibilityText_returnsCorrectText(day: Int, output: String) {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: day, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [.saturday, .sunday],
            offDays: [offDay]
        )
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.snapshot.gridAccessibilityText == output)
    }

    @Test func cells_hasCorrectAmount_andState() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [.saturday, .sunday],
            offDays: [offDay]
        )
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        #expect(vm.cells.count == vm.snapshot.timeline.totalDays)
        #expect(vm.cells[vm.snapshot.timeline.elapsedDays].state == .today)
    }

    @Test func toggle_changesMilestoneStatusCorrectly() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [.saturday, .sunday],
            offDays: [offDay]
        )
        let targertDay = helper.makeDate(year: 2026, month: 10, day: 20, hour: 10, minute: 30, calendar: calendar)
        let m = Milestone(title: "Test", targetDay: targertDay)
        m.goal = goal
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })

        context.insert(goal)
        context.insert(m)

        #expect(vm.snapshot.milestoneText == "0/1")

        try vm.toggle(m)
        
        #expect(m.status == .closed)
        #expect(m.closedAt == now)
        #expect(vm.snapshot.milestoneText == "1/1")

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Milestone>())
        let first = try #require(fetched.first)
        #expect(first.status == .closed)

        try vm.toggle(m)

        #expect(m.status == .open)
        #expect(m.closedAt == nil)
        #expect(vm.snapshot.milestoneText == "0/1")
    }

    @Test func closureNow_returnsChangedVariable() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        var now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(
            title: "Test",
            startDay: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            endDay: helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar),
            color: .slate,
            offWeekdays: [.saturday, .sunday],
            offDays: [offDay]
        )
        let vm = GoalDetailView.ViewModel(goal: goal, calendar: calendar, now: { now })
        #expect(vm.snapshot.dayText == "7/14")

        now = helper.makeDate(year: 2026, month: 10, day: 20, hour: 10, minute: 30, calendar: calendar)
        vm.refresh()

        #expect(vm.snapshot.dayText == "8/14")
    }
}
