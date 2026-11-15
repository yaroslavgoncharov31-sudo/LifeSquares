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
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(snapshot.timeline.elapsedDays, format: .number)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("/\(snapshot.timeline.totalDays)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .widgetGlassChip()
            .monospacedDigit()
            HStack(alignment: .top) {
                GoalGridLayout(color: color, snapshot: snapshot, columnCount: columnCount, size: 50, daysBeforeToday: 19)
            }
            Spacer(minLength: 0)
        }
        .widgetAccentable()
    }
}

#Preview(as: .systemSmall) {
    LifeSquaresWidget()
} timeline: {
    GoalEntry.makeSample()
    GoalEntry(date: .now, content: .noGoal)
}

