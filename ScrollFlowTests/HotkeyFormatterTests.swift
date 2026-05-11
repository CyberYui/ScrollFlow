import Carbon.HIToolbox
import XCTest
@testable import ScrollFlow

final class HotkeyFormatterTests: XCTestCase {
    func testFormatterBuildsReadableShortcutString() {
        let hotkey = Hotkey(keyCode: 1, modifiers: UInt32(controlKey | optionKey | cmdKey), displayKey: "S")

        XCTAssertEqual(HotkeyFormatter.string(from: hotkey), "⌃⌥⌘S")
    }
}
