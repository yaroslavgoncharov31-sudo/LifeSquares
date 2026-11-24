import SwiftUI

enum CardStyle { case primary, secondary }

extension View {
    func cardStyle() -> some View {
        padding(12).background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
