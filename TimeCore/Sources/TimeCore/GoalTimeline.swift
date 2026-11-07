public import Foundation

public enum CellState: Equatable, Sendable {
    case past, today, future
}

public struct GoalTimeline: Equatable, Sendable {

    public var start: Date
    public var end: Date
    public var today: Date
    public let totalDays: Int
    public let calendar: Calendar

    public init(start: Date, end: Date, now: Date, calendar: Calendar) {
        let startDayOfStart = calendar.startOfDay(for: start)
        let startDayOfEnd = calendar.startOfDay(for: end)
        self.start = startDayOfStart
        self.end = startDayOfEnd
        self.today = calendar.startOfDay(for: now)
        let normalizedStart = startDayOfStart
        let normalizedEnd = startDayOfEnd
        let days = calendar.dateComponents([.day], from: normalizedStart, to: normalizedEnd).day ?? 0
        self.totalDays = normalizedEnd < normalizedStart ? 0 : days + 1
        self.calendar = calendar
    }
    public var isFinished: Bool { today > end }

    public var daysUntilStart: Int? {
        today < start ? calendar.dateComponents([.day], from: today, to: start).day : nil
    }

    public var elapsedDays: Int {
        if totalDays == 0 {
            return 0
        } else if today <= start {
            return 0
        } else {
            let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
            return min(days, totalDays)
        }
    }
    public func index(of date: Date) -> Int? {
        let normalizedDate = calendar.startOfDay(for: date)
        guard let days = calendar.dateComponents([.day], from: start, to: normalizedDate).day,
              (0..<totalDays).contains(days)
                else { return nil }
        return days
    }

    public func cellState(at index: Int) -> CellState? {
        guard index < totalDays && index >= 0 else { return nil }
        guard let day = calendar.date(byAdding: .day, value: index, to: start) else { return nil }
        if day < today {
            return .past
        } else if day == today {
            return .today
        } else {
            return .future
        }
    }
}

extension GoalTimeline {
    var anchorIndex: Int {
        guard totalDays > 0 else { return 0 }
        return min(elapsedDays, totalDays - 1)
    }

    public func visibleRange(size: Int, daysBeforeToday: Int) -> Range<Int> {
        precondition(size > 0 && (0..<size).contains(daysBeforeToday))
        guard totalDays > size else { return 0..<totalDays }

        let latestStart = totalDays - size
        let start = max(0, min(anchorIndex - daysBeforeToday, latestStart))
        return start..<(start + size)
    }
}
