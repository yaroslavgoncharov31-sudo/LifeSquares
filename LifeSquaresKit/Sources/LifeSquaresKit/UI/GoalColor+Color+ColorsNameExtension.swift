import SwiftUI
import Foundation
import TimeCore

public extension GoalColor {
    var color: Color {
        Color(uiColor: UIColor { trait in
            let h = trait.userInterfaceStyle == .dark ? hex.dark : hex.light
            return UIColor(red: CGFloat((h >> 16) & 0xFF) / 255,
                           green: CGFloat((h >> 8) & 0xFF) / 255,
                           blue: CGFloat(h & 0xFF) / 255,
                           alpha: 1)
        })
    }
}
public extension GoalColor {
    var displayName: String {
        switch self {
        case .red:     String(localized: "Red", bundle: .module)
        case .magenta: String(localized: "Magenta", bundle: .module)
        case .violet:  String(localized: "Violet", bundle: .module)
        case .blue:    String(localized: "Blue", bundle: .module)
        case .cyan:    String(localized: "Cyan", bundle: .module)
        case .green:   String(localized: "Green", bundle: .module)
        case .slate:   String(localized: "Slate", bundle: .module, comment: "Grey-blue goal color")
        }
    }
}
