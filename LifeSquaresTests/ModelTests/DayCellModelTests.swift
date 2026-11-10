import Testing
internal import Foundation
@testable import LifeSquares
internal import TimeCore
internal import LifeSquaresKit

@MainActor
struct DayCellModel_make {

    let helper = DateTesterHelper()

    @Test func dayCellModel_index0_returnsCorrectValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = helper.makeData()
        let m = Milestone(title: "testM", targetDay: targetDay)
        m.goal = goal
        let snapshot = goal.snapshot(now: now, calendar: calendar)

        let cell = DayCellModel.make(index: 0, snapshot: snapshot)
        #expect(cell?.state == CellState.past)
        #expect(cell?.isAvailable == true)
        #expect(cell?.hasMilestone == false)
        #expect(cell?.id == 0)
    }

    @Test func dayCellModel_index2_returnsCorrectValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = helper.makeData()
        let m = Milestone(title: "testM", targetDay: targetDay)
        m.goal = goal
        let snapshot = goal.snapshot(now: now, calendar: calendar)

        let cell = DayCellModel.make(index: 2, snapshot: snapshot)
        #expect(cell?.state == CellState.past)
        #expect(cell?.isAvailable == false)
        #expect(cell?.hasMilestone == false)
        #expect(cell?.id == 2)
    }

    @Test func dayCellModel_index7_returnsCorrectValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = helper.makeData()
        let m = Milestone(title: "testM", targetDay: targetDay)
        m.goal = goal
        let snapshot = goal.snapshot(now: now, calendar: calendar)

        let cell = DayCellModel.make(index: 7, snapshot: snapshot)
        #expect(cell?.state == CellState.today)
        #expect(cell?.isAvailable == true)
        #expect(cell?.hasMilestone == false)
        #expect(cell?.id == 7)
    }

    @Test func dayCellModel_index9_returnsCorrectValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = helper.makeData()
        let m = Milestone(title: "testM", targetDay: targetDay)
        m.goal = goal
        let snapshot = goal.snapshot(now: now, calendar: calendar)

        let cell = DayCellModel.make(index: 9, snapshot: snapshot)
        #expect(cell?.state == CellState.future)
        #expect(cell?.isAvailable == true)
        #expect(cell?.hasMilestone == true)
        #expect(cell?.id == 9)
    }

    @Test func dayCellModel_index12_returnsCorrectValues() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = helper.makeData()
        let m = Milestone(title: "testM", targetDay: targetDay)
        m.goal = goal
        let snapshot = goal.snapshot(now: now, calendar: calendar)

        let cell = DayCellModel.make(index: 12, snapshot: snapshot)
        #expect(cell?.state == CellState.future)
        #expect(cell?.isAvailable == false)
        #expect(cell?.hasMilestone == false)
        #expect(cell?.id == 12)
    }

    @Test func dayCellModel_invalidIndex_returnsNil() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = helper.makeData()
        let m = Milestone(title: "testM", targetDay: targetDay)
        m.goal = goal
        let snapshot = goal.snapshot(now: now, calendar: calendar)

        let cell = DayCellModel.make(index: -1, snapshot: snapshot)
        #expect(cell?.state == nil)
        #expect(cell?.isAvailable == nil)
        #expect(cell?.hasMilestone == nil)
        #expect(cell?.id == nil)
    }

    @Test func dayCellModel_indexOutOfScope_returnsNil() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Warsaw")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 21, hour: 10, minute: 30, calendar: calendar)
        let now = helper.makeDate(year: 2026, month: 10, day: 19, hour: 10, minute: 30, calendar: calendar)
        let goal = helper.makeData()
        let m = Milestone(title: "testM", targetDay: targetDay)
        m.goal = goal
        let snapshot = goal.snapshot(now: now, calendar: calendar)

        let cell = DayCellModel.make(index: 14, snapshot: snapshot)
        #expect(cell?.state == nil)
        #expect(cell?.isAvailable == nil)
        #expect(cell?.hasMilestone == nil)
        #expect(cell?.id == nil)
    }
}
