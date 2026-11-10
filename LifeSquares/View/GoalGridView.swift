import Foundation
import SwiftUI
import LifeSquaresKit

struct GoalGridView: View {
    let goals: [Goal]
    let calendar: Calendar
    let now: Date
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
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
