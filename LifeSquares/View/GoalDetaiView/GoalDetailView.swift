import SwiftUI
import Foundation
import TimeCore
import SwiftData
import LifeSquaresKit

struct GoalDetailView: View {

    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State private var showEdit = false
    @State private var showDeleteConfirmation = false
    @State private var hapticTrigger = false
    @State private var viewModel: ViewModel
    @FocusState private var isMilestoneFocused: Bool


    init(goal: Goal, calendar: Calendar = .autoupdatingCurrent, now: @escaping () -> Date = Date.init) {
        _viewModel = State(initialValue: ViewModel(goal: goal, calendar: calendar, now: now))
    }
    private func milestoneRow(_ m: Milestone) -> some View {
        let isClosed = m.status == .closed
        return HStack(spacing: 12) {
            ZStack(alignment: .leading) {
                Text(m.title)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(m.status == .closed ? .secondary : .primary)
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.gray.opacity(0.5))
                    .scaleEffect(x: isClosed ? 1 : 0, anchor: .leading)
            }
            .animation(.easeInOut(duration: 0.3), value: isClosed)
            Spacer()
            if viewModel.isReadOnly {
                Image(systemName: m.status == .closed ? "checkmark.circle.fill" : "circle")
            } else {
                Button {
                    withAnimation(.snappy) { try? viewModel.toggle(m) }
                    hapticTrigger.toggle()
                } label: {
                    Image(systemName: m.status == .closed ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(m.status == .closed ? viewModel.goal.color.color : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .sensoryFeedback(.impact, trigger: hapticTrigger)
                .buttonStyle(.plain)
                .accessibilityLabel(m.status == .closed ? "Reopen \(m.title)" : "Close \(m.title)")
            }
        }
    }
    private var milestoneSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack {
                ForEach(viewModel.milestones) { m in
                    milestoneRow(m)
                    if m.id != viewModel.milestones.last?.id {
                        Divider().padding(.leading, 20)
                    }
                }
                if !viewModel.isReadOnly {
                    if !viewModel.milestones.isEmpty {
                        Divider()
                    }
                    if let range = viewModel.goalRange {
                        MilestoneInputRow(in: range, isFocused: $isMilestoneFocused) { title, date in
                            viewModel.goal.addMilestone(title: title, on: date)
                            viewModel.refresh()
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var insight: some View {
        InsightCard(
            leftValue: viewModel.snapshot.workingDayText,
            leftLabel: String(localized: "Working days left"),
            rightValue: viewModel.snapshot.forecast.forecastValue,
            rightLabel: viewModel.snapshot.forecast.forecastLabel,
            style: .secondary
        )

    }
    private var summary: some View {
        SummaryCard(
            leftValue: viewModel.snapshot.dayText,
            leftLabel:  String(localized: "Days passed"),
            rightValue: viewModel.snapshot.milestoneText,
            rightLabel: viewModel.snapshot.milestoneLabelText,
            style: .primary
        )
        .frame(maxWidth: .infinity)
    }
    var body: some View {
        ScrollView {
            summary
            insight
            VStack(alignment: .leading, spacing: 20) {
                DayGridView(cells: (viewModel.isGridExpanded ? viewModel.cells : viewModel.snapshot.windowCells()), color: viewModel.goal.color, accessibilityText: viewModel.snapshot.gridAccessibilityText)
                    .padding(10)
            }
            milestoneSection
        }
        .navigationTitle(viewModel.goal.title)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    withAnimation(.snappy) { viewModel.isGridExpanded.toggle() }
                } label: {
                    Image(systemName: viewModel.isGridExpanded ? "rectangle.compress.vertical"
                          : "rectangle.expand.vertical")
                }
                .accessibilityLabel(viewModel.isGridExpanded ? "Collapse days" : "Show all days")

                Menu {
                    if !viewModel.isReadOnly {
                        Button("Edit", systemImage: "pencil") { showEdit = true; isMilestoneFocused = false }
                    }
                    Button("Delete", systemImage: "trash", role: .destructive) { showDeleteConfirmation = true }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showEdit, onDismiss: { viewModel.refresh() }) {
            NavigationStack { GoalAddView(goal: viewModel.goal) }
        }
        .alert("Delete \(viewModel.goal.title)?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) { deleteGoal() }
        } message: {
            Text("The goal and all its milestones will be removed. This action can't be undone")
        }
        .sensoryFeedback(.warning, trigger: showDeleteConfirmation) { _, isShown in isShown }
        .background(Color(.systemGroupedBackground))
    }
    private func deleteGoal() {
        try? viewModel.deleteGoal()
        dismiss()
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
    let m = Milestone(title: "TEst", targetDay: start)
    let m1 = Milestone(title: "TEst", targetDay: start)
    let m2 = Milestone(title: "TEst", targetDay: start)
    let m3 = Milestone(title: "TEst", targetDay: start)
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
