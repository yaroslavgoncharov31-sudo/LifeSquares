public import Foundation
public import SwiftData
import TimeCore

@Model
public final class Milestone: Identifiable, Hashable {
    public var id: UUID = UUID()
    public var title: String = ""
    public var targetDay: Date = Date.now
    public var closedAt: Date? = nil
    public var goal: Goal?
    public var statusRaw: String = MilestoneStatus.open.rawValue
    public var status: MilestoneStatus {
        get { MilestoneStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }

    public init(title: String, targetDay: Date, closedAt: Date? = nil, calendar: Calendar = .current) {
        self.title = title
        self.targetDay = calendar.startOfDay(for: targetDay)
        self.closedAt = closedAt
    }
    public static let maxTitleLimit = 40
}
