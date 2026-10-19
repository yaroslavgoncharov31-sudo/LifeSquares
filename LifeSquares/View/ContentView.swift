import SwiftUI
import TimeCore

struct ContentView: View {

    var body: some View {
        VStack{
            Text("oqoqoqooqq slate")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(GoalColor.slate.color)
            Text("oqoqoqooqq orchid")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(GoalColor.magenta.color)
            Text("oqoqoqooqq violet")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(GoalColor.violet.color)
            Text("oqoqoqooqq blue")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(GoalColor.blue.color)
            Text("oqoqoqooqq indigo")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(GoalColor.red.color)
            Text("oqoqoqooqq sky")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(GoalColor.green.color)
            Text("oqoqoqooqq teal")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(GoalColor.violet.color)
            Text("oqoqoqooqq mint")
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(GoalColor.cyan.color)
        }
    }
}

#Preview {
    ContentView()
        .backgroundStyle(.secondary)
}
