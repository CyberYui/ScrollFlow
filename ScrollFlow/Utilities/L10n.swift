import Foundation

enum L10n {
    static let appPermissionRequired = NSLocalizedString(
        "app.permissionRequired",
        value: "需要先授予“辅助功能”权限，ScrollFlow 才能向系统发送滚动事件。",
        comment: "Shown when auto-scroll needs accessibility access."
    )

    static func speedDescription(current: Double) -> String {
        String(
            format: NSLocalizedString(
                "app.speedDescription",
                value: "%.0f / %.0f",
                comment: "Current scroll speed over maximum."
            ),
            current,
            AppSettings.maximumScrollSpeed
        )
    }

    static func menuSpeed(_ value: String) -> String {
        String(
            format: NSLocalizedString(
                "menu.speed",
                value: "滚动速度：%@",
                comment: "Menu bar speed label."
            ),
            value
        )
    }

    static func menuHotkey(_ value: String) -> String {
        String(
            format: NSLocalizedString(
                "menu.hotkey",
                value: "全局快捷键：%@",
                comment: "Menu bar hotkey label."
            ),
            value
        )
    }

    static let menuRunning = NSLocalizedString("menu.running", value: "自动滚动中", comment: "Auto-scroll running state.")
    static let menuPaused = NSLocalizedString("menu.paused", value: "已暂停", comment: "Auto-scroll paused state.")
    static let menuPermissionHint = NSLocalizedString("menu.permissionHint", value: "需授予辅助功能权限后才能滚动其他应用内容。", comment: "Permission hint in menu.")
    static let menuPauseButton = NSLocalizedString("menu.pause", value: "暂停自动滚动", comment: "Pause auto-scroll button.")
    static let menuStartButton = NSLocalizedString("menu.start", value: "开启自动滚动", comment: "Start auto-scroll button.")
    static let menuSettingsButton = NSLocalizedString("menu.settings", value: "设置…", comment: "Open settings button.")
    static let menuQuitButton = NSLocalizedString("menu.quit", value: "退出 ScrollFlow", comment: "Quit app button.")

    static let settingsSectionGeneral = NSLocalizedString("settings.general", value: "基础设置", comment: "General settings section.")
    static let settingsLaunchAtLogin = NSLocalizedString("settings.launchAtLogin", value: "开机自启", comment: "Launch at login toggle.")
    static let settingsSpeedTitle = NSLocalizedString("settings.speedTitle", value: "滚动速度", comment: "Scroll speed label.")
    static let settingsSectionHotkey = NSLocalizedString("settings.hotkey", value: "全局快捷键", comment: "Hotkey settings section.")
    static let settingsHotkeyHint = NSLocalizedString("settings.hotkeyHint", value: "设置后可在任意应用内一键开启 / 暂停自动滚动。", comment: "Hotkey hint text.")
    static let settingsSectionPermissions = NSLocalizedString("settings.permissions", value: "权限", comment: "Permissions section.")
    static let settingsPermissionReady = NSLocalizedString("settings.permissionReady", value: "辅助功能权限已就绪", comment: "Permission ready state.")
    static let settingsPermissionNeeded = NSLocalizedString("settings.permissionNeeded", value: "需要辅助功能权限", comment: "Permission needed state.")
    static let settingsPermissionDescription = NSLocalizedString("settings.permissionDescription", value: "ScrollFlow 仅在本机运行。为了向系统发送滚动事件，需要你在系统设置中授予辅助功能权限。", comment: "Permission explanation.")
    static let settingsRequestPermission = NSLocalizedString("settings.requestPermission", value: "请求辅助功能权限", comment: "Request permission button.")

    static let recorderPrompt = NSLocalizedString("recorder.prompt", value: "请按下新的组合键…", comment: "Prompt while recording hotkey.")
    static let recorderInstructionRecording = NSLocalizedString("recorder.recordingHint", value: "按下带 Command / Option / Control / Shift 的组合键，按 Esc 取消。", comment: "Recording hotkey hint.")
    static let recorderInstructionIdle = NSLocalizedString("recorder.idleHint", value: "点击按钮后录制新的全局快捷键。", comment: "Idle hotkey recorder hint.")

    static func hotkeyRegistrationFailed(status: OSStatus) -> String {
        String(
            format: NSLocalizedString(
                "error.hotkeyRegistrationFailed",
                value: "全局快捷键注册失败（OSStatus: %d）。",
                comment: "Global hotkey registration failure."
            ),
            status
        )
    }

    static let launchAtLoginUnsupported = NSLocalizedString(
        "error.launchAtLoginUnsupported",
        value: "当前系统版本不支持开机自启功能（需要 macOS 13.0 或更高版本）。",
        comment: "Launch at login unsupported system error."
    )

    static func launchAtLoginOperationFailed(_ message: String) -> String {
        String(
            format: NSLocalizedString(
                "error.launchAtLoginOperationFailed",
                value: "开机自启设置失败：%@",
                comment: "Launch at login operation failure."
            ),
            message
        )
    }
}
