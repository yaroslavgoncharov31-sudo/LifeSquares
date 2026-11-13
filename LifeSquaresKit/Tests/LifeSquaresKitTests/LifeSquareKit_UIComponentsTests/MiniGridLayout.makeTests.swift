import Testing
internal import LifeSquaresKit
internal import Foundation
internal import TimeCore
@MainActor
struct MiniGridLayout_makeTests {

    let helper = DateTesterHelper()

    @Test func miniGridLayout_returnsCorrectCellSize() async throws {
        // 100 days -> 10 columns: (118 - 2 * 9) / 10 = 10, exact in floating point
        let layout = MiniGridLayout.make(totalDays: 100, side: 118, spacing: 2)

        #expect(layout.columns == 10)
        #expect(layout.cellSize == 10)
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
