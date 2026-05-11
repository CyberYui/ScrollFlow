import Foundation
import ServiceManagement

enum LaunchAtLoginServiceError: LocalizedError {
    case unsupportedSystem
    case operationFailed(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedSystem:
            return "当前系统版本不支持开机自启功能（需要 macOS 13.0 或更高版本）。"
        case let .operationFailed(message):
            return "开机自启设置失败：\(message)"
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
