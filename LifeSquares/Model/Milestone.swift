import Foundation
import SwiftData
import TimeCore

@Model
final class Milestone: Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String = ""
    var targetDay: Date = Date.now
    var closedAt: Date? = nil
    var goal: Goal?
    var statusRaw: String = MilestoneStatus.open.rawValue
    var status: MilestoneStatus {
        get { MilestoneStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }

    init(title: String, targetDay: Date, closedAt: Date? = nil, calendar: Calendar = .current) {
        self.title = title
        self.targetDay = calendar.startOfDay(for: targetDay)
        self.closedAt = closedAt
    }
    static let maxTitleLimit = 40
}
