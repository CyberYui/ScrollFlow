import Carbon.HIToolbox
import XCTest
@testable import ScrollFlow

final class SettingsStoreExtendedTests: XCTestCase {

    // MARK: - Reset to defaults

    func testResetToDefault() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        let custom = AppSettings(
            scrollSpeed: 9.0,
            hotkey: Hotkey(keyCode: 1, modifiers: UInt32(cmdKey | shiftKey), displayKey: "S"),
            launchAtLoginEnabled: true,
            scrollDirection: .up,
            smoothMode: false
        )
        store.save(custom)

        var loaded = store.load()
        XCTAssertEqual(loaded.scrollSpeed, 9.0)
        XCTAssertEqual(loaded.scrollDirection, .up)
        XCTAssertFalse(loaded.smoothMode)

        loaded = .default
        XCTAssertEqual(loaded.scrollSpeed, AppSettings.defaultScrollSpeed)
        XCTAssertEqual(loaded.scrollDirection, .down)
        XCTAssertTrue(loaded.smoothMode)
    }

    // MARK: - Corrupted data

    func testCorruptedSpeedDataFallsBackToDefault() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        defaults.set("not a number", forKey: "settings.scrollSpeed")
        let loaded = store.load()
        XCTAssertEqual(loaded.scrollSpeed, AppSettings.defaultScrollSpeed)
    }

    func testCorruptedHotkeyDataFallsBackToDefault() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        defaults.set("not json".data(using: .utf8)!, forKey: "settings.hotkey")
        let loaded = store.load()
        XCTAssertEqual(loaded.hotkey, Hotkey.defaultValue)
    }

    func testCorruptedLaunchAtLoginFallsBackToDefault() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        defaults.set("not a bool", forKey: "settings.launchAtLogin")
        let loaded = store.load()
        XCTAssertFalse(loaded.launchAtLoginEnabled)
    }

    // MARK: - New fields round-trip

    func testScrollDirectionRoundTrip() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        let original = AppSettings(
            scrollSpeed: 6.0,
            hotkey: Hotkey(keyCode: 0, modifiers: UInt32(optionKey | cmdKey), displayKey: "Space"),
            launchAtLoginEnabled: false,
            scrollDirection: .alternate,
            smoothMode: false
        )
        store.save(original)
        XCTAssertEqual(store.load(), original)
    }

    func testSmoothModeRoundTrip() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        let original = AppSettings(
            scrollSpeed: 6.0,
            hotkey: Hotkey(keyCode: 0, modifiers: UInt32(optionKey | cmdKey), displayKey: "Space"),
            launchAtLoginEnabled: false,
            scrollDirection: .down,
            smoothMode: false
        )
        store.save(original)
        XCTAssertEqual(store.load().smoothMode, false)
    }
}
