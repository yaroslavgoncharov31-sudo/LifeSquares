import Foundation

struct OffWeekdays: OptionSet {
     let rawValue: Int

    static let sunday = OffWeekdays(rawValue: 1 << 0)
    static let monday = OffWeekdays(rawValue: 1 << 1)
    static let tuesday = OffWeekdays(rawValue: 1 << 2)
    static let wednesday = OffWeekdays(rawValue: 1 << 3)
    static let thursday = OffWeekdays(rawValue: 1 << 4)
    static let friday = OffWeekdays(rawValue: 1 << 5)
    static let saturday = OffWeekdays(rawValue: 1 << 6)

}
