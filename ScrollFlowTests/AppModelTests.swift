import XCTest
@testable import ScrollFlow

final class MockAccessibilityPermissionService: AccessibilityPermissionServicing {
    var isTrustedResult = false
    func isTrusted(prompt: Bool) -> Bool { isTrustedResult }
}

final class MockInputMonitor: InputMonitorStarting {
    weak var delegate: InputMonitorDelegate?
    func start() {}
    func stop() {}
}

@MainActor
final class AppModelTests: XCTestCase {
    private var defaults: UserDefaults!
    private var mockAccessibility: MockAccessibilityPermissionService!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        mockAccessibility = MockAccessibilityPermissionService()
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: #function)
        defaults = nil
        mockAccessibility = nil
        super.tearDown()
    }

    private func makeModel() -> AppModel {
        AppModel(
            settingsStore: SettingsStore(defaults: defaults),
            hotkeyService: MockGlobalHotkeyService(),
            accessibilityPermissionService: mockAccessibility,
            inputMonitor: MockInputMonitor(),
            batteryMonitor: MockBatteryMonitor()
        )
    }

    func testInitialState() {
        let appModel = makeModel()
        XCTAssertFalse(appModel.isAutoScrolling)
        XCTAssertFalse(appModel.accessibilityAuthorized)
        XCTAssertEqual(appModel.scrollSpeed, AppSettings.defaultScrollSpeed)
        XCTAssertEqual(appModel.scrollDirection, .down)
        XCTAssertTrue(appModel.smoothMode)
        XCTAssertNil(appModel.lastErrorMessage)
    }

    func testToggleAutoScrollWithoutPermission() {
        mockAccessibility.isTrustedResult = false
        let appModel = makeModel()
        appModel.toggleAutoScroll()
        XCTAssertFalse(appModel.isAutoScrolling)
        XCTAssertNotNil(appModel.lastErrorMessage)
    }

    func testToggleAutoScrollWithPermission() {
        mockAccessibility.isTrustedResult = true
        let appModel = makeModel()
        appModel.toggleAutoScroll()
        XCTAssertTrue(appModel.isAutoScrolling)
        XCTAssertNil(appModel.lastErrorMessage)
    }

    func testUpdateScrollSpeed() {
        let appModel = makeModel()
        appModel.updateScrollSpeed(9.0)
        XCTAssertEqual(appModel.scrollSpeed, 9.0)
    }

    func testUpdateScrollDirection() {
        let appModel = makeModel()
        appModel.updateScrollDirection(.up)
        XCTAssertEqual(appModel.scrollDirection, .up)
    }

    func testUpdateSmoothMode() {
        let appModel = makeModel()
        appModel.updateSmoothMode(false)
        XCTAssertFalse(appModel.smoothMode)
    }

    func testResetToDefaults() {
        let appModel = makeModel()
        appModel.updateScrollSpeed(9.0)
        appModel.updateScrollDirection(.up)
        appModel.updateSmoothMode(false)

        appModel.resetToDefaults()

        XCTAssertEqual(appModel.scrollSpeed, AppSettings.defaultScrollSpeed)
        XCTAssertEqual(appModel.scrollDirection, .down)
        XCTAssertTrue(appModel.smoothMode)
    }

    func testSpeedDescriptionFormat() {
        let appModel = makeModel()
        appModel.updateScrollSpeed(6.0)
        XCTAssertEqual(appModel.speedDescription, "6 级")
    }

    func testSpeedDescriptionContainsLevel() {
        let appModel = makeModel()
        appModel.updateScrollSpeed(3.0)
        XCTAssertTrue(appModel.speedDescription.contains("3"))
        XCTAssertFalse(appModel.speedDescription.contains("/"))
    }
}
