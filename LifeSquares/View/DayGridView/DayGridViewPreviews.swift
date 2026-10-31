//
    

import Foundation

#if DEBUG
import SwiftUI
import TimeCore

// MARK: - Preview data

enum PreviewData {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Warsaw")!
        calendar.firstWeekday = 2
        return calendar
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    static func snapshot(
        start: Date,
        days: Int,
        now: Date,
        offWeekdays: OffWeekdays = [.saturday, .sunday],
        offDays: [Date] = [],
        milestoneOffsets: [Int] = [],
        closed: Int = 0
    ) -> GoalSnapshot {
        let end = calendar.date(byAdding: .day, value: days - 1, to: start)!
        let milestones = milestoneOffsets.enumerated().map { index, offset in
            MilestoneInput(
                targetDate: calendar.date(byAdding: .day, value: offset, to: start)!,
                status: index < closed ? .closed : .open
            )
        }
        return GoalSnapshot(
            start: start, end: end, now: now, calendar: calendar,
            offWeekdays: offWeekdays, offDays: offDays,
            milestones: milestones
        )
    }

    static func cells(_ snapshot: GoalSnapshot) -> [DayCellModel] {
        (0..<snapshot.timeline.totalDays).compactMap {
            DayCellModel.make(index: $0, snapshot: snapshot)
        }
    }

    static func accessibilityText(_ snapshot: GoalSnapshot) -> String {
        "Прошло \(snapshot.timeline.elapsedDays) из \(snapshot.timeline.totalDays) дней"
    }

    static let english = snapshot(
        start: date(2026, 8, 31),
        days: 180,
        now: date(2026, 10, 14),
        offDays: [date(2026, 11, 4)],
        milestoneOffsets: [6, 13, 27, 41, 89, 179],
        closed: 4
    )

    static let week = snapshot(
        start: date(2026, 10, 12),
        days: 7,
        now: date(2026, 10, 15),
        milestoneOffsets: [5]
    )

    static let year = snapshot(
        start: date(2026, 9, 2),
        days: 365,
        now: date(2026, 10, 17),
        milestoneOffsets: [30, 120, 240, 364]
    )
}

// MARK: - Grid previews

private struct GridPreview: View {
    let snapshot: GoalSnapshot
    let color: GoalColor

    var body: some View {
        ScrollView {
            DayGridView(
                cells: PreviewData.cells(snapshot),
                color: color,
                accessibilityText: PreviewData.accessibilityText(snapshot)
            )
            .padding()
        }
    }
}

#Preview("180 days · light") {
    GridPreview(snapshot: PreviewData.english, color: .blue)
}

#Preview("180 days · dark") {
    GridPreview(snapshot: PreviewData.english, color: .blue)
        .preferredColorScheme(.dark)
}

#Preview("7 days") {
    GridPreview(snapshot: PreviewData.week, color: .green)
}

#Preview("365 days") {
    GridPreview(snapshot: PreviewData.year, color: .magenta)
}

// MARK: - Cell matrix: все комбинации × все цвета

private struct CellMatrixPreview: View {
    private let states: [CellState] = [.past, .today, .future]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(GoalColor.allCases, id: \.self) { color in
                    HStack(spacing: 6) {
                        ForEach(Array(combinations.enumerated()), id: \.offset) { index, combo in
                            DayCell(
                                cell: DayCellModel(
                                    id: index,
                                    state: combo.state,
                                    isAvailable: combo.isAvailable,
                                    hasMilestone: combo.hasMilestone
                                ),
                                color: color
                            )
                            .frame(width: 24)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var combinations: [(state: CellState, isAvailable: Bool, hasMilestone: Bool)] {
        states.flatMap { state in
            [true, false].flatMap { isAvailable in
                [false, true].map { hasMilestone in
                    (state, isAvailable, hasMilestone)
                }
            }
        }
    }
}

#Preview("Cells · light") {
    CellMatrixPreview()
}

#Preview("Cells · dark") {
    CellMatrixPreview()
        .preferredColorScheme(.dark)
}
#endif
