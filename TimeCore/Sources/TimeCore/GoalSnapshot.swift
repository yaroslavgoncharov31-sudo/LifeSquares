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
