import WidgetKit
import TimeCore
import LifeSquaresKit
import SwiftUI

struct LifeSquaresWidget: Widget {
    let kind: String = "LifeSquaresWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectGoalIntent.self, provider: GoalProvider()) { entry in
            GoalWidgetView(entry: entry)
                .environment(\.dayCellStyle, .compact)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Goal")
        .description("Days passed and milestones closed for one goal.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
            .systemSmall,
            .systemMedium
        ])
    }
}
