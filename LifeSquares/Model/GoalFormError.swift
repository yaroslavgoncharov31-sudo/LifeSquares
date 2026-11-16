import Foundation

enum GoalFormError: LocalizedError {
    case invalid
    case saveFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalid: String(localized: "Some fields need attention")
        case .saveFailed(let underlying): String(localized: "Couldn't save the goal. \(underlying.localizedDescription)")
        }
    }
    }
