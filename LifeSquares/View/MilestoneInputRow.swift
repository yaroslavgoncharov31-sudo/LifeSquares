import TimeCore
import SwiftUI

struct MilestoneInputRow: View {
    let range: ClosedRange<Date>
    var isFocused: FocusState<Bool>.Binding
    let onAdd: (String, Date) -> Void

    @State private var title = ""
    @State private var date: Date

    init(in range: ClosedRange<Date>, isFocused: FocusState<Bool>.Binding, onAdd: @escaping (String, Date) -> Void) {
        self.range = range
        self.isFocused = isFocused
        self.onAdd = onAdd
        _date = State(initialValue: min(max(.now, range.lowerBound), range.upperBound))
    }

    private var trimmed: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("New milestone title", text: $title)
                    .characterLimit(Milestone.maxTitleLimit, text: $title)
                    .focused(isFocused)
            }
        }
        HStack {
            DatePicker("Date", selection: $date, in: range, displayedComponents: .date)
                .padding(.trailing, 5)
            Button("Add") {
                onAdd(trimmed, date)
                title = ""
                isFocused.wrappedValue = true
            }
            .buttonStyle(.borderless)
            .disabled(trimmed.isEmpty)
        }

    }
}

