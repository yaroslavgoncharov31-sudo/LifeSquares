import SwiftData
import SwiftUI
import LifeSquaresKit
import WidgetKit
import TimeCore

struct RootView: View {
    @State private var demoContainer: ModelContainer? = nil
    @State private var now = Date()
    private var isDemo: Bool { demoContainer != nil }
    @Environment(\.scenePhase) private var scenePhase
    private let calendar = Calendar.autoupdatingCurrent
    var body: some View {
        ZStack {
            NavigationStack {
                GoalListView(now: now, calendar: calendar, isDemo: isDemo,
                             onStartDemo: { withAnimation { demoContainer = DemoGoalFactory.container()}})
                .navigationDestination(for: Goal.self) { goal in
                    GoalDetailView(goal: goal, calendar: calendar)
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .archive: GoalArchiveView(now: now, calendar: calendar)
                    }
                }
            }
            .modelContainer(demoContainer ?? SharedModelContainer.shared)
            .id(isDemo)
            .transition(.opacity)
        }
        .demoGlow(isActive: isDemo)
        .safeAreaInset(edge: .bottom) {
            if isDemo {
                DemoExitButton(onExitDemo: { withAnimation { demoContainer = nil}})
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
}

#Preview {
    RootView()
}
