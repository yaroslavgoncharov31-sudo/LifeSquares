import TimeCore
import SwiftUI

struct InsightCard: View {

    let leftValue: String
    let leftLabel: String
    let rightValue: String
    let rightLabel: String
    let style: Style = .secondary

    private var valueFont: Font { style == .primary ? .largeTitle : .title3.weight(.semibold) }
    private var labelFont: Font { style == .primary ? .footnote : .caption }
    private var padding: CGFloat { style == .primary ? 16 : 12 }

    private func column(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(valueFont).monospacedDigit()
            Text(label).font(labelFont).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var body: some View {
        HStack(spacing: 16) {
            column(value: leftValue, label: leftLabel)
            Divider()
            column(value: rightValue, label: rightLabel)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(padding)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}


#Preview {
    InsightCard(leftValue: "45/180", leftLabel: "qweety", rightValue: "150", rightLabel: "qewrty")
}
