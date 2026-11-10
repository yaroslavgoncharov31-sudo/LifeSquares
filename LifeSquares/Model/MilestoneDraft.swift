import TimeCore
import Foundation
import LifeSquaresKit

struct MilestoneDraft: Equatable, Identifiable, Hashable {
    let id = UUID()
    var title: String
    var dayNumber: Int
    var existing: Milestone?
}
