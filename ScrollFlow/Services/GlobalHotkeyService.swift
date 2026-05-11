import Carbon.HIToolbox
import Foundation

enum GlobalHotkeyServiceError: LocalizedError {
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case let .registrationFailed(status):
            return "全局快捷键注册失败（OSStatus: \(status)）。"
        }
    }
}

final class GlobalHotkeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var handler: (() -> Void)?

    func register(_ hotkey: Hotkey, handler: @escaping () -> Void) throws {
        self.handler = handler
        installHandlerIfNeeded()

        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        var hotKeyID = EventHotKeyID(signature: fourCharCode(from: "SCFL"), id: 1)
        let status = RegisterEventHotKey(
            hotkey.keyCode,
            hotkey.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            throw GlobalHotkeyServiceError.registrationFailed(status)
        }
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    private func installHandlerIfNeeded() {
        guard eventHandlerRef == nil else {
            return
        }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData else {
                    return noErr
                }

                let service = Unmanaged<GlobalHotkeyService>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    service.handler?()
                }
                return noErr
            },
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandlerRef
        )
    }

    private func fourCharCode(from string: String) -> OSType {
        string.utf8.reduce(0) { partialResult, character in
            (partialResult << 8) + OSType(character)
        }
    }
}
