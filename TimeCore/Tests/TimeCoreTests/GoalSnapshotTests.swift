import Testing
@testable import TimeCore
internal import Foundation

struct GoalSnapshotTests {

    let helper = DateTesterHelper()

    @Test func snapshot_wiresAllLayersTogether_week() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let start = helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2026, month: 10, day: 18, hour: 10, minute: 30, calendar: calendar)
        let now =  helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let target1 = helper.makeDate(year: 2026, month: 10, day: 13, hour: 10, minute: 30, calendar: calendar)
        let target2 = helper.makeDate(year: 2026, month: 10, day: 16, hour: 10, minute: 30, calendar: calendar)
        let target3 = helper.makeDate(year: 2026, month: 10, day: 17, hour: 10, minute: 30, calendar: calendar)
        let i1 = MilestoneInput(targetDate: target1, status: .closed)
        let i2 = MilestoneInput(targetDate: target2, status: .open)
        let i3 = MilestoneInput(targetDate: target3, status: .open)
        let snapshot = GoalSnapshot(start: start, end: end, now: now, calendar: calendar, offWeekdays: [.saturday, .sunday], offDays: [], milestones: [i1, i2, i3])

        #expect(snapshot.timeline.totalDays == 7)
        #expect(snapshot.timeline.elapsedDays == 3)
        #expect(snapshot.availability.totalAvailable == 5)
        #expect(snapshot.availability.elapsedAvailable == 3)
        #expect(snapshot.availability.remainingAvailable == 2)
        #expect(snapshot.progress.closed == 1)
        #expect(snapshot.progress.total == 3)
        #expect(snapshot.forecast == .projected(workingDaysNeeded: 6))
    }

    @Test func snapshot_wiresAllLayersTogether_twoWeeks() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let dayOff = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        let start = helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar)
        let end = helper.makeDate(year: 2026, month: 10, day: 25, hour: 10, minute: 30, calendar: calendar)
        let now =  helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let target1 = helper.makeDate(year: 2026, month: 10, day: 12, hour: 10, minute: 30, calendar: calendar)
        let target2 = helper.makeDate(year: 2026, month: 10, day: 13, hour: 10, minute: 30, calendar: calendar)
        let target3 = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let target4 = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let i1 = MilestoneInput(targetDate: target1, status: .closed)
        let i2 = MilestoneInput(targetDate: target2, status: .closed)
        let i3 = MilestoneInput(targetDate: target3, status: .open)
        let i4 = MilestoneInput(targetDate: target4, status: .open)
        let snapshot = GoalSnapshot(
            start: start,
            end: end,
            now: now,
            calendar: calendar,
            offWeekdays: [.saturday, .sunday],
            offDays: [dayOff],
            milestones: [i1, i2, i3, i4]
        )

        #expect(snapshot.timeline.totalDays == 14)
        #expect(snapshot.timeline.elapsedDays == 7)
        #expect(snapshot.availability.totalAvailable == 9)
        #expect(snapshot.availability.elapsedAvailable == 4)
        #expect(snapshot.availability.remainingAvailable == 5)
        #expect(snapshot.progress.closed == 2)
        #expect(snapshot.progress.total == 4)
        #expect(snapshot.forecast == .projected(workingDaysNeeded: 4))
    }

}
