import Foundation
import  SwiftData

@Model
final class Goal: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var startDay: Date = Date.now
    var endDay: Date = Date.now
    var color: GoalColor = GoalColor.red
    var offWeekdays: OffWeekdays = OffWeekdays.monday
    var offDays: [Date] = []
    @Relationship(deleteRule: .cascade, inverse: \Milestone.goal) var milestones: [Milestone]? = []

    init(title: String, startDay: Date, endDay: Date, color: GoalColor, offWeekdays: OffWeekdays, offDays: [Date], milestones: [Milestone]? = nil, calendar: Calendar = .current) {
        self.title = title
        self.startDay = calendar.startOfDay(for: startDay)
        self.endDay = calendar.startOfDay(for: endDay)
        self.color = color
        self.offWeekdays = offWeekdays
        self.offDays = Set(offDays.map{ calendar.startOfDay(for: $0) }).sorted()
    }
}
