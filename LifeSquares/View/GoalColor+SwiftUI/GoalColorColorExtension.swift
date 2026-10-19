import SwiftUI
import Foundation
import TimeCore

extension GoalColor {
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
