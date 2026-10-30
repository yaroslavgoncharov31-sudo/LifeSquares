import TimeCore
import Foundation

struct MilestoneDraft: Equatable, Identifiable, Hashable {
    let id = UUID()
    var title: String
    var dayNumber: Int
    var existing: Milestone?
}
