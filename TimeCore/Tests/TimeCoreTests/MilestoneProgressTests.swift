import Testing
internal import Foundation
@testable import TimeCore

struct MilestoneProgressTests {

    @Test func milestoneProgress_withEmptyStatusArray_returnsCorrectValues() {
        let progress = MilestoneProgress(statuses: [])

        #expect(progress.total == 0)
        #expect(progress.closed == 0)
        #expect(progress.fraction == nil)
    }

    @Test func milestoneProgress_oneElementArray_fraction_returns1() {
        let progress = MilestoneProgress(statuses: [.closed])

        #expect(progress.fraction == 1)
    }

    @Test func milestoneProgress_allMilestones_open() {
        let progress = MilestoneProgress(statuses: [.open, .open, .open])

        #expect(progress.total == 3)
        #expect(progress.closed == 0)
        #expect(progress.fraction == 0)
    }

    @Test func milestoneProgress_allMilestones_closed() {
        let progress = MilestoneProgress(statuses: [.closed, .closed, .closed])

        #expect(progress.total == 3)
        #expect(progress.closed == 3)
        #expect(progress.fraction == 1)
    }

    @Test func milestoneProgress_allMilestones_partiallyClosed() {
        let progress = MilestoneProgress(statuses: [.closed, .open, .closed])

        #expect(progress.total == 3)
        #expect(progress.closed == 2)
        #expect(progress.fraction == 2.0 / 3.0)
    }

    @Test func milestoneProgressStatuses_rawValues_areCorrect() {
        let open = MilestoneStatus.open
        let closed = MilestoneStatus.closed

        #expect(open.rawValue == "open")
        #expect(closed.rawValue == "closed")
    }

    @Test func milestoneStatus_unknownRawValue_returnsNil() {
        #expect(MilestoneStatus(rawValue: "unknown") == nil)
    }
}
