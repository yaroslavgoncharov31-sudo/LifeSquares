import SwiftUI
import SwiftData
import LifeSquaresKit
import WidgetKit

@main struct LifeSquaresApp: App {
    @State private var now = Date()
    @Environment(\.scenePhase) private var scenePhase
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
            .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    now = Date()
                }
            }
        }
        .modelContainer(SharedModelContainer.shared)
    }
}
