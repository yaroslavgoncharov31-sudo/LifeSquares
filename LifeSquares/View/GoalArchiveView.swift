import TimeCore
import SwiftData
import Foundation
import SwiftUI

struct GoalArchiveView: View {
    @Query private var goals: [Goal]
    private let now: Date
    private let calendar: Calendar

    init(now: Date, calendar: Calendar = .autoupdatingCurrent) {
        let today = calendar.startOfDay(for: now)
        _goals = Query(
            filter: #Predicate<Goal> { $0.endDay < today },
            sort: \.endDay, order: .reverse
        )
        self.now = now
        self.calendar = calendar
    }

    var body: some View {
        GoalGridView(goals: goals, calendar: calendar, now: now)
            .navigationTitle("Archive")
            .overlay {
                if goals.isEmpty {
                    ContentUnavailableView {
                        Label("Archive is empty", systemImage: "clock")
                    } description: {
                        Text("Archived goals will appear here as time passes")
                    }
                }
            }
    }
}

#Preview {
    GoalArchiveView(now: .now)
}

