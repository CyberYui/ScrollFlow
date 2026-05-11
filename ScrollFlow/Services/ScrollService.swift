import ApplicationServices
import Foundation

final class ScrollService {
    private var timer: Timer?
    private var currentSpeed: Double = AppSettings.default.scrollSpeed

    func start(speed: Double) {
        currentSpeed = speed
        stop()

        let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.emitScrollTick()
        }

        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func update(speed: Double) {
        currentSpeed = speed
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func emitScrollTick() {
        let delta = max(1, Int32(currentSpeed * 8))
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
}
