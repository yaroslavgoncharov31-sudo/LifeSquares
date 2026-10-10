import Testing
@testable import LifeSquares
import SwiftData
internal import Foundation
internal import TimeCore

@MainActor
struct GoalModelTests {
    let helper = DateTesterHelper()

    @Test(arguments: GoalColor.allCases)
    func goalColor_allCases(color: GoalColor) throws {

        let goal = Goal(title: "Test", startDay: helper.makeStart(), endDay: helper.makeEnd(), color: .slate, offWeekdays: [], offDays: [])
        goal.color = color

        #expect(goal.color == color)
        #expect(goal.colorRaw == color.rawValue)
    }

    @Test func offWeekdays_overwrite_replacesBits() throws {

        let goal = Goal(title: "Test", startDay: helper.makeStart(), endDay: helper.makeEnd(), color: .slate, offWeekdays: [.saturday, .sunday], offDays: [])
        #expect(goal.offWeekdaysRaw == 65)

        goal.offWeekdays = [.monday]
        #expect(goal.offWeekdaysRaw == 2)

        goal.offWeekdays = []
        #expect(goal.offWeekdaysRaw == 0)

        goal.offWeekdaysRaw = 65
        #expect(goal.offWeekdays == [.saturday, .sunday])

        goal.offWeekdaysRaw = 2
        #expect(goal.offWeekdays == [.monday])

        goal.offWeekdaysRaw = 0
        #expect(goal.offWeekdays == [])
    }

}
