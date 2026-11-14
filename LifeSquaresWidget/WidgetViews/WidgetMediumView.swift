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
            HStack {
                Text(title)
                    .font(.headline.weight(.semibold))
                Spacer()
                VStack {
                    if snapshot.forecast != .notEnoughData {
                        Text(snapshot.forecast == .completed ? "\(snapshot.forecast.forecastValue)" : "\(snapshot.forecast.forecastValue) days")
                        Text(snapshot.forecast.forecastLabel)
                    }
                }
                .font(.caption.weight(.semibold))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            GoalGridLayout(color: color, snapshot: snapshot, columnCount: columnCount)
                .padding(.bottom, 3)
            HStack {
                Text(snapshot.dayText)
                Spacer()
                Text(snapshot.milestoneText)
            }
            .font(.footnote)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview(as: .systemMedium) {
    LifeSquaresWidget()
} timeline: {
    GoalEntry.makeSample()
    GoalEntry(date: .now, content: .noGoal)
}
