import TimeCore
import Foundation

public extension Forecast {
    var forecastValue: String {
        switch self {
        case .notEnoughData:
            String(localized: "—", bundle: .module)
        case .completed:
            String(localized: "✓", bundle: .module)
        case .projected(let days):
            String(localized: "~\(days)", bundle: .module)
        }
    }
    var forecastLabel: String {
        switch self {
        case .notEnoughData:
            String(localized: "Not enough data", bundle: .module)
        case .completed:
            String(localized: "all milestones closed", bundle: .module)
        case .projected:
            String(localized: "needed at this pace", bundle: .module)
        }
    }
}

