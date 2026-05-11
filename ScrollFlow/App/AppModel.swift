import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var scrollSpeed: Double
    @Published var launchAtLoginEnabled: Bool
    @Published var hotkey: Hotkey
    @Published private(set) var isAutoScrolling = false
    @Published private(set) var accessibilityAuthorized: Bool
    @Published private(set) var lastErrorMessage: String?

    private let settingsStore: SettingsStore
    private let scrollService: ScrollService
    private let hotkeyService: GlobalHotkeyService
    private let launchAtLoginService: LaunchAtLoginService
    private let accessibilityPermissionService: AccessibilityPermissionService

    init(
        settingsStore: SettingsStore = SettingsStore(),
        scrollService: ScrollService = ScrollService(),
        hotkeyService: GlobalHotkeyService = GlobalHotkeyService(),
        launchAtLoginService: LaunchAtLoginService = LaunchAtLoginService(),
        accessibilityPermissionService: AccessibilityPermissionService = AccessibilityPermissionService()
    ) {
        self.settingsStore = settingsStore
        self.scrollService = scrollService
        self.hotkeyService = hotkeyService
        self.launchAtLoginService = launchAtLoginService
        self.accessibilityPermissionService = accessibilityPermissionService

        let settings = settingsStore.load()
        scrollSpeed = settings.scrollSpeed
        launchAtLoginEnabled = settings.launchAtLoginEnabled
        hotkey = settings.hotkey
        accessibilityAuthorized = accessibilityPermissionService.isTrusted(prompt: false)

        registerHotkey(hotkey)
    }

    deinit {
        scrollService.stop()
        hotkeyService.unregister()
    }

    var speedDescription: String {
        String(format: "%.0f / 12", scrollSpeed)
    }

    func toggleAutoScroll() {
        isAutoScrolling ? stopAutoScroll() : startAutoScroll()
    }

    func startAutoScroll() {
        guard accessibilityPermissionService.isTrusted(prompt: false) else {
            requestAccessibilityPermission()
            lastErrorMessage = "需要先授予“辅助功能”权限，ScrollFlow 才能向系统发送滚动事件。"
            return
        }

        accessibilityAuthorized = true
        scrollService.start(speed: scrollSpeed)
        isAutoScrolling = true
        lastErrorMessage = nil
    }

    func stopAutoScroll() {
        scrollService.stop()
        isAutoScrolling = false
    }

    func requestAccessibilityPermission() {
        accessibilityAuthorized = accessibilityPermissionService.isTrusted(prompt: true)
    }

    func updateScrollSpeed(_ newValue: Double) {
        scrollSpeed = newValue
        persistSettings()
        scrollService.update(speed: newValue)
    }

    func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            try launchAtLoginService.setEnabled(enabled)
            launchAtLoginEnabled = enabled
            lastErrorMessage = nil
            persistSettings()
        } catch {
            launchAtLoginEnabled = launchAtLoginService.isEnabled
            lastErrorMessage = error.localizedDescription
        }
    }

    func updateHotkey(_ newHotkey: Hotkey) {
        hotkey = newHotkey
        persistSettings()
        registerHotkey(newHotkey)
    }

    private func persistSettings() {
        let settings = AppSettings(
            scrollSpeed: scrollSpeed,
            hotkey: hotkey,
            launchAtLoginEnabled: launchAtLoginEnabled
        )
        settingsStore.save(settings)
    }

    private func registerHotkey(_ hotkey: Hotkey) {
        do {
            try hotkeyService.register(hotkey) { [weak self] in
                Task { @MainActor in
                    self?.toggleAutoScroll()
                }
            }
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }
}
