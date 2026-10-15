import Foundation

enum ScrollDirection: String, Codable, CaseIterable, Identifiable {
    case down
    case up
    case alternate

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .down: return "arrow.down"
        case .up: return "arrow.up"
        case .alternate: return "arrow.up.arrow.down"
        }
    }

    var label: String {
        switch self {
        case .down: return "向下"
        case .up: return "向上"
        case .alternate: return "交替"
        }
    }
}

struct AppSettings: Codable, Equatable {
    static let minimumScrollSpeed = 1.0
    static let maximumScrollSpeed = 12.0
    static let defaultScrollSpeed = 6.0

    var scrollSpeed: Double
    var hotkey: Hotkey
    var launchAtLoginEnabled: Bool
    var scrollDirection: ScrollDirection
    var smoothMode: Bool

    static let `default` = AppSettings(
        scrollSpeed: defaultScrollSpeed,
        hotkey: .defaultValue,
        launchAtLoginEnabled: false,
        scrollDirection: .down,
        smoothMode: true
    )
}
