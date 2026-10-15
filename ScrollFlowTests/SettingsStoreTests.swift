import Carbon.HIToolbox
import Foundation
import XCTest
@testable import ScrollFlow

final class SettingsStoreTests: XCTestCase {
    func testLoadReturnsDefaultsWhenStoreIsEmpty() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)

        XCTAssertEqual(store.load(), .default)
    }

    func testSavePersistsSettingsRoundTrip() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = SettingsStore(defaults: defaults)
        let settings = AppSettings(
            scrollSpeed: 9,
            hotkey: Hotkey(keyCode: 1, modifiers: UInt32(cmdKey | shiftKey), displayKey: "S"),
            launchAtLoginEnabled: true,
            scrollDirection: .up,
            smoothMode: false
        )

        store.save(settings)

        XCTAssertEqual(store.load(), settings)
    }
}
