import Carbon.HIToolbox
import Foundation

enum GlobalHotkeyServiceError: LocalizedError {
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case let .registrationFailed(status):
            return L10n.hotkeyRegistrationFailed(status: status)
        }
    }
}

protocol GlobalHotkeyServiceProtocol {
    func register(_ hotkey: Hotkey, handler: @escaping () -> Void) throws
    func unregister()
}

final class GlobalHotkeyService: GlobalHotkeyServiceProtocol {
    private enum Constants {
        static let hotKeySignature = "SCFL"
        static let hotKeyID: UInt32 = 1
    }

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var handler: (() -> Void)?

    deinit {
        unregister()
    }

    func register(_ hotkey: Hotkey, handler: @escaping () -> Void) throws {
        self.handler = handler
        installHandlerIfNeeded()

        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        guard let signature = fourCharCode(from: Constants.hotKeySignature) else {
            throw GlobalHotkeyServiceError.registrationFailed(OSStatus(paramErr))
        }
        var hotKeyID = EventHotKeyID(signature: signature, id: Constants.hotKeyID)
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

    private func fourCharCode(from string: String) -> OSType? {
        guard string.utf8.count == 4 && string.unicodeScalars.allSatisfy({ $0.isASCII }) else {
            return nil
        }
        return string.utf8.reduce(0) { partialResult, character in
            (partialResult << 8) + OSType(character)
        }
    }
}

final class MockGlobalHotkeyService: GlobalHotkeyServiceProtocol {
    private(set) var registerCallCount = 0
    private(set) var unregisterCallCount = 0
    private(set) var lastHandler: (() -> Void)?

    func register(_ hotkey: Hotkey, handler: @escaping () -> Void) throws {
        registerCallCount += 1
        lastHandler = handler
    }

    func unregister() {
        unregisterCallCount += 1
    }
}
