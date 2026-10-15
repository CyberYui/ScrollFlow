import Foundation
import IOKit.ps

protocol BatteryMonitoring {
    var isOnBattery: Bool { get }
    var onPowerSourceChange: ((Bool) -> Void)? { get set }
    func startMonitoring()
    func stopMonitoring()
}

final class BatteryMonitorService: BatteryMonitoring {
    var onPowerSourceChange: ((Bool) -> Void)?
    private var timer: Timer?

    var isOnBattery: Bool {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return false
        }
        #endif

        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return false
        }
        guard let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let first = sources.first else {
            return false
        }
        guard let description = IOPSGetPowerSourceDescription(snapshot, first)?.takeRetainedValue() as? [String: Any],
              let powerSource = description["Power Source"] as? String else {
            return false
        }
        return powerSource == "Battery Power"
    }

    func startMonitoring() {
        guard timer == nil else { return }
        onPowerSourceChange?(isOnBattery)
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.onPowerSourceChange?(self.isOnBattery)
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopMonitoring()
    }
}

final class MockBatteryMonitor: BatteryMonitoring {
    var isOnBattery: Bool = false
    var onPowerSourceChange: ((Bool) -> Void)?
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    func startMonitoring() { startCallCount += 1 }
    func stopMonitoring() { stopCallCount += 1 }
}
