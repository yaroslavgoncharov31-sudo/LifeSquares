import Foundation
import SwiftData
import TimeCore

@Model
final class Milestone: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var targetDay: Date = Date.now
    var weight: Int = 1
    var closedAt: Date? = nil
    var goal: Goal?
    var statusRaw: String = MilestoneStatus.open.rawValue
    var status: MilestoneStatus {
        get { MilestoneStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }

    init(title: String, targetDay: Date, weight: Int, closedAt: Date? = nil, calendar: Calendar = .current) {
        self.title = title
        self.targetDay = calendar.startOfDay(for: targetDay)
        self.weight = weight
        self.closedAt = closedAt
    }
}
