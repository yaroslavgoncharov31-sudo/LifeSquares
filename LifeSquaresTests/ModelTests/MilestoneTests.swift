import Testing
@testable import LifeSquares
import SwiftData
internal import Foundation

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
        let m = Milestone(title: "TestTitle", targetDay: targetDay, weight: 1, calendar: calendar)

        #expect(m.targetDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
    }

    @Test func milestone_withAnotherTimeZone_returnsDifferentTime() {
        let calendarM = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let calendarA = helper.makeCalendar(timeZoneID: "America/New_York")
        let targetDay = helper.makeDate(year: 2026, month: 10, day: 15, hour: 2, minute: 0, calendar: calendarM)

        let mM = Milestone(title: "TestM", targetDay: targetDay, weight: 1, calendar: calendarM)
        let mA = Milestone(title: "TestA", targetDay: targetDay, weight: 1, calendar: calendarA)

        #expect(mM.targetDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendarM))
        #expect(mA.targetDay == helper.makeDate(year: 2026, month: 10, day: 14, hour: 0, minute: 0, calendar: calendarA))
        #expect(mM.targetDay != mA.targetDay)
    }

    @Test func milestone_closedAtProperty_nilByDefault() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let target = helper.makeTarget()
        let m = Milestone(title: "Test", targetDay: target, weight: 1, calendar: calendar)

        #expect(m.closedAt == nil)
    }

    @Test(arguments: [1, 2, 3])
    func milestone_weightValue_fromInit_readsBackCorrectly(weight: Int) {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let target = helper.makeTarget()
        let m = Milestone(title: "Test", targetDay: target, weight: weight, calendar: calendar)

        #expect(m.weight == weight)

    }

    @Test func milestone_closedAt_closesProperly() {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let target = helper.makeTarget()
        let m = Milestone(title: "Test", targetDay: target, weight: 1, closedAt: target, calendar: calendar)
        #expect(m.closedAt == helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar))

        m.closedAt = helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar)
        #expect(m.closedAt == helper.makeDate(year: 2026, month: 10, day: 14, hour: 10, minute: 30, calendar: calendar))

        m.closedAt = nil
        #expect(m.closedAt == nil)
    }

    @Test func insert_fetchReturnsValidFields() throws {
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let target = helper.makeTarget()
        let m = Milestone(title: "Test", targetDay: target, weight: 3, closedAt: target, calendar: calendar)
        context.insert(m)
        try context.save()

        let read = ModelContext(container)
        let fetched = try read.fetch(FetchDescriptor<Milestone>())

        let first = try #require(fetched.first)
        #expect(first.title == "Test")
        #expect(first.targetDay == helper.makeDate(year: 2026, month: 10, day: 15, hour: 0, minute: 0, calendar: calendar))
        #expect(first.weight == 3)
        #expect(first.closedAt == helper.makeDate(year: 2026, month: 10, day: 15, hour: 10, minute: 30, calendar: calendar))
    }
}
