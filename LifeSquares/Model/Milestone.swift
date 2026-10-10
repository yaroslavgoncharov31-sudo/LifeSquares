import Foundation
import SwiftData

@Model
final class Milestone: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var targetDay: Date = Date.now
    var weight: Int = 1
    var closedAt: Date? = nil
    var goal: Goal?

    init(title: String, targetDay: Date, weight: Int, closedAt: Date? = nil, calendar: Calendar = .current) {
        self.title = title
        self.targetDay = calendar.startOfDay(for: targetDay)
        self.weight = weight
        self.closedAt = closedAt
    }
}
