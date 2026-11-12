import SwiftUI
import Foundation
import TimeCore
import WidgetKit
import LifeSquaresKit

struct AccessoryRectangularView: View {
    let title: String
    let snapshot: GoalSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .widgetAccentable()

            Gauge(value: Double(snapshot.timeline.elapsedDays), in: 0...Double(snapshot.timeline.totalDays)) {
                EmptyView()
            }
            .gaugeStyle(.accessoryLinearCapacity)

            HStack {
                Text("\(snapshot.compactDayText)")
                Spacer()
                if !snapshot.milestoneDays.isEmpty {
                    Image(systemName: "flag")
                }
                Text(snapshot.compactMilestoneText ?? "")
            }
            .font(.caption)
        }
    }
}

#Preview(as: .accessoryRectangular) {
    LifeSquaresWidget()
} timeline: {
    GoalEntry.makeSample()
    GoalEntry(date: .now, content: .noGoal)
}

