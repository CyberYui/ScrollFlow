import ApplicationServices
import Foundation

final class ScrollService {
    private enum Constants {
        static let tickInterval = 0.05
        static let pixelsPerSpeedUnit = 8.0
    }

    private var timer: Timer?
    private var currentSpeed: Double = AppSettings.default.scrollSpeed
    private var accumulatedDelta = 0.0

    func start(speed: Double) {
        currentSpeed = clamped(speed)
        accumulatedDelta = 0.0
        stop()

        let timer = Timer(timeInterval: Constants.tickInterval, repeats: true) { [weak self] _ in
            self?.emitScrollTick()
        }

        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func update(speed: Double) {
        currentSpeed = clamped(speed)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        accumulatedDelta = 0.0
    }

    private func emitScrollTick() {
        accumulatedDelta += currentSpeed * Constants.pixelsPerSpeedUnit
        let delta = Int32(accumulatedDelta.rounded(.towardZero))
        guard delta != 0 else {
            return
        }

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
