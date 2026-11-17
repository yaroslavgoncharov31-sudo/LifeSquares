import SwiftUI

struct ForecastInfoButton: View {
    @State private var isPresented: Bool = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
                .frame(width: 33, height: 33)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("How forecast works")
        .popover(isPresented: $isPresented) {
            Text("""
                How the forecast works
                It uses your pace so far: the working days it took to close your finished milestones. The remaining ones are assumed to take about the same.

                Example: 2 milestones closed in 10 working days, 4 left → about 20 more working days.

                The forecast appears after your first closed milestone and once about a fifth of the goal’s working days have passed. All milestones count equally. Days off aren’t counted.
                """)
            .font(.footnote)
            .padding()
            .frame(idealWidth: 260)
            .fixedSize(horizontal: false, vertical: true)
            .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    ForecastInfoButton()
}
