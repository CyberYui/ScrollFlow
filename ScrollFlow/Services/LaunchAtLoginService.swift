import Foundation
import ServiceManagement

enum LaunchAtLoginServiceError: LocalizedError {
    case unsupportedSystem
    case operationFailed(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedSystem:
            return L10n.launchAtLoginUnsupported
        case let .operationFailed(message):
            return L10n.launchAtLoginOperationFailed(message)
        }
    }
}

final class LaunchAtLoginService {
    var isEnabled: Bool {
        guard #available(macOS 13.0, *) else {
            return false
        }

        return SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) throws {
        guard #available(macOS 13.0, *) else {
            throw LaunchAtLoginServiceError.unsupportedSystem
        }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            throw LaunchAtLoginServiceError.operationFailed(error.localizedDescription)
        }
    }
}
