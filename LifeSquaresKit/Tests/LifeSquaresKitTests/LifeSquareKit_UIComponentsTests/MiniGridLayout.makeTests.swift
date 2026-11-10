import Testing
@testable import LifeSquares
internal import Foundation
internal import TimeCore
import Numerics
@MainActor
struct MiniGridLayout_makeTests {

    let helper = DateTesterHelper()

    @Test func miniGridLayout_returnsCorrectCellSize() async throws {
        let layout = MiniGridLayout.make(totalDays: 180, side: 140, spacing: 1.5)

        #expect(layout.cellSize.isApproximatelyEqual(to: 8.6, relativeTolerance: 0.001))
    }
    @Test func miniGridLayout_retutnsCorrectColumnsAmount() {
        let side: CGFloat = 140
        let layout = MiniGridLayout.make(totalDays: 1, side: side, spacing: 1.5)

        #expect(layout.columns == 1)
        #expect(layout.cellSize == side)
    }

    @Test func miniGridLayout_with0Days_returns1Column() {
        let layout = MiniGridLayout.make(totalDays: 0, side: 140, spacing: 1.5)

        #expect(layout.columns == 1)
    }

    @Test func miniGridLayout_365Days_returnsCorrectColumnsAmount() {
        let layout = MiniGridLayout.make(totalDays: 365, side: 140, spacing: 1.5)

        #expect(layout.columns == 20)
    }
}
