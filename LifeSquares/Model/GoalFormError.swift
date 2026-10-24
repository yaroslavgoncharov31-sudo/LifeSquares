import Foundation

enum GoalFormError: LocalizedError {
    case invalid
    case saveFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalid: "Some fields need attention"
        case .saveFailed(let underlying): "Couldn't save the goal. \(underlying)"
        }
    }
    }
