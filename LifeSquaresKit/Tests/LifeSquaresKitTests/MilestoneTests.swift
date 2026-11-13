import Testing
internal import LifeSquaresKit
import SwiftData
internal import Foundation
internal import TimeCore

@MainActor
struct MilestoneTests {

    let helper = DateTesterHelper()
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Goal.self, Milestone.self, configurations: config)
        context = container.mainContext
    }

    @Test func milestone_timeNormalization_worksCorrectly() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar)
        let m = Milestone(title: "TestTitle", targetDay: targetDay, calendar: calendar)

        #expect(m.targetDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
    }

    @Test func milestone_withAnotherTimeZone_returnsDifferentTime() {
        let calendarM = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let calendarA = helper.makeCalendar(timeZoneID: "America/New_York")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 15, hour: 2, minute: 0, calendar: calendarM)

        let mM = Milestone(title: "TestM", targetDay: targetDay, calendar: calendarM)
        let mA = Milestone(title: "TestA", targetDay: targetDay, calendar: calendarA)

        #expect(mM.targetDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendarM))
        #expect(mA.targetDay == helper.makeDate(year: 2026, month: 10, day: 14, hour: 0, minute: 0, calendar: calendarA))
        #expect(mM.targetDay != mA.targetDay)
    }

    @Test func milestone_closedAtProperty_nilByDefault() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let target = helper.makeTarget()
        let m = Milestone(title: "Test", targetDay: target, calendar: calendar)

        #expect(m.closedAt == nil)
    }

    @Test func milestone_closedAt_closesProperly() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let target = helper.makeTarget()
        let m = Milestone(title: "Test", targetDay: target, closedAt: target, calendar: calendar)
        #expect(m.closedAt == helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar))

        m.closedAt = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        #expect(m.closedAt == helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar))

        m.closedAt = nil
        #expect(m.closedAt == nil)
    }

    @Test func insert_fetchReturnsValidFields() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let target = helper.makeTarget()
        let m = Milestone(title: "Test", targetDay: target, closedAt: target, calendar: calendar)
        context.insert(m)
        try context.save()

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Milestone>())

        let first = try #require(fetched.first)
        #expect(first.title == "Test")
        #expect(first.targetDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
        #expect(first.closedAt == helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar))
    }
}
