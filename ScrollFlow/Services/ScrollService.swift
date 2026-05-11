import ApplicationServices
import Foundation

final class ScrollService {
    private enum Constants {
        static let tickInterval = 0.05
        static let pixelsPerSpeedUnit = 8.0
    }

    private var timer: Timer?
    private var currentSpeed: Double = AppSettings.default.scrollSpeed

    func start(speed: Double) {
        currentSpeed = clamped(speed)
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
    }

    private func emitScrollTick() {
        let delta = Int32(currentSpeed * Constants.pixelsPerSpeedUnit)
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
