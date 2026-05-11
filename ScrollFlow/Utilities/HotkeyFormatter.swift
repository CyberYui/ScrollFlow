import Carbon.HIToolbox
import Foundation

enum HotkeyFormatter {
    static func string(from hotkey: Hotkey) -> String {
        var result = ""

        if hotkey.modifiers & UInt32(controlKey) != 0 {
            result += "⌃"
        }
        if hotkey.modifiers & UInt32(shiftKey) != 0 {
            result += "⇧"
        }
        if hotkey.modifiers & UInt32(optionKey) != 0 {
            result += "⌥"
        }
        if hotkey.modifiers & UInt32(cmdKey) != 0 {
            result += "⌘"
        }

        return result + hotkey.displayKey
    }
}
