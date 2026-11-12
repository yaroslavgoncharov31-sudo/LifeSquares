import SwiftUI
import TimeCore
import LifeSquaresKit
import Foundation
import WidgetKit

struct WidgetSmallView: View {
    let title: String
    let color: GoalColor
    let snapshot: GoalSnapshot
    let columnCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            GoalGridLayout(color: color, snapshot: snapshot, columnCount: columnCount)
            HStack {
                Text(snapshot.dayText)
                Spacer()
                Text(snapshot.milestoneText)
            }
            .font(.caption2)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
    }
}

#Preview(as: .systemSmall) {
    LifeSquaresWidget()
} timeline: {
    GoalEntry.makeSample()
    GoalEntry(date: .now, content: .noGoal)
}
