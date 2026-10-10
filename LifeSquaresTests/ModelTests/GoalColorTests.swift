import Testing
@testable import LifeSquares
import SwiftData
internal import Foundation

struct GoalColorTests {
    let helper = DateTesterHelper()
    @Test func goalColor_hasCorrectRawValues() throws {
        #expect(GoalColor.red.rawValue == "red")
        #expect(GoalColor.magenta.rawValue == "magenta")
        #expect(GoalColor.violet.rawValue == "violet")
        #expect(GoalColor.blue.rawValue == "blue")
        #expect(GoalColor.cyan.rawValue == "cyan")
        #expect(GoalColor.green.rawValue == "green")
        #expect(GoalColor.slate.rawValue == "slate")
    }

    @Test func goalColor_containsCasesForAllColors() throws {
        #expect(GoalColor.allCases.count == 7)
    }

    @Test func goalColor_hasAllUniqueValues() throws {
        #expect(Set(GoalColor.allCases.map(\.rawValue)).count == GoalColor.allCases.count)
    }

    @Test func goalColor_hasAllUniqueLightHexes() throws {
        #expect(Set(GoalColor.allCases.map(\.hex.light)).count == GoalColor.allCases.count)
    }

    @Test func goalColor_hasAllUniqueDarkHexes() throws {
        #expect(Set(GoalColor.allCases.map(\.hex.dark)).count == GoalColor.allCases.count)
    }

    @Test(arguments: GoalColor.allCases)
    func goalColor_darkHexesAllValues_notEqualTo_lightHexesAllValues(color: GoalColor) throws {
        #expect(color.hex.light != color.hex.dark)
    }

    @Test(arguments: GoalColor.allCases)
    func hex_valuesFitIntoThreeBytes(color: GoalColor) {
        let hex = color.hex
        #expect(hex.light <= 0xFFFFFF)
        #expect(hex.dark <= 0xFFFFFF)
    }
}
