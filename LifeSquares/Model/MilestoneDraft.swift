import TimeCore
import Foundation

struct MilestoneDraft: Equatable, Identifiable {
    let id = UUID()
    var title: String
    var dayNumber: Int
    var existing: Milestone?
}
