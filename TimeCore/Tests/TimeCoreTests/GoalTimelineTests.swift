import Testing
@testable import TimeCore
internal import Foundation

struct GoalTimelineTests {

    let helper = DateTesterHelper()

    @Test func goalTimeline_elapsedDays_inTheEndOfTimeline_returnCorrectDays() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let end = helper.makeDate(year: 2026, month: 11, day: 24, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeNow()
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.elapsedDays == 40)
    }

    @Test func goalTimeline_returnsCorrectAmountOfDays() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeNow()
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.totalDays == 181)
    }

    @Test(arguments: [
        (2026, 10, 14, 0),
        (2026, 10, 15, 0),
        (2026, 11, 24, 40),
        (2027, 4, 12, 179),
        (2027, 4, 13, 180),
        (2027, 4, 20, 180)
    ])
    func elapsedDays(year: Int, month: Int, day: Int, expected: Int) {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 4, day: 12, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: year, month: month, day: day, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)
        #expect(timeline.elapsedDays == expected)
    }

    @Test func goalTimeline_withSameData_areEqual() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeNow()
        let timelineA = GoalTimeline(start: start, end: end, now: now, calendar: calendar)
        let timelineB = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timelineA == timelineB)
    }

    @Test func cellState_atStartDay_returnsCorrectCellState() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: start, calendar: calendar)

        #expect(timeline.cellState(at: 0) == .today)
    }

    @Test func cellStatePAST() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let now = helper.makeNow()
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.cellState(at: 30) == .past)
    }

    @Test func cellStateFUTURE() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let now = helper.makeNow()
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.cellState(at: 60) == .future)
    }

    @Test func cellStateALLFUTURE() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let now = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.totalDays == 181)
        for index in 0..<timeline.totalDays {
            #expect(timeline.cellState(at: index) == .future, "index \(index)")
        }
    }

    @Test func cellStateALLPAST() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let now = helper.makeDate(year: 2027, month: 4, day: 14, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.totalDays == 181)
        for index in 0..<timeline.totalDays {
            #expect(timeline.cellState(at: index) == .past, "index \(index)")
        }
    }

    @Test func cellState_invalidIndices_returnNil() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let now = helper.makeDate(year: 2026, month: 11, day: 24, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.cellState(at: -1) == nil)
    }

    @Test func lastCell_atDeadlineDay_returnsTodayState() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let now = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)
        let lastDay = timeline.totalDays - 1

        #expect(timeline.cellState(at: lastDay) == .today)
    }

    @Test func differentTimezones_returnDifferentToday() {
        let calendarM = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let calendarP  = helper.makeCalendar(timeZoneID: "Pacific/Kiritimati")
        let start = helper.makeStart()
        let now = helper.makeDate(year: 2026, month: 11, day: 24, hour: 22, minute: 00, calendar: calendarM)
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendarM)
        let timelineM = GoalTimeline(start: start, end: end, now: now, calendar: calendarM)
        let timelineP = GoalTimeline(start: start, end: end, now: now, calendar: calendarP)

        #expect(timelineM.today == helper.makeDate(year: 2026, month: 11, day: 24, hour: 0, minute: 0, calendar: calendarM))
        #expect(timelineP.today == helper.makeDate(year: 2026, month: 11, day: 25, hour: 0, minute: 0, calendar: calendarP))
        #expect(timelineM.today != timelineP.today)
    }

    @Test(arguments: [
        (0, 0),
        (12, 0),
        (23, 59)
    ])
    func today_differentTime_returnsSame_elapsedDaysAndCellState(hour: Int, minutes: Int) {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeStart()
        let now = helper.makeDate(year: 2026, month: 11, day: 24, hour: hour, minute: minutes, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 4, day: 13, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.elapsedDays == 40)
        #expect(timeline.cellState(at: 40) == .today)
    }

    @Test func totalDays_acrossSpringForward_countsCalendarDays() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeDate(year: 2027, month: 3, day: 27, hour: 0, minute: 0, calendar: calendar)
        let end = helper.makeDate(year: 2027, month: 3, day: 29, hour: 0, minute: 0, calendar: calendar)
        let now = helper.makeDate(year: 2027, month: 3, day: 28, hour: 12, minute: 0, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.totalDays == 3)
        #expect(timeline.elapsedDays == 1)
        #expect(timeline.cellState(at: 1) == .today)
        #expect(timeline.cellState(at: 2) == .future)
    }

    @Test func daysUntilStart_returnsCorrectValues() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let start = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar)
        var now = helper.makeDate(year: 2026, month: 10, day: 10, hour: 10, minute: 30, calendar: calendar)
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline.daysUntilStart == 5)

        now = helper.makeDate(year: 2026, month: 10, day: 16, hour: 10, minute: 30, calendar: calendar)
        let timeline1 = GoalTimeline(start: start, end: end, now: now, calendar: calendar)

        #expect(timeline1.daysUntilStart == nil)
    }
}
