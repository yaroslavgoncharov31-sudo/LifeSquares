import os

public extension Logger {
    private static let subsystem = "com.yaroslavgoncharov.LifeSquares"

    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let widget = Logger(subsystem: subsystem, category: "widget")
}
