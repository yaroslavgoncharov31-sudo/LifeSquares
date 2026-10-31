import SwiftUI
import TimeCore

struct DayCell: View {
    let cell: DayCellModel
    let color: GoalColor
    private let cornerRadius: CGFloat = 4
    private var fillColor: Color {
        switch cell.state {
        case .past: color.color
        case .today, .future: .clear
        }
    }
    private var borderColor: Color {
        switch cell.state {
        case .past: .clear
        case .today: .primary
        case .future: color.color
        }
    }
    private var dotColor: Color {
        cell.state == .past ? Color(.systemBackground) : color.color
    }
    private var borderWidth: CGFloat {
        cell.state == .today ? 3 : 1
    }
    private var showSlash: Bool {
        cell.state == .future && !cell.isAvailable
    }
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(fillColor)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }
            .overlay {
                if showSlash {
                    Diagonal()
                        .stroke(color.color, lineWidth: 1)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
            }
            .overlay {
                if cell.hasMilestone {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 7, height: 7)
                        .padding(3)

                }
            }
    }
}

#Preview {
    DayCell(cell: DayCellModel(id: 1, state: .future, isAvailable: true, hasMilestone: true), color: .magenta)
}
#Preview {
    DayCell(cell: DayCellModel(id: 1, state: .today, isAvailable: true, hasMilestone: false), color: .slate)
}
#Preview {
    DayCell(cell: DayCellModel(id: 1, state: .future, isAvailable: true, hasMilestone: false), color: .slate)
}
#Preview {
    DayCell(cell: DayCellModel(id: 1, state: .future, isAvailable: false, hasMilestone: false), color: .slate)
}
#Preview {
    DayCell(cell: DayCellModel(id: 1, state: .past, isAvailable: true, hasMilestone: true), color: .slate)
}
#Preview {
    DayCell(cell: DayCellModel(id: 1, state: .today, isAvailable: true, hasMilestone: true), color: .slate)
}
#Preview {
    DayCell(cell: DayCellModel(id: 1, state: .future, isAvailable: true, hasMilestone: true), color: .slate)
}
#Preview {
    DayCell(cell: DayCellModel(id: 1, state: .future, isAvailable: false, hasMilestone: true), color: .slate)
}
