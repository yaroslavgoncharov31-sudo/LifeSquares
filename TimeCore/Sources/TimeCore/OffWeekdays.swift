import Foundation

public struct OffWeekdays: OptionSet, Codable, Sendable {
    public var rawValue: Int

    public static let sunday = OffWeekdays(rawValue: 1 << 0)
    public static let monday = OffWeekdays(rawValue: 1 << 1)
    public static let tuesday = OffWeekdays(rawValue: 1 << 2)
    public static let wednesday = OffWeekdays(rawValue: 1 << 3)
    public static let thursday = OffWeekdays(rawValue: 1 << 4)
    public static let friday = OffWeekdays(rawValue: 1 << 5)
    public static let saturday = OffWeekdays(rawValue: 1 << 6)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static func from(weekday: Int) -> OffWeekdays? {
        switch weekday {
        case 1:
            return sunday
        case 2:
            return monday
        case 3:
            return tuesday
        case 4:
            return wednesday
        case 5:
            return thursday
        case 6:
            return friday
        case 7:
            return saturday
        default:
            return nil
        }
    }

}
