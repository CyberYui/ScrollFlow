import Foundation
import QuartzCore

protocol InputMonitorDelegate: AnyObject {
    func inputMonitorDidDetectUserInput(_ monitor: InputMonitorService)
}

protocol InputMonitorStarting: AnyObject {
    var delegate: InputMonitorDelegate? { get set }
    func start()
    func stop()
}

final class InputMonitorService: InputMonitorStarting {
    weak var delegate: InputMonitorDelegate?
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var lastInputTime: TimeInterval = 0
    private static let debounceInterval: TimeInterval = 2.0

    var isMonitoring: Bool { eventTap != nil }

    deinit {
        stop()
    }

    func start() {
        guard eventTap == nil else { return }

        let eventMask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.scrollWheel.rawValue) |
            (1 << CGEventType.leftMouseDragged.rawValue) |
            (1 << CGEventType.rightMouseDragged.rawValue) |
            (1 << CGEventType.otherMouseDragged.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .tailAppendEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: { _, _, event, userInfo in
                guard let userInfo else { return Unmanaged.passUnretained(event) }
                let service = Unmanaged<InputMonitorService>.fromOpaque(userInfo).takeUnretainedValue()
                service.handleInputEvent()
                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    fileprivate func handleInputEvent() {
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastInputTime >= Self.debounceInterval else { return }
        lastInputTime = now

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.inputMonitorDidDetectUserInput(self)
        }
    }
}

final class MockInputMonitorService: InputMonitorStarting {
    weak var delegate: InputMonitorDelegate?
    private(set) var isRunning = false

    func start() { isRunning = true }
    func stop() { isRunning = false }
}
