import Foundation
import SwiftUI

public struct DayCellStyle: Sendable {
    public var todayBorderWidth: CGFloat
    public var borderWidth: CGFloat
    public var milestoneDotScaleFactor: CGFloat

    public static let regular = DayCellStyle(todayBorderWidth: 3, borderWidth: 1, milestoneDotScaleFactor: 1)
    public static let compact = DayCellStyle(todayBorderWidth: 1.5, borderWidth: 0.5, milestoneDotScaleFactor: 0.35)
}

public extension EnvironmentValues {
    @Entry var dayCellStyle: DayCellStyle = .regular
}
