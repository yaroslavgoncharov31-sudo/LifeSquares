import SwiftUI
import Foundation
import TimeCore

struct GoalDetailView: View {

    @State private var viewModel: ViewModel

    init(goal: Goal, calendar: Calendar = .autoupdatingCurrent, now: @escaping () -> Date = Date.init) {
        _viewModel = State(initialValue: ViewModel(goal: goal, calendar: calendar, now: now))
    }
    private func milestoneRow(_ m: Milestone) -> some View {
        HStack(spacing: 12) {
            Text(m.title)
                .font(.headline)
            Spacer()
            Button {
                withAnimation(.snappy) { try? viewModel.toggle(m) }
            } label: {
                Image(systemName: m.status == .closed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(m.status == .closed ? viewModel.goal.color.color : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(m.status == .closed ? "Reopen \(m.title)" : "Close \(m.title)")
        }
    }
    private var milestoneSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Milestones · \(viewModel.milestoneText)")
                .padding(6)
                .font(.footnote).textCase(.uppercase).foregroundStyle(.secondary)
            if viewModel.milestones.isEmpty {
                Text("No milestones yet")
            } else {
                VStack {
                    ForEach(viewModel.milestones) { m in
                        milestoneRow(m)
                        if m.id != viewModel.milestones.last?.id {
                            Divider().padding(.leading, 40)
                        }
                    }
                }
                .padding(8)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var insight: some View {
        HStack {
            InsightCard(
                leftValue: viewModel.workingDayText,
                leftLabel: "Working days left",
                rightValue: viewModel.forecastValue,
                rightLabel: viewModel.forecastLabel
            )
        }
    }
    private var summary: some View {
        HStack {
            SummaryCard(
                leftValue: viewModel.dayText,
                leftLabel: "Days passed",
                rightValue: viewModel.milestoneText,
                rightLabel: viewModel.milestoneLabelText ?? ""
            )
        }
        .frame(maxWidth: .infinity)
    }
    var body: some View {
        ScrollView {
            summary
            insight
            VStack(alignment: .leading, spacing: 20) {
                DayGridView(cells: viewModel.cells, color: viewModel.goal.color, accessibilityText: viewModel.gridAccessibilityText)
                    .padding(10)
            }
            milestoneSection
        }
        .background(Color(.systemGroupedBackground))
    }
}

private func q() -> Goal {
    let calendar = Calendar(identifier: .gregorian)
    let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 10, minute: 30))!
    let end   = calendar.date(from: DateComponents(year: 2027, month: 4, day: 15, hour: 10, minute: 30))!
    return Goal(title: "Test", startDay: start, endDay: end,
                color: .slate, offWeekdays: [.saturday, .sunday],
                offDays: [], calendar: calendar)
}
private func qM(goal: Goal) -> Goal {
    let calendar = Calendar(identifier: .gregorian)
    let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 10, minute: 30))!
    let m = Milestone(title: "TEst", targetDay: start, weight: 1)
    let m1 = Milestone(title: "TEst", targetDay: start, weight: 1)
    let m2 = Milestone(title: "TEst", targetDay: start, weight: 1)
    let m3 = Milestone(title: "TEst", targetDay: start, weight: 1)
    m.goal = goal
    m1.goal = goal
    m2.goal = goal
    m3.goal = goal
    return goal
}
#Preview {
    let calendar = Calendar(identifier: .gregorian)
    let now = calendar.date(from: DateComponents(year: 2026, month: 12, day: 28, hour: 10, minute: 30))!
    GoalDetailView(goal: qM(goal: q()), calendar: calendar, now: { now })
}
