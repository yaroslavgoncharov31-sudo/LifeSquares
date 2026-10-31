import Foundation
import TimeCore
import SwiftUI
import SwiftData

struct GoalAddView: View {
    private enum Field: Hashable {
        case goalTitle, duration, milestoneTitle
    }
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel: ViewModel
    @State private var saveError: GoalFormError?
    @State private var newOffDay = Date()
    @State private var newMilestoneDate = Date()
    @State private var newMilestoneTitle: String = ""
    @State private var durationText: String = ""
    @FocusState private var focus: Field?

    init(goal: Goal? = nil) {
        if let goal {
            _viewModel = State(wrappedValue: ViewModel(goal: goal))
        } else {
            _viewModel = State(wrappedValue: ViewModel())
        }
    }
    private var titleSection: some View {
        Section("Title") {
            TextField("e.g. Read every day", text: $viewModel.title)
                .focused($focus, equals: .goalTitle)
        }
    }
    private var termSection: some View {
        Section {
            DatePicker("Start", selection: $viewModel.startDay, displayedComponents: .date)

            LabeledContent("Duration") {
                TextField("Days", text: $durationText)
                    .keyboardType(.numberPad)
                    .onAppear { durationText = String(viewModel.durationDays) }
                    .onChange(of: durationText) { old, new in
                        let digits = new.filter { $0.isASCII && $0.isNumber }
                        if let value = Int(digits), value > GoalAddView.ViewModel.maxDuration {
                            durationText = old
                            return
                        }
                        if digits != new {
                            durationText = digits
                            return
                        }
                        viewModel.durationDays = Int(digits) ?? 0
                    }
                    .multilineTextAlignment(.trailing)
                    .focused($focus, equals: .duration)
            }

            HStack(spacing: 8) {
                ForEach(ViewModel.durationPresets, id: \.self) { days in
                    Button {
                        viewModel.durationDays = days
                    } label: {
                        Text("\(days)")
                            .monospacedDigit()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.durationDays == days ? .accentColor : .secondary)
                }
            }
            if viewModel.durationDays == 0 {
                Text("Specify duration first")
            } else {
                LabeledContent("End", value: viewModel.endDay.formatted(date: .abbreviated, time: .omitted))
            }
        } header: {
            Text("Term")
        } footer: {
            if viewModel.validationIssues.contains(.durationOutOfRange) {
                Text("From 1 to 3650 days")
            }
        }
        .onChange(of: viewModel.durationDays) { _, new in
            if Int(durationText) != new { durationText = String(new) }
        }
    }
    private var colorSection: some View {
        Section("Color") {
            HStack(spacing: 0) {
                ForEach(GoalColor.allCases, id: \.rawValue) { color in
                    let isSelected = viewModel.color == color
                    Button {
                        viewModel.color = color
                    } label: {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.title2)
                            .foregroundStyle(color.color)
                            .padding(6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(.primary, lineWidth: isSelected ? 2 : 0)
                            }
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(color.rawValue.capitalized)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])

                }
            }
        }
    }
    private var weekdaySection: some View {
        Section {
            HStack {
                ForEach(viewModel.orderedWeekdays, id: \.self) { weekday in
                    Button(viewModel.weekdaySymbol(weekday)) {
                        viewModel.toggleWeekday(weekday)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    .tint(viewModel.isOff(weekday) ? .accentColor : .secondary)
                }
            }
        } header: {
            Text("Non-working days")
        } footer: {
            if viewModel.durationDays > 0 {
                Text("\(viewModel.availability.totalAvailable) out of \(viewModel.availability.timeline.totalDays) days available")
            }
        }
    }
    private var offDaySection: some View {
        Section {
            ForEach(viewModel.offDays, id: \.self) { day in
                Text(day.formatted(date: .abbreviated, time: .omitted))
            }
            .onDelete { indexSet in
                indexSet.map { viewModel.offDays[$0] }.forEach(viewModel.removeOffDay)
            }
            HStack {
                if let range = viewModel.offDayRange {
                    DatePicker("Date", selection: $newOffDay, in: range, displayedComponents: .date)
                        .labelsHidden()
                    Spacer()
                    Button("Add") {
                        withAnimation {
                            viewModel.addOffDay(newOffDay)
                        }
                    }
                    .disabled(viewModel.offDays.last == newOffDay)
                    .buttonStyle(.borderless)
                } else {
                    Text("Specify duration first")
                        .foregroundStyle(.primary)
                }
            }
        } header: {
            Text("Specific non-working dates")
        } footer: {
            Text("Days off don't move the end date")
        }
    }
    private var milestoneSection: some View {
        Section {
            ForEach(viewModel.milestones) { m in
                LabeledContent(m.title, value: "day \(m.dayNumber)")
            }
            .onDelete { indexSet in
                indexSet.map { viewModel.milestones[$0] }.forEach(viewModel.removeMilestone)
            }
            HStack {

                if let range = viewModel.offDayRange {
                    TextField("New milestone title", text: $newMilestoneTitle)
                        .focused($focus, equals: .milestoneTitle)
                    DatePicker("", selection: $newMilestoneDate, in: range, displayedComponents: .date)
                        .labelsHidden()
                    Spacer()
                    Button("Add") {
                        withAnimation {
                            viewModel.addMilestone(title: newMilestoneTitle, on: newMilestoneDate)
                            newMilestoneTitle = ""
                            focus = .milestoneTitle
                        }
                    }
                    .buttonStyle(.borderless)
                    .disabled(newMilestoneTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else {
                    Text("Specify duration first")
                        .foregroundStyle(.primary)
                }

            }

        } header: {
            Text("Milestones")
        } footer: {
            Text("You can add milestones later")
        }
    }
    var body: some View {
        Form {
            titleSection
            termSection
            colorSection
            weekdaySection
            offDaySection
            milestoneSection
        }
        .navigationTitle(viewModel.isEditing ? "Edit goal" : "New goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isEditing ? "Save" : "Create") { save() }
                    .disabled(!viewModel.isValid)
            }
        }
        .alert("Couldn't save", isPresented: .constant(saveError != nil), presenting: saveError) { _ in
            Button("OK") { saveError = nil
            }
        }  message: { error in
            Text(error.errorDescription ?? "")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button { focus = nil } label: { Image(systemName: "checkmark") }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    private func save() {
        do {
            try viewModel.save(in: context)
            dismiss()
        } catch let error as GoalFormError {
            saveError = error
        } catch {
            saveError = .saveFailed(underlying: error)
        }
    }
}

#Preview {
    NavigationStack { GoalAddView() }
}
