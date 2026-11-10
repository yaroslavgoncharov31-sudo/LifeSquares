public import Foundation

public struct MilestoneInput: Equatable, Sendable {
    public let targetDate: Date
    public let status: MilestoneStatus
    
    public init(targetDate: Date, status: MilestoneStatus) {
        self.targetDate = targetDate
        self.status = status
    }
}
