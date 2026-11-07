import SwiftUI
import SwiftData

@main struct LifeSquaresApp: App {
    @State private var now = Date()
    private let calendar = Calendar.autoupdatingCurrent
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                GoalListView(now: now, calendar: calendar)
                    .navigationDestination(for: Goal.self) { goal in
                        GoalDetailView(goal: goal, calendar: calendar)
                    }
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .archive: GoalArchiveView(now: now, calendar: calendar)
                        }
                    }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                now = Date()
            }
        }
        .modelContainer(for: [Goal.self, Milestone.self])
    }
}
