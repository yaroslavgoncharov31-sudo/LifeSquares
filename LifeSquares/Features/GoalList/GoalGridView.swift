import Foundation
import SwiftUI
import LifeSquaresKit

struct GoalGridView: View {
    let goals: [Goal]
    let calendar: Calendar
    let now: Date
    @ScaledMetric(relativeTo: .body) private var minCardWidth: CGFloat = 160

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: minCardWidth), spacing: 12)],
                      spacing: 12) {
                ForEach(goals) { goal in
                    NavigationLink(value: goal) {
                        GoalCard(title: goal.title, color: goal.color, snapshot: goal.snapshot(now: now, calendar: calendar))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground))
    }
}
