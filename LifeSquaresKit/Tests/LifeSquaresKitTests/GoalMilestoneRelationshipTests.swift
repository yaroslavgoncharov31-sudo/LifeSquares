import SwiftData
import Testing
internal import LifeSquaresKit
internal import Foundation
internal import TimeCore

@MainActor
struct GoalMilestoneRelationshipTests {

    let helper = DateTesterHelper()
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Goal.self, Milestone.self, configurations: config)
        context = container.mainContext
    }

    @Test func inverse_goalMilestoneRelationship_worksCorrectly() throws {
        let start = helper.makeStart()
        let end = helper.makeEnd()
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")

        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .blue, offWeekdays: [.saturday, .sunday], offDays: [], calendar: calendar)
        let m1 = Milestone(title: "TestM1", targetDay: start, calendar: calendar)
        context.insert(goal)
        context.insert(m1)
        m1.goal = goal

        #expect(goal.milestones == [m1])
        #expect(m1.goal === goal)

    }

    @Test func cascadeDeletionRule_goalMilestoneRelationship_worksCorrectly() throws {

        let start = helper.makeStart()
        let end = helper.makeEnd()
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")

        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .blue, offWeekdays: [.saturday, .sunday], offDays: [], calendar: calendar)
        let m1 = Milestone(title: "TestM1", targetDay: start, calendar: calendar)
        let m2 = Milestone(title: "TestM2", targetDay: end, calendar: calendar)
        m1.goal = goal
        m2.goal = goal

        let readContext = ModelContext(container)
        readContext.insert(goal)
        readContext.insert(m1)
        readContext.insert(m2)
        try readContext.save()

        readContext.delete(goal)
        try readContext.save()

        let newContext = ModelContext(container)
        let fetched = try newContext.fetch(FetchDescriptor<Goal>())
        let fetchedM = try newContext.fetch(FetchDescriptor<Milestone>())

        #expect(fetched.count == 0)
        #expect(fetchedM.count == 0)
    }

    @Test func deletionMilestone_notAffectsGoal() throws {
        let start = helper.makeStart()
        let end = helper.makeEnd()
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")

        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .blue, offWeekdays: [.saturday, .sunday], offDays: [], calendar: calendar)
        let m1 = Milestone(title: "TestM1", targetDay: start, calendar: calendar)
        let m2 = Milestone(title: "TestM2", targetDay: end, calendar: calendar)

        m1.goal = goal
        m2.goal = goal

        let readContext = ModelContext(container)
        readContext.insert(goal)
        readContext.insert(m1)
        readContext.insert(m2)
        try readContext.save()

        let beforeTest = try readContext.fetch(FetchDescriptor<Milestone>())
        #expect(beforeTest.count == 2)
        
        readContext.delete(m1)
        try readContext.save()

        let newContext = ModelContext(container)
        let fetched = try newContext.fetch(FetchDescriptor<Goal>())

        let first = try #require(fetched.first)
        #expect(fetched.count == 1)
        #expect(first.milestones?.count == 1)
        #expect(first.milestones?.first?.title == "TestM2")
    }

    @Test func goal_withNoMilestones() throws {
        let start = helper.makeStart()
        let end = helper.makeEnd()
        let calendar = helper.makeCalendar(timeZoneID: "Europe/Moscow")
        let goal = Goal(title: "TestTitle", startDay: start, endDay: end, color: .blue, offWeekdays: [.saturday, .sunday], offDays: [], calendar: calendar)

        let readContext = ModelContext(container)
        readContext.insert(goal)
        try readContext.save()

        let fetched = try readContext.fetch(FetchDescriptor<Goal>())

        let first = try #require(fetched.first)
        #expect((first.milestones ?? []).isEmpty)
    }
}
