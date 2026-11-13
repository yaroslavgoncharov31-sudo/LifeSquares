internal import Foundation
internal import TimeCore
internal import LifeSquaresKit

struct DateTesterHelper {

    func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, calendar: Calendar) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        let date = calendar.date(from: components)
        return date ?? Date()
    }
    func makeData() -> Goal {
        let calendar = makeCalendar(timeZoneID: "Europe/Warsaw")
        let start = makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar)
        let end = makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar)
        let offDay = makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        return Goal(title: "test", startDay: start, endDay: end, color: .slate, offWeekdays: [.saturday, .sunday], offDays: [offDay], calendar: calendar)
    }
    func makeCalendar(timeZoneID: String) -> Calendar  {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: timeZoneID)!
        return calendar
    }
    func makeStart() -> Date {
        let calendar = makeCalendar(timeZoneID: "Europe/Moscow")
        let start = makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        return start
    }
    func makeTarget() -> Date {
        let calendar = makeCalendar(timeZoneID: "Europe/Moscow")
        let start = makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        return start
    }
    func makeEnd() -> Date {
        let calendar = makeCalendar(timeZoneID: "Europe/Moscow")
        let end = makeDate(year: 2027, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        return end
    }
}
