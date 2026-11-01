import Testing
@testable import LifeSquares
import SwiftData
internal import Foundation
internal import TimeCore

@MainActor
struct Goal_SnapshotTests {

    let helper = DateTesterHelper()
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Goal.self, Milestone.self, configurations: config)
        context = container.mainContext
    }

    @Test func goalSnapshot_fromContext_returnsCorrectData() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let start = helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let m1 = Milestone(title: "Test1", targetDay: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar))
        let m2 = Milestone(title: "Test2", targetDay: helper.makeDate(year: 2026, month: 10, day: 16, hour: 10, minute: 30, calendar: calendar))
        let m3 = Milestone(title: "Test3", targetDay: helper.makeDate(year: 2026, month: 10, day: 17, hour: 10, minute: 30, calendar: calendar))
        let m4 = Milestone(title: "Test4", targetDay: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar))
        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .slate, offWeekdays: [.saturday, .sunday], offDays: [offDay], calendar: calendar)
        m1.status = .closed
        m2.status = .closed
        let context = ModelContext(container)
        context.insert(goal)
        for m in [m1, m2, m3, m4] {
            context.insert(m)
            m.goal = goal
        }
        try context.save()

        let fresh = ModelContext(container)
        let goalF = try #require(try fresh.fetch(FetchDescriptor<Goal>()).first)
        let snapshot = goalF.snapshot(now: now, calendar: calendar)

        #expect(goalF.milestones?.count == 4)
        #expect(snapshot.timeline.totalDays == 14)
        #expect(snapshot.timeline.elapsedDays == 7)
        #expect(snapshot.availability.totalAvailable == 9)
        #expect(snapshot.availability.elapsedAvailable == 4)
        #expect(snapshot.availability.remainingAvailable == 5)
        #expect(snapshot.progress.total == 4)
        #expect(snapshot.progress.closed == 2)
        #expect(snapshot.progress.fraction == 0.5)
        #expect(snapshot.forecast == .projected(workingDaysNeeded: 4))
    }

    @Test func goalSnapshot_goalWithoutMilestones_returnsCorrectForecast() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let start = helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .slate, offWeekdays: [.saturday, .sunday], offDays: [offDay], calendar: calendar)

        let snapshot = goal.snapshot(now: now, calendar: calendar)
        #expect(snapshot.progress.total == 0)
        #expect(snapshot.progress.closed == 0)
        #expect(snapshot.progress.fraction == nil)
        #expect(snapshot.forecast == .notEnoughData)
    }

    @Test func goalSnapshot_differentNowMoment_returnsDifferentElapsedDaysValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let start = helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let now19 = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let now20 = helper.makeDate(year: 2026, month: 10, day: 20, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .slate, offWeekdays: [.saturday, .sunday], offDays: [offDay], calendar: calendar)

        let snapshot19 = goal.snapshot(now: now19, calendar: calendar)
        let snapshot20 = goal.snapshot(now: now20, calendar: calendar)

        #expect(snapshot19.timeline.elapsedDays == 7)
        #expect(snapshot19.availability.elapsedAvailable == 4)
        #expect(snapshot19.availability.remainingAvailable == 5)
        #expect(snapshot20.timeline.elapsedDays == 8)
        #expect(snapshot20.availability.elapsedAvailable == 5)
        #expect(snapshot20.availability.remainingAvailable == 4)
    }

    @Test func goalSnapshot_goalSnapshotMethodMadeSnapshot_isEqualTo_handMadeSnapshot() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let start = helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar)
        let offDay = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .slate, offWeekdays: [.saturday, .sunday], offDays: [offDay], calendar: calendar)

        let snapshot = goal.snapshot(now: now, calendar: calendar)

        #expect(snapshot == GoalSnapshot(start: start, end: end, now: now, calendar: calendar, offWeekdays: [.saturday, .sunday], offDays: [offDay], milestones: []))
    }
}
