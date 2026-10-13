import Foundation

public enum MilestoneStatus: String, Codable, Sendable {
    case open, closed
}

public struct MilestoneProgress: Equatable, Sendable {
    public let closed: Int
    public let total: Int
    public var fraction: Double? {
        total == 0 ? nil : Double(closed) / Double(total)
    }

    public init(statuses: [MilestoneStatus]) {
        self.closed = statuses.filter { $0 == .closed }.count
        self.total = statuses.count
    }
}
