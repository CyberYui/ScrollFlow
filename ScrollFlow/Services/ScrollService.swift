import ApplicationServices
import CoreVideo
import Foundation
import QuartzCore

final class ScrollService {
    private enum Constants {
        static let pixelsPerSpeedUnit = 8.0
    }

    private var displayLink: CVDisplayLink?
    private var currentSpeed: Double = AppSettings.default.scrollSpeed
    private var accumulatedDelta = 0.0
    private var lastTime: CFTimeInterval = 0

    deinit {
        stop()
    }

    func start(speed: Double) {
        currentSpeed = clamped(speed)
        accumulatedDelta = 0.0
        lastTime = CACurrentMediaTime()
        stop()

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
        self.displayLink = displayLink
    }

    func update(speed: Double) {
        currentSpeed = clamped(speed)
    }

    func stop() {
        if let displayLink {
            CVDisplayLinkStop(displayLink)
            self.displayLink = nil
        }
        accumulatedDelta = 0.0
    }

    private func emitScrollTick() {
        let now = CACurrentMediaTime()
        let deltaTime = now - lastTime
        lastTime = now

        accumulatedDelta += currentSpeed * Constants.pixelsPerSpeedUnit * deltaTime * 60.0
        let delta = Int32(accumulatedDelta.rounded(.towardZero))
        guard delta != 0 else { return }

        accumulatedDelta -= Double(delta)
        guard let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 1,
            wheel1: -delta,
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
