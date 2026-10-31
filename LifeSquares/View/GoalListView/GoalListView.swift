import TimeCore
import SwiftData
import SwiftUI

struct GoalListView: View {
    @Query private var goals: [Goal]
    private let now: Date
    private let calendar: Calendar

    init(now: Date, calendar: Calendar) {
        self.now = now
        self.calendar = calendar
        let today = calendar.startOfDay(for: now)
        _goals = Query(
            filter: #Predicate<Goal> { $0.endDay >= today },
            sort: \.startDay
        )
    }
    var body: some View {

    }
}

#Preview {
    GoalListView(now: .now, calendar: Calendar.current)
}
