import Foundation

struct OffWeekdays: OptionSet, Codable {
    var rawValue: Int

    static let sunday = OffWeekdays(rawValue: 1 << 0)
    static let monday = OffWeekdays(rawValue: 1 << 1)
    static let tuesday = OffWeekdays(rawValue: 1 << 2)
    static let wednesday = OffWeekdays(rawValue: 1 << 3)
    static let thursday = OffWeekdays(rawValue: 1 << 4)
    static let friday = OffWeekdays(rawValue: 1 << 5)
    static let saturday = OffWeekdays(rawValue: 1 << 6)

    static func from(weekday: Int) -> OffWeekdays? {
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
