import SwiftUI
import Foundation
import TimeCore
import WidgetKit
import LifeSquaresKit

struct AccessoryInlineView: View {
    let title: String
    let snapshot: GoalSnapshot

    var body: some View {
        Text("\(snapshot.compactDayText) · \(title)")
    }
}

#Preview(as: .accessoryInline) {
    LifeSquaresWidget()
} timeline: {
    GoalEntry.makeSample()
    GoalEntry(date: .now, content: .noGoal)
}

