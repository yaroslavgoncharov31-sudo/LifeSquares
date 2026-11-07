import TimeCore
import Foundation
import SwiftData

extension Goal {
    @discardableResult
    func addMilestone(title: String, on date: Date, calendar: Calendar = .autoupdatingCurrent) -> Milestone? {
        let day = calendar.startOfDay(for: date)
        guard (startDay...endDay).contains(day) else  { return nil }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.count <= Milestone.maxTitleLimit else { return nil }
        guard !trimmedTitle.isEmpty else { return nil }
        let milestone = Milestone(title: trimmedTitle, targetDay: date, calendar: calendar)
        modelContext?.insert(milestone)
        milestone.goal = self

        return milestone
    }
}
