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
        case let .goal(title, color, snapshot):
            switch family {
            case .systemSmall: WidgetSmallView(title: title, color: color, snapshot: snapshot, columnCount: 10)
            case .systemMedium: WidgetMediumView(title: title, color: color, snapshot: snapshot, columnCount: 15)
            case .accessoryCircular: AccessoryCircularView(snapshot: snapshot)
            case .accessoryRectangular: AccessoryRectangularView(title: title, snapshot: snapshot)
            case .accessoryInline: AccessoryInlineView(title: title, snapshot: snapshot)
            default: GoalGridLayout(color: color, snapshot: snapshot, columnCount: 10)
            }
        }
    }
}


struct NoGoalView: View {
    var body: some View {
        VStack {
            Image(systemName: "plus.circle")
                .padding(.bottom, 3)
            Text("Create a goal in app")
        }
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
