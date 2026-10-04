import Foundation
import SwiftData

@Model
final class Milestone: Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var targetDay: Date
    var weight: Int
    var closedAt: Date?
    @Relationship var goal: Goal?

    init(title: String, targetDay: Date, weight: Int, closedAt: Date? = nil, goal: Goal?) {
        self.title = title
        self.targetDay = targetDay
        self.weight = weight
        self.closedAt = closedAt
        self.goal = goal
    }
}
