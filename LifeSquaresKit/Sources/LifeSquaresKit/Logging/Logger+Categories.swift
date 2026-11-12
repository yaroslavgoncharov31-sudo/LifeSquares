import os

public extension Logger {
    private static let subsystem = "com.yaroslavgoncharov.LifeSquares"

    static let persistance = Logger(subsystem: subsystem, category: "persistance")
    static let widget = Logger(subsystem: subsystem, category: "widget")
}
