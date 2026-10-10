import Testing
import SwiftData
internal import Foundation
@testable import TimeCore

struct OffWeekdaysTests {

    let helper = DateTesterHelper()

    @Test(arguments: [
        (4, OffWeekdays.sunday, 1),
        (5, OffWeekdays.monday, 2),
        (6, OffWeekdays.tuesday, 4),
        (7, OffWeekdays.wednesday, 8),
        (8, OffWeekdays.thursday, 16),
        (9, OffWeekdays.friday, 32),
        (10, OffWeekdays.saturday, 64),
    ])
    func offWeekdays_calendarSunday_returnsCorrectValue(day: Int, expected: OffWeekdays, raw: Int) throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let date = helper.makeDate(year: 2026, month: 10, day: day, hour: 12, minute: 30, calendar: calendar)
        let day = calendar.component(.weekday, from: date)

        #expect(OffWeekdays.from(weekday: day) == expected)
        #expect(expected.rawValue == raw)
    }

    @Test(arguments: [
        (1, OffWeekdays.sunday),
        (2, .monday),
        (3, .tuesday),
        (4, .wednesday),
        (5, .thursday),
        (6, .friday),
        (7, .saturday)
    ])
    func offWeekdays_dayValue_returnsCorrectDay(weekday: Int, expected: OffWeekdays) throws {
        #expect(OffWeekdays.from(weekday: weekday) == expected)
    }

    @Test func allDays_union_equalsMask127() {
        let all: OffWeekdays = [.sunday, .monday, .tuesday, .wednesday,
                                .thursday, .friday, .saturday]
        #expect(all.rawValue == 127)
    }

    @Test(arguments: [0, 8, -1])
    func from_invalidWeekday_returnsNil(weekday: Int) {
        #expect(OffWeekdays.from(weekday: weekday) == nil)
    }
}
