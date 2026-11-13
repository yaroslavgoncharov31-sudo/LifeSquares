import Testing
internal import LifeSquaresKit
import SwiftData
internal import Foundation
internal import TimeCore

@MainActor
struct LifeSquaresTests {
    let helper = DateTesterHelper()
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Goal.self, Milestone.self, configurations: config)
        context = container.mainContext
    }

    @Test func insert_fetchReturnsValidFields() throws {

        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")

        let title = "TestTitle"
        let color = GoalColor.violet
        let start = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let dayOff1 = helper.makeDate(year: 2026, month: 11, day: 1, hour: 10, minute: 30, calendar: calendar)
        let dayOff2 = helper.makeDate(year: 2026, month: 11, day: 1, hour: 13, minute: 30, calendar: calendar)
        let dayOff3 = helper.makeDate(year: 2026, month: 11, day: 2, hour: 10, minute: 30, calendar: calendar)

        let startDayOff1 = calendar.startOfDay(for: dayOff1)
        let startDayOff3 = calendar.startOfDay(for: dayOff3)

        let goal = Goal(title: title, startDay: start, endDay: end, color: color, offWeekdays: [.saturday, .sunday], offDays: [dayOff1, dayOff2, dayOff3], calendar: calendar)
        context.insert(goal)
        try context.save()

        let readContext = ModelContext(container)
        let fetched = try readContext.fetch(FetchDescriptor<Goal>())

        let firstGoal = try #require(fetched.first)
        #expect(fetched.count == 1)
        #expect(firstGoal.title == title)
        #expect(firstGoal.startDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
        #expect(firstGoal.endDay == helper.makeDate(year: 2027, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
        #expect(firstGoal.color == color)
        #expect(firstGoal.offWeekdays == [.saturday, .sunday])
        #expect(firstGoal.offDays == [startDayOff1, startDayOff3])
    }

    @Test func insert_fetchReturnsValidRelationships() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")

        let targetDay1 = helper.makeDate(year: 2026, month: 12, day: 10, hour: 10, minute: 30, calendar: calendar)
        let targetDay2 = helper.makeDate(year: 2026, month: 12, day: 20, hour: 10, minute: 30, calendar: calendar)
        let start = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let goal = Goal(title: "Test", startDay: start, endDay: end, color: .blue, offWeekdays: [.saturday, .sunday], offDays: [], calendar: calendar)
        let m1 = Milestone(title: "TestM1", targetDay: targetDay1, calendar: calendar)
        let m2 = Milestone(title: "TestM2", targetDay: targetDay2, calendar: calendar)
        m1.goal = goal
        m2.goal = goal
        context.insert(m1)
        context.insert(m2)
        context.insert(goal)
        try context.save()

        let readContext = ModelContext(container)
        let fetched = try readContext.fetch(FetchDescriptor<Goal>())

        let firstGoal = try #require(fetched.first)
        let ms = try #require(firstGoal.milestones)
        #expect(ms.count == 2)
        #expect(ms.allSatisfy { $0.goal?.id == firstGoal.id })
    }

    @Test func customTime_goalInitReturnsStartOfDay() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")

        let start = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)

        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .blue, offWeekdays: [.saturday, .sunday], offDays: [], calendar: calendar)

        #expect(goal.startDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
        #expect(goal.endDay == helper.makeDate(year: 2027, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
    }

    @Test func calendar_withAnotherTimeZone_returnsDifferentTime() throws {
        let calendarM = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let calendarA = helper.makeCalendar(timeZoneID: "America/New_York")

        let start = helper.makeDate(year: 2026, month: 10, day: 15, hour: 2, minute: 0, calendar: calendarM)
        let end = helper.makeDate(year: 2027, month: 10, day: 15, hour: 2, minute: 0, calendar: calendarM)

        let goalA = Goal(title: "TestTitle", startDay: start, endDay: end, color: .blue, offWeekdays: [.saturday, .sunday], offDays: [], calendar: calendarA)
        let goalM = Goal(title: "TestTitle", startDay: start, endDay: end, color: .blue, offWeekdays: [.saturday, .sunday], offDays: [], calendar: calendarM)

        #expect(goalA.startDay == helper.makeDate(year: 2026, month: 10, day: 14, hour: 0, minute: 0, calendar: calendarA))
        #expect(goalA.endDay == helper.makeDate(year: 2027, month: 10, day: 14, hour: 0, minute: 0, calendar: calendarA))
        #expect(goalM.startDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendarM))
        #expect(goalM.endDay == helper.makeDate(year: 2027, month: 10, day: 15, hour: 0, minute: 0, calendar: calendarM))
        #expect(goalA.startDay != goalM.startDay)
        #expect(goalA.endDay != goalM.endDay)
    }

    @Test func colorRaw_withInvalidInputValue_returnsDefaultColorSlate() throws {

        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")

        let invalidColor = "garbage"
        let start = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let dayOff1 = helper.makeDate(year: 2026, month: 11, day: 1, hour: 10, minute: 30, calendar: calendar)
        let dayOff2 = helper.makeDate(year: 2026, month: 11, day: 1, hour: 13, minute: 30, calendar: calendar)
        let dayOff3 = helper.makeDate(year: 2026, month: 11, day: 2, hour: 10, minute: 30, calendar: calendar)

        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .violet, offWeekdays: [.saturday, .sunday], offDays: [dayOff1, dayOff2, dayOff3], calendar: calendar)
        goal.colorRaw = invalidColor

        #expect(goal.color == GoalColor.slate)
        #expect(goal.colorRaw == "garbage")
    }

    @Test func offDays_setDeletesDuplicates_inAscendingOrder() throws {

        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")

        let start = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let dayOff1 = helper.makeDate(year: 2026, month: 11, day: 1, hour: 22, minute: 30, calendar: calendar)
        let dayOff2 = helper.makeDate(year: 2026, month: 11, day: 4, hour: 14, minute: 30, calendar: calendar)
        let dayOff3 = helper.makeDate(year: 2026, month: 11, day: 3, hour: 5, minute: 30, calendar: calendar)
        let dayOff4 = helper.makeDate(year: 2026, month: 11, day: 1, hour: 23, minute: 30, calendar: calendar)
        let startDayOff1 = calendar.startOfDay(for: dayOff1)
        let startDayOff2 = calendar.startOfDay(for: dayOff2)
        let startDayOff3 = calendar.startOfDay(for: dayOff3)

        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .violet, offWeekdays: [.saturday, .sunday], offDays: [dayOff1, dayOff2, dayOff3, dayOff4], calendar: calendar)

        #expect(goal.offDays == [startDayOff1, startDayOff3, startDayOff2])
    }
}
