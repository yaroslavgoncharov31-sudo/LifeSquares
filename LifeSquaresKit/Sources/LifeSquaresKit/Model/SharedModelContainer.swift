import SwiftData

public enum SharedModelContainer {
    public static let appGroupId = "group.com.yaroslavgoncharov.LifeSquares"

    public static let shared: ModelContainer = make()

    public static func make(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([Goal.self, Milestone.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            groupContainer: inMemory ? .none : .identifier(appGroupId),
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
