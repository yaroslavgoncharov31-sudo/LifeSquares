import SwiftUI

@main struct LifeSquaresApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

//struct previewЙЦУ: View {
//    @State var demoContainer: ModelContainer?
//    let container = SharedModelContainer.make(inMemory: true)
//    var isDemo: Bool { demoContainer != nil }
//    private let calendar = Calendar.autoupdatingCurrent
//    @State private var now: Date = Date()
//    var body: some View {
//        VStack {
//            ZStack {
//                NavigationStack {
//                    GoalListView(now: now, calendar: calendar, isDemo: isDemo,
//                                 onStartDemo: { withAnimation { demoContainer = DemoGoalFactory.container()}},
//                                 onExitDemo: { withAnimation { demoContainer = nil}}
//                    )
//                }
//                .modelContainer(demoContainer ?? container)
//                .id(isDemo)
//                .transition(.opacity)
//            }
//            VStack {
//                Button("toggle") { withAnimation { demoContainer = DemoGoalFactory.container()}}
//                Button("reset") { withAnimation { demoContainer = nil } }
//                Text("\(isDemo)")
//            }
//        }
//    }
//}
//#Preview {
//    previewЙЦУ()
//}
