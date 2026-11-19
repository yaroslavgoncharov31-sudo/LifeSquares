import TimeCore
import SwiftUI
import LifeSquaresKit

struct GoalCard: View {
    let title: String
    let color: GoalColor
    let snapshot: GoalSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .lineLimit(2, reservesSpace: true)
            MiniGridView(totalDays: snapshot.timeline.totalDays, elapsedDays: snapshot.timeline.elapsedDays, todayIndex: snapshot.todayIndex, color: color)
            HStack {
                Text(snapshot.dayText)
                Spacer()
                Text(snapshot.milestoneText)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    GoalCard(
        title: "Read every day",
        color: .green,
        snapshot: PreviewData.snapshot(
            start: PreviewData.date(2026, 10, 1),
            days: 4,
            now: PreviewData.date(2026, 10, 31)
        ))
}
#endif
