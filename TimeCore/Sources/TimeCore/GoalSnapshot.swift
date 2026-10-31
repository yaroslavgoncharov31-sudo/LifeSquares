import Foundation

public struct GoalSnapshot: Sendable, Equatable {
    public let timeline: GoalTimeline
    public let availability: Availability
    public let progress: MilestoneProgress
    public let forecast: Forecast
    public let milestoneDays: Set<Int>

    public init(start: Date, end: Date, now: Date, calendar: Calendar,
                offWeekdays: OffWeekdays, offDays: [Date],
                milestones: [MilestoneInput]) {
        let timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)
        self.timeline = GoalTimeline(start: start, end: end, now: now, calendar: calendar)
        self.availability = Availability(timeline: timeline, offWeekdays: offWeekdays, offDays: offDays)
        self.progress = MilestoneProgress(statuses: milestones.map(\.status))
        self.forecast = Forecast(progress: progress, availability: availability)
        self.milestoneDays = Set(milestones.compactMap { timeline.index(of: $0.targetDate) })
    }
}

public extension GoalSnapshot {
    var dayText: String {
        let t = timeline
        let passed = min(t.elapsedDays + 1, t.totalDays)
        if let days = t.daysUntilStart { return "Starting in \(days) days"}
        return  "\(passed)/\(t.totalDays)"
    }
    var milestoneText: String {
        guard progress.total > 0 else { return "No milestones" }
        return "\(progress.closed)/\(progress.total)"
    }
    var todayIndex: Int? { timeline.index(of: timeline.today) }
}
