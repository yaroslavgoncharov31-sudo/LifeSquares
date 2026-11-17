public import Foundation
public import SwiftData
import TimeCore

@Model
public final class Goal: Identifiable {
    public var id: UUID = UUID()
    public var title: String = ""
    public var startDay: Date = Date.now
    public var endDay: Date = Date.now
    public var colorRaw: String = GoalColor.blue.rawValue
    public var color: GoalColor {
        get { GoalColor(rawValue: colorRaw) ?? .slate }
        set { colorRaw = newValue.rawValue }
    }
    public var offWeekdaysRaw: Int = 0
    public var offWeekdays: OffWeekdays {
        get { OffWeekdays(rawValue: offWeekdaysRaw) }
        set { offWeekdaysRaw = newValue.rawValue }
    }
    public var offDays: [Date] = []
    @Relationship(deleteRule: .cascade, inverse: \Milestone.goal) public var milestones: [Milestone]? = []

    public init(title: String, startDay: Date, endDay: Date, color: GoalColor, offWeekdays: OffWeekdays, offDays: [Date], calendar: Calendar = .current) {
        self.title = title
        self.startDay = calendar.startOfDay(for: startDay)
        self.endDay = calendar.startOfDay(for: endDay)
        self.color = color
        self.offWeekdays = offWeekdays
        self.offDays = Set(offDays.map{ calendar.startOfDay(for: $0) }).sorted()
    }
    public func update(title: String, startDay: Date, endDay: Date, color: GoalColor, offWeekdays: OffWeekdays, offDays: [Date], calendar: Calendar = .current) {
        self.title = title
        self.startDay = calendar.startOfDay(for: startDay)
        self.endDay = calendar.startOfDay(for: endDay)
        self.color = color
        self.offWeekdays = offWeekdays
        self.offDays = Set(offDays.map { calendar.startOfDay(for: $0) }).sorted()
    }
    public static let maxTitleLength = 30
}
