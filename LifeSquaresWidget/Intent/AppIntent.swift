import LifeSquaresKit
import WidgetKit
import AppIntents

struct SelectGoalIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Select goal" }
    static var description: IntentDescription { "Choose which goal the widget shows" }

    @Parameter(title: "Goal")
    var goal: GoalEntity?
}
