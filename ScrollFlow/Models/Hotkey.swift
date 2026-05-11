import AppKit
import Carbon.HIToolbox
import Foundation

struct Hotkey: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    var displayKey: String

    static let defaultValue = Hotkey(
        keyCode: UInt32(kVK_ANSI_S),
        modifiers: UInt32(optionKey | cmdKey),
        displayKey: "S"
    )

    static func from(event: NSEvent) -> Hotkey? {
        let carbonModifiers = Self.carbonModifiers(from: event.modifierFlags)
        guard carbonModifiers != 0 else {
            return nil
        }

        guard let displayKey = displayKey(for: event) else {
            return nil
        }

        return Hotkey(
            keyCode: UInt32(event.keyCode),
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
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased(),
           !characters.isEmpty {
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
