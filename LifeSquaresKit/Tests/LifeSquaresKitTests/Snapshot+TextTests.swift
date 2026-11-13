internal import TimeCore
import Testing
internal import LifeSquaresKit

struct Snapshot_TextTests {

    let helper = DateTesterHelper()

    @Test(arguments: [
        (1, "Starting in 3 days"),
        (4, "0/14"),
        (5, "1/14"),
        (17, "13/14"),
        (19, "14/14"),
    ])
    func snapshot_passedDays_returnsCorrectText(day: Int, result: String) async throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let now = helper.makeDate(year: 2026, month: 10, day: day, hour: 10, minute: 30, calendar: calendar)
        let start = helper.makeDate(year: 2026, month: 10, day: 4, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2026, month: 10, day: 17, hour: 10, minute: 30, calendar: calendar)
        let snapshot = GoalSnapshot(start: start, end: end, now: now, calendar: calendar, offWeekdays: [], offDays: [], milestones: [])

        #expect(snapshot.dayText == result)
    }

}
