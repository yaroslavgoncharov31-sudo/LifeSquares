public enum GoalColor: String, Codable, CaseIterable, Sendable {
    case red, magenta, violet, blue, cyan, green, slate
    public var hex: (light: UInt32, dark: UInt32) {
        switch self {
        case .red:     (0xD6284A, 0xFF6B85)
        case .magenta: (0xB8359E, 0xE87FD0)
        case .violet:  (0x7A4CE0, 0xAD8BFF)
        case .blue:    (0x2F6BFF, 0x6D98FF)
        case .cyan:    (0x0FA3C4, 0x4FD3EE)
        case .green:   (0x12A15F, 0x4FD68F) 
        case .slate:   (0x5F7287, 0xA3B3C6)
        }
    }
}
