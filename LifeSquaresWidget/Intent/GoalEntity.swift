import LifeSquaresKit
import TimeCore
import AppIntents
import Foundation

struct GoalEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Goal"
    static let defaultQuery = GoalQuery()

    let id: UUID
    let title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}
