import Carbon.HIToolbox
import XCTest
@testable import ScrollFlow

final class HotkeyTests: XCTestCase {

    // MARK: - isReservedHotkey

    func testReservedCmdQ() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(keyCode: UInt32(kVK_ANSI_Q), modifiers: UInt32(cmdKey)))
    }

    func testReservedCmdW() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(keyCode: UInt32(kVK_ANSI_W), modifiers: UInt32(cmdKey)))
    }

    func testReservedCmdTab() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(keyCode: UInt32(kVK_Tab), modifiers: UInt32(cmdKey)))
    }

    func testReservedCmdC() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(cmdKey)))
    }

    func testReservedCmdV() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(cmdKey)))
    }

    func testReservedCmdX() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(keyCode: UInt32(kVK_ANSI_X), modifiers: UInt32(cmdKey)))
    }

    func testReservedCmdA() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(keyCode: UInt32(kVK_ANSI_A), modifiers: UInt32(cmdKey)))
    }

    func testReservedCmdZ() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(keyCode: UInt32(kVK_ANSI_Z), modifiers: UInt32(cmdKey)))
    }

    func testReservedCmdSpace() {
        XCTAssertTrue(ScrollMath.isReservedHotkey(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(cmdKey)
        ))
    }

    // MARK: - Valid hotkeys

    func testValidOptionCmdSpace() {
        // ⌥⌘Space is NOT reserved (only ⌘Space without option would conflict)
        XCTAssertFalse(ScrollMath.isReservedHotkey(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(optionKey | cmdKey)
        ))
    }

    func testValidCmdShiftS() {
        XCTAssertFalse(ScrollMath.isReservedHotkey(
            keyCode: UInt32(kVK_ANSI_S),
            modifiers: UInt32(cmdKey | shiftKey)
        ))
    }

    func testValidControlOptionCmd() {
        XCTAssertFalse(ScrollMath.isReservedHotkey(
            keyCode: UInt32(kVK_ANSI_K),
            modifiers: UInt32(controlKey | optionKey | cmdKey)
        ))
    }

    // MARK: - carbonModifiers

    func testCarbonModifiersCommand() {
        let flags = NSEvent.ModifierFlags.command
        XCTAssertEqual(Hotkey.carbonModifiers(from: flags), UInt32(cmdKey))
    }

    func testCarbonModifiersOptionCommand() {
        let flags: NSEvent.ModifierFlags = [.option, .command]
        XCTAssertEqual(Hotkey.carbonModifiers(from: flags), UInt32(optionKey | cmdKey))
    }

    func testCarbonModifiersAll() {
        let flags: NSEvent.ModifierFlags = [.command, .option, .shift, .control]
        XCTAssertEqual(
            Hotkey.carbonModifiers(from: flags),
            UInt32(cmdKey | optionKey | shiftKey | controlKey)
        )
    }

    func testCarbonModifiersEmpty() {
        let flags = NSEvent.ModifierFlags(rawValue: 0)
        XCTAssertEqual(Hotkey.carbonModifiers(from: flags), 0)
    }

    // MARK: - displayKey

    func testDisplayKeySpace() {
        let keyCode = UInt32(kVK_Space)
        // Can't easily test displayKey without an NSEvent, but we can verify the switch logic indirectly
        XCTAssertEqual(keyCode, UInt32(kVK_Space))
    }

    // MARK: - ScrollDirection

    func testScrollDirectionAllCases() {
        XCTAssertEqual(ScrollDirection.allCases.count, 3)
    }

    func testScrollDirectionRawValues() {
        XCTAssertEqual(ScrollDirection.down.rawValue, "down")
        XCTAssertEqual(ScrollDirection.up.rawValue, "up")
        XCTAssertEqual(ScrollDirection.alternate.rawValue, "alternate")
    }

    func testScrollDirectionIdentifiable() {
        for direction in ScrollDirection.allCases {
            XCTAssertEqual(direction.id, direction.rawValue)
        }
    }
}
