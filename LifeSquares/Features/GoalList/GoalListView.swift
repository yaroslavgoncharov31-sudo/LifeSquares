import TimeCore
import SwiftData
import SwiftUI
import LifeSquaresKit

struct GoalListView: View {
    @Query private var goals: [Goal]
    @State private var showAdd = false
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
        GoalGridView(goals: goals, calendar: calendar, now: now)
        .navigationTitle("Goals")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New goal", systemImage: "plus") { showAdd = true }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Route.archive) {
                    Label("Archive", systemImage: "archivebox")
                }
            }

        }
        .sheet(isPresented: $showAdd) {
            NavigationStack { GoalAddView() }
        }
        .overlay {
            if goals.isEmpty {
                ContentUnavailableView {
                    Label("No goals yet", systemImage: "square.grid.3x3")
                } description: {
                    Text("One day, one square")
                } actions: {
                    Button("Create goal") { showAdd = true }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    GoalListView(now: .now, calendar: Calendar.current)
}
