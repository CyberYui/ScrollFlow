import Foundation

struct AppSettings: Codable, Equatable {
    var scrollSpeed: Double
    var hotkey: Hotkey
    var launchAtLoginEnabled: Bool

    static let `default` = AppSettings(
        scrollSpeed: 6,
        hotkey: .defaultValue,
        launchAtLoginEnabled: false
    )
}
