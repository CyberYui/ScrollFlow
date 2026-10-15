import AppKit
import Carbon.HIToolbox
import Foundation

struct Hotkey: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    var displayKey: String

    static let defaultValue = Hotkey(
        keyCode: UInt32(kVK_Space),
        modifiers: UInt32(optionKey | cmdKey),
        displayKey: "Space"
    )

    private static let reservedKeyCodes: Set<UInt32> = [
        UInt32(kVK_ANSI_Q),  // ⌘Q
        UInt32(kVK_ANSI_W),  // ⌘W
        UInt32(kVK_Tab) // ⌘Tab
    ]

    private static let reservedWithModifiersKeyCodes: Set<UInt32> = [
        UInt32(kVK_ANSI_Q), UInt32(kVK_ANSI_W), UInt32(kVK_ANSI_H),
        UInt32(kVK_ANSI_C), UInt32(kVK_ANSI_V), UInt32(kVK_ANSI_X),
        UInt32(kVK_ANSI_A), UInt32(kVK_ANSI_Z), UInt32(kVK_ANSI_S),
        UInt32(kVK_ANSI_P), UInt32(kVK_ANSI_N), UInt32(kVK_ANSI_O),
        UInt32(kVK_ANSI_F), UInt32(kVK_ANSI_G)
    ]

    static func isReservedHotkey(keyCode: UInt32, modifiers: UInt32) -> Bool {
        if modifiers == UInt32(cmdKey) && reservedKeyCodes.contains(keyCode) {
            return true
        }
        if modifiers == UInt32(cmdKey) && reservedWithModifiersKeyCodes.contains(keyCode) {
            return true
        }
        if modifiers == UInt32(cmdKey) && keyCode == UInt32(kVK_Space) {
            return true
        }
        return false
    }

    static func from(event: NSEvent) -> Hotkey? {
        let carbonModifiers = Self.carbonModifiers(from: event.modifierFlags)
        guard carbonModifiers != 0 else {
            return nil
        }

        guard let displayKey = displayKey(for: event) else {
            return nil
        }

        let keyCode = UInt32(event.keyCode)
        guard !isReservedHotkey(keyCode: keyCode, modifiers: carbonModifiers) else {
            return nil
        }

        return Hotkey(
            keyCode: keyCode,
            modifiers: carbonModifiers,
            displayKey: displayKey
        )
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var result: UInt32 = 0

        if flags.contains(.command) {
            result |= UInt32(cmdKey)
        }
        if flags.contains(.option) {
            result |= UInt32(optionKey)
        }
        if flags.contains(.shift) {
            result |= UInt32(shiftKey)
        }
        if flags.contains(.control) {
            result |= UInt32(controlKey)
        }

        return result
    }

    static func displayKey(for event: NSEvent) -> String? {
        if let characters = event.charactersIgnoringModifiers?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !characters.isEmpty {
            if characters.count == 1,
               let scalar = characters.unicodeScalars.first,
               CharacterSet.letters.contains(scalar) {
                return characters.uppercased()
            }

            return characters
        }

        switch Int(event.keyCode) {
        case kVK_Space:
            return "Space"
        case kVK_Return:
            return "↩"
        case kVK_Escape:
            return "⎋"
        case kVK_Delete:
            return "⌫"
        case kVK_ForwardDelete:
            return "⌦"
        case kVK_LeftArrow:
            return "←"
        case kVK_RightArrow:
            return "→"
        case kVK_UpArrow:
            return "↑"
        case kVK_DownArrow:
            return "↓"
        default:
            return nil
        }
    }
}
