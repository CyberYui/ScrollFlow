import ApplicationServices
import Carbon.HIToolbox
import CoreVideo
import Foundation
import QuartzCore

final class ScrollService {
    private enum Constants {
        static let pixelsPerSpeedUnit = 8.0
        static let maxDeltaTime: CFTimeInterval = 0.1
        static let maxAccumulatedDelta: Double = 500.0
        static let smoothModeSubSteps = 3
    }

    private let stateQueue = DispatchQueue(label: "com.scrollflow.scroll.state")
    private var displayLink: CVDisplayLink?
    private var isStopped = true
    private var _currentSpeed: Double = AppSettings.default.scrollSpeed
    private var _direction: ScrollDirection = .down
    private var _smoothMode: Bool = true
    private var accumulatedDelta = 0.0
    private var lastTime: CFTimeInterval = 0
    private var alternateDirectionUp = false
    private var lastAlternateTime: CFTimeInterval = 0
    private static let alternateInterval: CFTimeInterval = 5.0

    private var currentSpeed: Double {
        get { stateQueue.sync { _currentSpeed } }
        set { stateQueue.sync { _currentSpeed = newValue } }
    }

    deinit {
        stop()
    }

    func start(speed: Double, direction: ScrollDirection = .down, smoothMode: Bool = true) {
        stateQueue.sync {
            isStopped = false
            _currentSpeed = clamped(speed)
            _direction = direction
            _smoothMode = smoothMode
            accumulatedDelta = 0.0
            lastTime = CACurrentMediaTime()
            lastAlternateTime = 0
            alternateDirectionUp = false
        }
        stopDisplayLink()

        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let displayLink = link else { return }

        let callback: CVDisplayLinkOutputCallback = { _, _, _, _, _, userInfo in
            guard let userInfo else { return kCVReturnSuccess }
            let service = Unmanaged<ScrollService>.fromOpaque(userInfo).takeUnretainedValue()
            service.emitScrollTick()
            return kCVReturnSuccess
        }

        CVDisplayLinkSetOutputCallback(displayLink, callback, Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkStart(displayLink)

        stateQueue.sync {
            if isStopped {
                CVDisplayLinkStop(displayLink)
            } else {
                self.displayLink = displayLink
            }
        }
    }

    func update(speed: Double, direction: ScrollDirection? = nil, smoothMode: Bool? = nil) {
        stateQueue.sync {
            if !isStopped {
                _currentSpeed = clamped(speed)
                if let direction { _direction = direction }
                if let smoothMode { _smoothMode = smoothMode }
            }
        }
    }

    func stop() {
        stateQueue.sync {
            isStopped = true
        }
        stopDisplayLink()
        stateQueue.sync {
            accumulatedDelta = 0.0
        }
    }

    private func stopDisplayLink() {
        let link = stateQueue.sync { displayLink }
        if let link {
            CVDisplayLinkStop(link)
            stateQueue.sync {
                if displayLink === link {
                    displayLink = nil
                }
            }
        }
    }

    private func emitScrollTick() {
        guard !stateQueue.sync(execute: { isStopped }) else { return }

        let now = CACurrentMediaTime()
        let deltaTime = stateQueue.sync { () -> CFTimeInterval in
            let dt = now - lastTime
            lastTime = now
            return dt
        }

        guard deltaTime <= Constants.maxDeltaTime else {
            stateQueue.sync {
                accumulatedDelta = 0.0
                lastTime = CACurrentMediaTime()
            }
            return
        }

        let speed = currentSpeed
        let (delta, shouldPost) = stateQueue.sync { () -> (Int32, Bool) in
            accumulatedDelta += speed * Constants.pixelsPerSpeedUnit * deltaTime * 60.0

            if abs(accumulatedDelta) > Constants.maxAccumulatedDelta {
                accumulatedDelta = 0.0
                lastTime = CACurrentMediaTime()
                return (0, false)
            }

            let value = Int32(accumulatedDelta.rounded(.towardZero))
            guard value != 0 else { return (0, false) }

            accumulatedDelta -= Double(value)
            return (value, true)
        }

        guard shouldPost, delta != 0 else { return }

        let directionMultiplier = stateQueue.sync { () -> Int32 in
            switch _direction {
            case .down:
                return -1
            case .up:
                return 1
            case .alternate:
                if lastAlternateTime == 0 {
                    lastAlternateTime = CACurrentMediaTime()
                    alternateDirectionUp = false
                    return -1
                }
                let elapsed = CACurrentMediaTime() - lastAlternateTime
                if elapsed >= Self.alternateInterval {
                    lastAlternateTime = CACurrentMediaTime()
                    alternateDirectionUp.toggle()
                }
                return alternateDirectionUp ? 1 : -1
            }
        }

        let finalDelta = delta * directionMultiplier

        if _smoothMode {
            let subDelta = Double(finalDelta) / Double(Constants.smoothModeSubSteps)
            var remainder = Double(finalDelta)
            for _ in 0..<Constants.smoothModeSubSteps {
                let step = Int32(subDelta.rounded())
                remainder -= Double(step)
                postScrollEvent(delta: step)
            }
            if remainder != 0 {
                postScrollEvent(delta: Int32(remainder.rounded()))
            }
        } else {
            postScrollEvent(delta: finalDelta)
        }
    }

    private func postScrollEvent(delta: Int32) {
        guard delta != 0 else { return }
        guard let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 1,
            wheel1: delta,
            wheel2: 0,
            wheel3: 0
        ) else {
            return
        }
        event.post(tap: .cghidEventTap)
    }

    private func clamped(_ speed: Double) -> Double {
        min(max(speed, AppSettings.minimumScrollSpeed), AppSettings.maximumScrollSpeed)
    }
}

// MARK: - Testable pure functions

enum ScrollMath {
    static func clamped(_ speed: Double) -> Double {
        min(max(speed, AppSettings.minimumScrollSpeed), AppSettings.maximumScrollSpeed)
    }

    static func accumulatedDelta(speed: Double, deltaTime: CFTimeInterval) -> Double {
        speed * 8.0 * deltaTime * 60.0
    }

    static func directionMultiplier(for direction: ScrollDirection, isUp: Bool = false) -> Int32 {
        switch direction {
        case .down: return -1
        case .up: return 1
        case .alternate: return isUp ? 1 : -1
        }
    }

    static func isDeltaTimeAnomaly(_ deltaTime: CFTimeInterval) -> Bool {
        deltaTime > 0.1
    }

    static func isAccumulatedDeltaOverflow(_ accumulatedDelta: Double) -> Bool {
        abs(accumulatedDelta) > 500.0
    }

    static func isReservedHotkey(keyCode: UInt32, modifiers: UInt32) -> Bool {
        let reservedKeyCodes: Set<UInt32> = [UInt32(kVK_ANSI_Q), UInt32(kVK_ANSI_W), UInt32(kVK_Tab)]
        let reservedWithModifiersKeyCodes: Set<UInt32> = [
            UInt32(kVK_ANSI_Q), UInt32(kVK_ANSI_W), UInt32(kVK_ANSI_H),
            UInt32(kVK_ANSI_C), UInt32(kVK_ANSI_V), UInt32(kVK_ANSI_X),
            UInt32(kVK_ANSI_A), UInt32(kVK_ANSI_Z), UInt32(kVK_ANSI_S),
            UInt32(kVK_ANSI_P), UInt32(kVK_ANSI_N), UInt32(kVK_ANSI_O),
            UInt32(kVK_ANSI_F), UInt32(kVK_ANSI_G)
        ]

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
}
