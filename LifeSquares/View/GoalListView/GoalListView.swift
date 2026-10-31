import TimeCore
import SwiftData
import SwiftUI

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
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
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
        .navigationTitle("Goals")
        .navigationDestination(for: Goal.self) { goal in
            GoalDetailView(goal: goal, calendar: calendar)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New goal", systemImage: "plus") { showAdd = true }
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
