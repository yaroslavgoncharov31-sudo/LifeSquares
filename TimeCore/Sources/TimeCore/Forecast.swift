import Foundation

public enum Forecast: Equatable, Sendable {
    case notEnoughData
    case completed
    case projected(workingDaysNeeded: Int)

    public static let minElapsedShareDenominator = 5

    public static func make(closed: Int, total: Int, totalAvailable: Int, elapsedAvailable: Int) -> Forecast {
        if total == 0 { return .notEnoughData }
        if closed >= total { return .completed }
        if closed == 0 { return .notEnoughData }
        if elapsedAvailable == 0 { return .notEnoughData }
        if elapsedAvailable * minElapsedShareDenominator < totalAvailable { return .notEnoughData }
        let remaining = total - closed
        let needed = (remaining * elapsedAvailable + closed - 1) / closed
        return .projected(workingDaysNeeded: needed)
    }

    public init(progress: MilestoneProgress, availability: Availability) {
        self = Forecast.make(
            closed: progress.closed,
            total: progress.total,
            totalAvailable: availability.totalAvailable,
            elapsedAvailable: availability.elapsedAvailable
        )
    }
}
