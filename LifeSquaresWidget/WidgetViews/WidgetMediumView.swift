import SwiftUI
import TimeCore
import LifeSquaresKit
import Foundation
import WidgetKit

struct WidgetMediumView: View {
    let title: String
    let color: GoalColor
    let snapshot: GoalSnapshot
    let columnCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            HStack(alignment: .top, spacing: 16) {
                GoalGridLayout(color: color, snapshot: snapshot, columnCount: columnCount, size: 54, daysBeforeToday: 16)
                VStack(alignment: .leading) {
                    Spacer(minLength: 0)
                    HStack(alignment: .firstTextBaseline) {
                        BigDayNumber(snapshot: snapshot)
                        Text("Days")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    HStack(alignment: .firstTextBaseline) {
                        BigMilestoneNumber(snapshot: snapshot)
                        Text("Milestones")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .widgetGlassChip()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
#Preview(as: .systemMedium) {
    LifeSquaresWidget()
} timeline: {
    GoalEntry.makeSample()
    GoalEntry(date: .now, content: .noGoal)
}
