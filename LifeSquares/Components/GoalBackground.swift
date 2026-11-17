import Foundation
import SwiftUI

struct GoalBackground: View {
    let color: Color

    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0],   [0.5, 0],   [1, 0],
                [0, 0.5], [0.6, 0.4], [1, 0.5],
                [0, 1],   [0.5, 1],   [1, 1]
            ],
            colors: [
                color.opacity(0.45), color.opacity(0.30), color.opacity(0.40),
                color.opacity(0.15), color.opacity(0.10), color.opacity(0.20),
                .clear,              .clear,              .clear
            ]
        )
    }
}

