import ApplicationServices
import Combine
import Foundation

protocol AccessibilityPermissionServicing {
    func isTrusted(prompt: Bool) -> Bool
}

final class AccessibilityPermissionService: AccessibilityPermissionServicing {
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    var onPermissionChange: ((Bool) -> Void)?

    func isTrusted(prompt: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func startMonitoring() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let trusted = self.isTrusted(prompt: false)
            self.onPermissionChange?(trusted)
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

final class MockAccessibilityPermission: AccessibilityPermissionServicing {
    var isTrustedResult = true
    func isTrusted(prompt: Bool) -> Bool { isTrustedResult }
}
