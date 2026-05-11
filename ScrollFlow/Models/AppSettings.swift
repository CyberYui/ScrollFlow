import Foundation

struct AppSettings: Codable, Equatable {
    static let minimumScrollSpeed = 1.0
    static let maximumScrollSpeed = 12.0
    static let defaultScrollSpeed = 6.0

    var scrollSpeed: Double
    var hotkey: Hotkey
    var launchAtLoginEnabled: Bool

    static let `default` = AppSettings(
        scrollSpeed: defaultScrollSpeed,
        hotkey: .defaultValue,
        launchAtLoginEnabled: false
    )
}
