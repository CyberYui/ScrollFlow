import Foundation

enum L10n {
    static let appPermissionRequired = NSLocalizedString(
        "app.permissionRequired",
        value: "Accessibility permission is required before ScrollFlow can post system-wide scroll events.",
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
                value: "Speed: %@",
                comment: "Menu bar speed label."
            ),
            value
        )
    }

    static func menuHotkey(_ value: String) -> String {
        String(
            format: NSLocalizedString(
                "menu.hotkey",
                value: "Hotkey: %@",
                comment: "Menu bar hotkey label."
            ),
            value
        )
    }

    static let menuRunning = NSLocalizedString("menu.running", value: "Auto-scrolling", comment: "Auto-scroll running state.")
    static let menuPaused = NSLocalizedString("menu.paused", value: "Paused", comment: "Auto-scroll paused state.")
    static let menuPermissionHint = NSLocalizedString("menu.permissionHint", value: "Accessibility permission is required before other apps can be scrolled.", comment: "Permission hint in menu.")
    static let menuPauseButton = NSLocalizedString("menu.pause", value: "Pause Auto-Scroll", comment: "Pause auto-scroll button.")
    static let menuStartButton = NSLocalizedString("menu.start", value: "Start Auto-Scroll", comment: "Start auto-scroll button.")
    static let menuSettingsButton = NSLocalizedString("menu.settings", value: "Settings…", comment: "Open settings button.")
    static let menuQuitButton = NSLocalizedString("menu.quit", value: "Quit ScrollFlow", comment: "Quit app button.")

    static let settingsSectionGeneral = NSLocalizedString("settings.general", value: "General", comment: "General settings section.")
    static let settingsLaunchAtLogin = NSLocalizedString("settings.launchAtLogin", value: "Launch at login", comment: "Launch at login toggle.")
    static let settingsSpeedTitle = NSLocalizedString("settings.speedTitle", value: "Scroll speed", comment: "Scroll speed label.")
    static let settingsSectionHotkey = NSLocalizedString("settings.hotkey", value: "Global Hotkey", comment: "Hotkey settings section.")
    static let settingsHotkeyHint = NSLocalizedString("settings.hotkeyHint", value: "Use the shortcut anywhere to start or pause auto-scrolling.", comment: "Hotkey hint text.")
    static let settingsSectionPermissions = NSLocalizedString("settings.permissions", value: "Permissions", comment: "Permissions section.")
    static let settingsPermissionReady = NSLocalizedString("settings.permissionReady", value: "Accessibility permission is ready", comment: "Permission ready state.")
    static let settingsPermissionNeeded = NSLocalizedString("settings.permissionNeeded", value: "Accessibility permission is required", comment: "Permission needed state.")
    static let settingsPermissionDescription = NSLocalizedString("settings.permissionDescription", value: "ScrollFlow runs locally only. To send scroll events through the system, grant Accessibility permission in System Settings.", comment: "Permission explanation.")
    static let settingsRequestPermission = NSLocalizedString("settings.requestPermission", value: "Request Accessibility Permission", comment: "Request permission button.")

    static let recorderPrompt = NSLocalizedString("recorder.prompt", value: "Press a new shortcut…", comment: "Prompt while recording hotkey.")
    static let recorderInstructionRecording = NSLocalizedString("recorder.recordingHint", value: "Press a shortcut with Command, Option, Control, or Shift. Press Esc to cancel.", comment: "Recording hotkey hint.")
    static let recorderInstructionIdle = NSLocalizedString("recorder.idleHint", value: "Click the button to record a new global shortcut.", comment: "Idle hotkey recorder hint.")

    static func hotkeyRegistrationFailed(status: OSStatus) -> String {
        String(
            format: NSLocalizedString(
                "error.hotkeyRegistrationFailed",
                value: "Failed to register the global hotkey (OSStatus: %d).",
                comment: "Global hotkey registration failure."
            ),
            status
        )
    }

    static let launchAtLoginUnsupported = NSLocalizedString(
        "error.launchAtLoginUnsupported",
        value: "Launch at login requires macOS 13.0 or later.",
        comment: "Launch at login unsupported system error."
    )

    static func launchAtLoginOperationFailed(_ message: String) -> String {
        String(
            format: NSLocalizedString(
                "error.launchAtLoginOperationFailed",
                value: "Failed to update launch at login: %@",
                comment: "Launch at login operation failure."
            ),
            message
        )
    }
}
