import TimeCore
import LifeSquaresKit
import SwiftUI

struct BigDayNumber: View {
    let snapshot: GoalSnapshot
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(snapshot.timeline.elapsedDays, format: .number)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("/\(snapshot.timeline.totalDays)")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

struct BigMilestoneNumber: View {
    let snapshot: GoalSnapshot
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(snapshot.progress.closed, format: .number)
                .font(.system(.title3, design: .rounded, weight: .bold))
            Text("/\(snapshot.progress.total)")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}
