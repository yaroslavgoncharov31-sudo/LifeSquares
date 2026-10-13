public import Foundation

public struct Availability: Equatable, Sendable {
    public let totalAvailable: Int
    public let timeline: GoalTimeline
    private let mask: [Bool]

    public init(timeline: GoalTimeline, offWeekdays: OffWeekdays, offDays: [Date]) {
        let calendar = timeline.calendar
        let offSet = Set(offDays.map { calendar.startOfDay(for: $0) })

        var mask: [Bool] = []
        for i in 0..<timeline.totalDays {
            guard let date = calendar.date(byAdding: .day, value: i, to: timeline.start) else {
                mask.append(true)
                continue
            }
            let weekday = calendar.component(.weekday, from: date)
            let isOffWeekday = OffWeekdays.from(weekday: weekday).map { offWeekdays.contains($0) } ?? false
            let isOffDay = offSet.contains(calendar.startOfDay(for: date))
            mask.append(!(isOffWeekday || isOffDay))
        }
        self.timeline = timeline
        self.mask = mask
        self.totalAvailable = mask.filter { $0 }.count
    }

    public func isAvailable(at index: Int) -> Bool? {
        guard index >= 0 && index < mask.count else { return nil }
        return mask[index]
    }
    public var elapsedAvailable: Int {
        mask.prefix(timeline.elapsedDays).filter { $0 }.count
    }
    public var remainingAvailable: Int {
        totalAvailable - elapsedAvailable
    }
}
