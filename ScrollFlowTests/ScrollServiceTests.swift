import Carbon.HIToolbox
import CoreVideo
import QuartzCore
import XCTest
@testable import ScrollFlow

final class ScrollServiceTests: XCTestCase {

    // MARK: - ScrollMath.clamped

    func testClampedWithinRange() {
        XCTAssertEqual(ScrollMath.clamped(6.0), 6.0)
    }

    func testClampedBelowMinimum() {
        XCTAssertEqual(ScrollMath.clamped(0.5), AppSettings.minimumScrollSpeed)
    }

    func testClampedAboveMaximum() {
        XCTAssertEqual(ScrollMath.clamped(99.0), AppSettings.maximumScrollSpeed)
    }

    func testClampedAtExactBounds() {
        XCTAssertEqual(ScrollMath.clamped(AppSettings.minimumScrollSpeed), AppSettings.minimumScrollSpeed)
        XCTAssertEqual(ScrollMath.clamped(AppSettings.maximumScrollSpeed), AppSettings.maximumScrollSpeed)
    }

    // MARK: - ScrollMath.accumulatedDelta

    func testAccumulatedDeltaAt60FPS() {
        let delta = ScrollMath.accumulatedDelta(speed: 6.0, deltaTime: 1.0 / 60.0)
        XCTAssertEqual(delta, 48.0, accuracy: 0.1)
    }

    func testAccumulatedDeltaAt120FPS() {
        let delta = ScrollMath.accumulatedDelta(speed: 6.0, deltaTime: 1.0 / 120.0)
        XCTAssertEqual(delta, 24.0, accuracy: 0.1)
    }

    func testAccumulatedDeltaAt30FPS() {
        let delta = ScrollMath.accumulatedDelta(speed: 6.0, deltaTime: 1.0 / 30.0)
        XCTAssertEqual(delta, 96.0, accuracy: 0.1)
    }

    func testAccumulatedDeltaZeroAtZeroSpeed() {
        let delta = ScrollMath.accumulatedDelta(speed: 0.0, deltaTime: 1.0 / 60.0)
        XCTAssertEqual(delta, 0.0)
    }

    // MARK: - ScrollMath.directionMultiplier

    func testDirectionMultiplierDown() {
        XCTAssertEqual(ScrollMath.directionMultiplier(for: .down), -1)
    }

    func testDirectionMultiplierUp() {
        XCTAssertEqual(ScrollMath.directionMultiplier(for: .up), 1)
    }

    func testDirectionMultiplierAlternateDown() {
        XCTAssertEqual(ScrollMath.directionMultiplier(for: .alternate, isUp: false), -1)
    }

    func testDirectionMultiplierAlternateUp() {
        XCTAssertEqual(ScrollMath.directionMultiplier(for: .alternate, isUp: true), 1)
    }

    // MARK: - ScrollMath.isDeltaTimeAnomaly

    func testDeltaTimeAnomalyAtSleep() {
        XCTAssertTrue(ScrollMath.isDeltaTimeAnomaly(10.0))
    }

    func testDeltaTimeAnomalyAtNormal() {
        XCTAssertFalse(ScrollMath.isDeltaTimeAnomaly(1.0 / 60.0))
    }

    func testDeltaTimeAnomalyAtBoundary() {
        XCTAssertFalse(ScrollMath.isDeltaTimeAnomaly(0.1))
    }

    // MARK: - ScrollMath.isAccumulatedDeltaOverflow

    func testAccumulatedDeltaOverflowAtLimit() {
        XCTAssertTrue(ScrollMath.isAccumulatedDeltaOverflow(501.0))
    }

    func testAccumulatedDeltaOverflowWithinLimit() {
        XCTAssertFalse(ScrollMath.isAccumulatedDeltaOverflow(499.0))
    }

    func testAccumulatedDeltaOverflowNegative() {
        XCTAssertTrue(ScrollMath.isAccumulatedDeltaOverflow(-501.0))
    }

    func testAccumulatedDeltaOverflowAtZero() {
        XCTAssertFalse(ScrollMath.isAccumulatedDeltaOverflow(0.0))
    }

    // MARK: - ScrollService lifecycle

    func testRapidStartStopDoesNotCrash() {
        let service = ScrollService()
        for _ in 0..<100 {
            service.start(speed: 6.0, direction: .down, smoothMode: true)
            service.stop()
        }
    }

    func testStartStopWithAllDirections() {
        let service = ScrollService()
        for direction in ScrollDirection.allCases {
            service.start(speed: 6.0, direction: direction, smoothMode: true)
            service.stop()
        }
    }

    func testStartStopWithSmoothModeToggle() {
        let service = ScrollService()
        service.start(speed: 6.0, direction: .down, smoothMode: true)
        service.stop()
        service.start(speed: 6.0, direction: .down, smoothMode: false)
        service.stop()
    }

    // MARK: - Update speed while stopped

    func testUpdateSpeedWhileStoppedDoesNotCrash() {
        let service = ScrollService()
        service.stop()
        service.update(speed: 99.0)
    }
}
