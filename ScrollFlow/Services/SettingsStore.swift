import Foundation

final class SettingsStore {
    private enum Keys {
        static let scrollSpeed = "settings.scrollSpeed"
        static let hotkey = "settings.hotkey"
        static let launchAtLogin = "settings.launchAtLogin"
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
            settings.scrollSpeed = defaults.double(forKey: Keys.scrollSpeed)
        }

        if let data = defaults.data(forKey: Keys.hotkey),
           let hotkey = try? decoder.decode(Hotkey.self, from: data) {
            settings.hotkey = hotkey
        }

        if defaults.object(forKey: Keys.launchAtLogin) != nil {
            settings.launchAtLoginEnabled = defaults.bool(forKey: Keys.launchAtLogin)
        }

        return settings
    }

    func save(_ settings: AppSettings) {
        defaults.set(settings.scrollSpeed, forKey: Keys.scrollSpeed)
        defaults.set(settings.launchAtLoginEnabled, forKey: Keys.launchAtLogin)

        if let encodedHotkey = try? encoder.encode(settings.hotkey) {
            defaults.set(encodedHotkey, forKey: Keys.hotkey)
        }
    }
}
