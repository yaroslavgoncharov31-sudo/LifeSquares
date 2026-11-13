import SwiftUI
import TimeCore
import LifeSquaresKit
import Foundation
import WidgetKit

struct AccessoryCircularView: View {
    let snapshot: GoalSnapshot

    var body: some View {
        Gauge(value: Double(snapshot.timeline.elapsedDays), in: 0...Double(snapshot.timeline.totalDays)) {
            Text("Days")
        } currentValueLabel: {
            Text("\(snapshot.passedDays)")
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .gaugeStyle(.accessoryCircularCapacity)
    }
}

#Preview(as: .accessoryCircular) {
    LifeSquaresWidget()
} timeline: {
    GoalEntry.makeSample()
    GoalEntry(date: .now, content: .noGoal)
}
