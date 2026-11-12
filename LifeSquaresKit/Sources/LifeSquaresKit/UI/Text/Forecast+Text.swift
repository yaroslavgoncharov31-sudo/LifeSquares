import TimeCore
import Foundation

public extension Forecast {
    var forecastValue: String {
        switch self {
        case .notEnoughData:
            "-"
        case .completed:
            "✓"
        case .projected(let days):
            "~\(days)"
        }
    }
    var forecastLabel: String {
        switch self {
        case .notEnoughData:
            "not enough data"
        case .completed:
            "all milestones closed"
        case .projected:
            "needed at this pace"
        }
    }
}

