import LifeSquaresKit
import SwiftUI
import TimeCore
import Foundation
import WidgetKit

struct GoalWidgetView: View {
    let entry: GoalProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch entry.content {
        case .noGoal:
            NoGoalView()
                .containerBackground(for: .widget) {
                    GoalWidgetBackground(color: GoalColor.slate, startPoint: .topLeading, endPoint: .bottomTrailing)
                }
        case let .goal(title, color, snapshot):
            switch family {
            case .systemSmall: WidgetSmallView(title: title, color: color, snapshot: snapshot, columnCount: 10)
                    .containerBackground(for: .widget) {
                        GoalWidgetBackground(color: color, startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
            case .systemMedium: WidgetMediumView(title: title, color: color, snapshot: snapshot, columnCount: 9)
                    .containerBackground(for: .widget) {
                        GoalWidgetBackground(color: color, startPoint: .bottomTrailing, endPoint: .topLeading)
                    }
            case .accessoryCircular: AccessoryCircularView(snapshot: snapshot)
                    .containerBackground(for: .widget) {
                        GoalWidgetBackground(color: color, startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
            case .accessoryRectangular: AccessoryRectangularView(title: title, snapshot: snapshot)
                    .containerBackground(for: .widget) {
                        GoalWidgetBackground(color: color, startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
            case .accessoryInline: AccessoryInlineView(title: title, snapshot: snapshot)
                    .containerBackground(for: .widget) {
                        GoalWidgetBackground(color: color, startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
            default: GoalGridLayout(color: color, snapshot: snapshot, columnCount: 10, size: 30, daysBeforeToday: 9)
                    .containerBackground(for: .widget) {
                        GoalWidgetBackground(color: color, startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
            }
        }
    }
}


struct NoGoalView: View {
    var body: some View {
        VStack {
            Image(systemName: "plus.circle")
                .accessibilityHidden(true)
                .padding(.bottom, 3)
            Text("Create a goal in the app")
        }
        .glassChip()
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
}


#Preview(as: .systemMedium) {
    LifeSquaresWidget()
} timeline: {
    GoalEntry.makeSample()
    GoalEntry(date: .now, content: .noGoal)
}
