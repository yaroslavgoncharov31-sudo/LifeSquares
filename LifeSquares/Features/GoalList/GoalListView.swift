import TimeCore
import SwiftData
import SwiftUI
import LifeSquaresKit

struct GoalListView: View {
    @Query private var goals: [Goal]
    @State private var showAdd = false
    @State private var showWarning = false
    private let now: Date
    private let calendar: Calendar
    private let isDemo: Bool
    private let onStartDemo: () -> Void

    init(now: Date, calendar: Calendar, isDemo: Bool = false, onStartDemo: @escaping () -> Void) {
        self.now = now
        self.calendar = calendar
        let today = calendar.startOfDay(for: now)
        _goals = Query(
            filter: #Predicate<Goal> { $0.endDay >= today },
            sort: \.startDay
        )
        self.isDemo = isDemo
        self.onStartDemo = onStartDemo
    }
    var body: some View {
        GoalGridView(goals: goals, calendar: calendar, now: now)
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New goal", systemImage: "plus") {
                        if isDemo {
                            showWarning = true
                        } else {
                            showAdd = true
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Route.archive) {
                        Label("Archive", systemImage: "archivebox")
                    }
                }
            }

            .alert("You are in demo mode", isPresented: $showWarning) {
                Button("Add anyway") { showAdd = true }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Goals you add in demo mode will be deleted when you exit")
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
                            .buttonStyle(.glassProminent)
                    }
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: 8) {
                            DemoCircle(onComplete: onStartDemo)
                            Text("Or swipe up to enter demo mode")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 50)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Enter demo mode")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAction { onStartDemo() }
                    }

                }
            }
    }
}

#Preview {
    GoalListView(now: .now, calendar: .current, onStartDemo: {})
}
