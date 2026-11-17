import AppIntents
import SwiftData
import LifeSquaresKit

struct GoalQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [GoalEntity] {
        let context = ModelContext(SharedModelContainer.shared)
        let descriptor = FetchDescriptor<Goal>(predicate: #Predicate { identifiers.contains($0.id) })
        return try context.fetch(descriptor).map { GoalEntity(id: $0.id, title: $0.title) }
    }
    func suggestedEntities() async throws -> [GoalEntity] {
        let today = Calendar.autoupdatingCurrent.startOfDay(for: .now)
        let context = ModelContext(SharedModelContainer.shared)
        let descriptor = FetchDescriptor<Goal>(
            predicate: #Predicate { $0.endDay >= today },
            sortBy: [SortDescriptor(\.startDay)]
        )
        return try context.fetch(descriptor).map { GoalEntity(id: $0.id, title: $0.title) }
    }
}
