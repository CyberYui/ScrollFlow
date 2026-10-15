import Foundation

final class SettingsStore {
    private enum Keys {
        static let scrollSpeed = "settings.scrollSpeed"
        static let hotkey = "settings.hotkey"
        static let launchAtLogin = "settings.launchAtLogin"
        static let scrollDirection = "settings.scrollDirection"
        static let smoothMode = "settings.smoothMode"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AppSettings {
        var settings = AppSettings.default

        if defaults.object(forKey: Keys.scrollSpeed) != nil {
            let loaded = defaults.double(forKey: Keys.scrollSpeed)
            if loaded >= AppSettings.minimumScrollSpeed && loaded <= AppSettings.maximumScrollSpeed {
                settings.scrollSpeed = loaded
            }
        }

        if let data = defaults.data(forKey: Keys.hotkey),
           let hotkey = try? decoder.decode(Hotkey.self, from: data) {
            settings.hotkey = hotkey
        }

        if defaults.object(forKey: Keys.launchAtLogin) != nil {
            settings.launchAtLoginEnabled = defaults.bool(forKey: Keys.launchAtLogin)
        }

        if let rawValue = defaults.string(forKey: Keys.scrollDirection),
           let direction = ScrollDirection(rawValue: rawValue) {
            settings.scrollDirection = direction
        }

        if defaults.object(forKey: Keys.smoothMode) != nil {
            settings.smoothMode = defaults.bool(forKey: Keys.smoothMode)
        }

        return settings
    }

    func save(_ settings: AppSettings) {
        defaults.set(settings.scrollSpeed, forKey: Keys.scrollSpeed)
        defaults.set(settings.launchAtLoginEnabled, forKey: Keys.launchAtLogin)
        defaults.set(settings.scrollDirection.rawValue, forKey: Keys.scrollDirection)
        defaults.set(settings.smoothMode, forKey: Keys.smoothMode)

        if let encodedHotkey = try? encoder.encode(settings.hotkey) {
            defaults.set(encodedHotkey, forKey: Keys.hotkey)
        }
    }
}
