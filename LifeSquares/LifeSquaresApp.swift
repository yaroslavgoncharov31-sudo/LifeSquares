import SwiftUI
import SwiftData

@main struct LifeSquaresApp: App {
    @State private var now = Date()
    private let calendar = Calendar.autoupdatingCurrent
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                GoalListView(now: now, calendar: calendar)
                    .id(calendar.startOfDay(for: now))
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                now = Date()
            }
        }
        .modelContainer(for: [Goal.self, Milestone.self])
    }
}
