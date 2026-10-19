import Testing
@testable import TimeCore
internal import Foundation

struct AvailabilityTests {

    let helper = DateTesterHelper()

    @Test func availability_noWeekdays_returnsCorrectAmountOfAvailableDays() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [], offDays: [])

        #expect(availability.totalAvailable == 7)
    }

    @Test func availability_weekdays_returnsCorrectAmountOfAvailableDays() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [.saturday, .sunday], offDays: [])

        #expect(availability.totalAvailable == 5)
        #expect(availability.isAvailable(at: 0) == true)
        #expect(availability.isAvailable(at: 5) == false)
        #expect(availability.isAvailable(at: 6) == false)
    }

    @Test func availability_notFullWeeks_returnCorrectAvailableDays() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 27, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [.saturday, .sunday], offDays: [])

        #expect(availability.totalAvailable == 10)
    }

    @Test func availability_onlyOffDays() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff1 = helper.makeDate(year: 2026, month: 10, day: 13, hour: 10, minute: 30, calendar: calendar)
        let dayOff2 = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [], offDays: [dayOff1, dayOff2])

        #expect(availability.totalAvailable == 5)
        #expect(availability.isAvailable(at: 1) == false)
        #expect(availability.isAvailable(at: 3) == false)
        #expect(availability.isAvailable(at: 2) == true)
    }

    @Test func availability_weekdaysAndOffDaysIntersection_returnsCorrectAvailableDays() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 17, hour: 10, minute: 30, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [.saturday], offDays: [dayOff])

        #expect(availability.totalAvailable == 6)
    }

    @Test func availability_offDays_outOfGoalScope_doesNotAffectResult() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [], offDays: [dayOff])

        #expect(availability.totalAvailable == 7)
    }

    @Test func availability_offDayNormalization_marksDayCorrect() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 13, hour: 15, minute: 45, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [], offDays: [dayOff])

        #expect(availability.totalAvailable == 6)
    }

    @Test func availability_allDaysWeekdays_returnsCorrectValues() {
        let offWeekdays = OffWeekdays([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 13, hour: 15, minute: 45, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: offWeekdays, offDays: [dayOff])

        #expect(availability.totalAvailable == 0)
        #expect(availability.elapsedAvailable == 0)
        #expect(availability.remainingAvailable == 0)
        #expect(offWeekdays.rawValue == 127)
    }

    @Test func availability_isAvailable_indexBorders_returnNil() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 13, hour: 15, minute: 45, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [], offDays: [dayOff])

        #expect(availability.isAvailable(at: -1) == nil)
        #expect(availability.isAvailable(at: 0) != nil)
        #expect(availability.isAvailable(at: timeline.totalDays) == nil)
    }

    @Test func availability_emptyTimeline_returnsCorrectValues() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 13, hour: 15, minute: 45, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [], offDays: [dayOff])

        #expect(availability.totalAvailable == 0)
        #expect(availability.isAvailable(at: 0) == nil)
        #expect(timeline.end < timeline.start)
    }

    
    @Test(arguments: [
          (11, 0, 5),
          (15, 3, 2),
          (16, 4, 1),
          (17, 5, 0),
          (19, 5, 0),
    ])
    func q(now: Int, elapsed: Int, remaining: Int) {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: now, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [.saturday, .sunday], offDays: [])

        #expect(availability.elapsedAvailable == elapsed)
        #expect(availability.remainingAvailable == remaining)
    }

    @Test func availability_sameData_AvailablityAreEqual() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 13, hour: 15, minute: 45, calendar: calendar)

        let timeline1 = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff1 = helper.makeDate(year: 2026, month: 10, day: 13, hour: 15, minute: 45, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [], offDays: [dayOff])
        let availability1 = Availability(timeline: timeline1, offWeekdays: [], offDays: [dayOff1])

        #expect(availability == availability1)
    }

    @Test func availability_differentDayOff_AvailablityAreNotEqual() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let timeline = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 13, hour: 15, minute: 45, calendar: calendar)

        let timeline1 = GoalTimeline(
            start: helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar),
            end: helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar),
            now: helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar),
            calendar: calendar)
        let dayOff1 = helper.makeDate(year: 2026, month: 10, day: 14, hour: 15, minute: 45, calendar: calendar)
        let availability = Availability(timeline: timeline, offWeekdays: [], offDays: [dayOff])
        let availability1 = Availability(timeline: timeline1, offWeekdays: [], offDays: [dayOff1])

        #expect(availability != availability1)
    }
}
