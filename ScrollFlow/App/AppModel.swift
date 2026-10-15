import Foundation

@MainActor
final class AppModel: ObservableObject, InputMonitorDelegate {
    @Published var scrollSpeed: Double
    @Published var launchAtLoginEnabled: Bool
    @Published var hotkey: Hotkey
    @Published var scrollDirection: ScrollDirection
    @Published var smoothMode: Bool
    @Published private(set) var isAutoScrolling = false
    @Published private(set) var accessibilityAuthorized: Bool
    @Published private(set) var lastErrorMessage: String?

    private let settingsStore: SettingsStore
    private let scrollService: ScrollService
    private let hotkeyService: GlobalHotkeyServiceProtocol
    private let launchAtLoginService: LaunchAtLoginService
    private let accessibilityPermissionService: AccessibilityPermissionServicing
    private let inputMonitor: InputMonitorStarting
    private var batteryMonitor: BatteryMonitoring
    private var resumeTask: Task<Void, Never>?
    private var permissionTimer: Timer?

    init(
        settingsStore: SettingsStore = SettingsStore(),
        scrollService: ScrollService = ScrollService(),
        hotkeyService: GlobalHotkeyServiceProtocol = GlobalHotkeyService(),
        launchAtLoginService: LaunchAtLoginService = LaunchAtLoginService(),
        accessibilityPermissionService: AccessibilityPermissionServicing = AccessibilityPermissionService(),
        inputMonitor: InputMonitorStarting = InputMonitorService(),
        batteryMonitor: BatteryMonitoring = BatteryMonitorService()
    ) {
        self.settingsStore = settingsStore
        self.scrollService = scrollService
        self.hotkeyService = hotkeyService
        self.launchAtLoginService = launchAtLoginService
        self.accessibilityPermissionService = accessibilityPermissionService
        self.inputMonitor = inputMonitor
        self.batteryMonitor = batteryMonitor

        let settings = settingsStore.load()
        scrollSpeed = settings.scrollSpeed
        launchAtLoginEnabled = launchAtLoginService.isEnabled
        hotkey = settings.hotkey
        scrollDirection = settings.scrollDirection
        smoothMode = settings.smoothMode
        accessibilityAuthorized = accessibilityPermissionService.isTrusted(prompt: false)

        persistSettings()
        registerHotkey(hotkey)

        inputMonitor.delegate = self
        inputMonitor.start()
        startPermissionMonitoring()
        startBatteryMonitoring()
    }

    deinit {
        resumeTask?.cancel()
        permissionTimer?.invalidate()
        batteryMonitor.stopMonitoring()
        inputMonitor.stop()
        scrollService.stop()
        hotkeyService.unregister()
    }

    private func startBatteryMonitoring() {
        batteryMonitor.onPowerSourceChange = { [weak self] isOnBattery in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if isOnBattery {
                    self.handleBatteryPowerDetected()
                }
            }
        }
        batteryMonitor.startMonitoring()
    }

    private func handleBatteryPowerDetected() {
        guard isAutoScrolling else { return }
        stopAutoScroll()
        lastErrorMessage = L10n.batteryPowerPause
    }

    private func startPermissionMonitoring() {
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let trusted = self.accessibilityPermissionService.isTrusted(prompt: false)
                if trusted != self.accessibilityAuthorized {
                    self.accessibilityAuthorized = trusted
                    if !trusted {
                        self.stopAutoScroll()
                        self.lastErrorMessage = L10n.appPermissionRequired
                    } else {
                        self.lastErrorMessage = nil
                    }
                }
            }
        }
    }

    var speedDescription: String {
        L10n.speedDescription(current: scrollSpeed)
    }

    func toggleAutoScroll() {
        isAutoScrolling ? stopAutoScroll() : startAutoScroll()
    }

    func startAutoScroll() {
        guard accessibilityPermissionService.isTrusted(prompt: false) else {
            requestAccessibilityPermission()
            lastErrorMessage = L10n.appPermissionRequired
            return
        }

        accessibilityAuthorized = true
        scrollService.start(speed: scrollSpeed, direction: scrollDirection, smoothMode: smoothMode)
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
        lastErrorMessage = nil
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

    func updateScrollDirection(_ direction: ScrollDirection) {
        scrollDirection = direction
        persistSettings()
        scrollService.update(speed: scrollSpeed, direction: direction, smoothMode: smoothMode)
    }

    func updateSmoothMode(_ enabled: Bool) {
        smoothMode = enabled
        persistSettings()
        scrollService.update(speed: scrollSpeed, direction: scrollDirection, smoothMode: enabled)
    }

    func resetToDefaults() {
        scrollSpeed = AppSettings.defaultScrollSpeed
        hotkey = Hotkey.defaultValue
        scrollDirection = .down
        smoothMode = true
        launchAtLoginEnabled = launchAtLoginService.isEnabled
        persistSettings()
        scrollService.update(speed: scrollSpeed, direction: scrollDirection, smoothMode: smoothMode)
        registerHotkey(hotkey)
        lastErrorMessage = nil
    }

    private func persistSettings() {
        let settings = AppSettings(
            scrollSpeed: scrollSpeed,
            hotkey: hotkey,
            launchAtLoginEnabled: launchAtLoginEnabled,
            scrollDirection: scrollDirection,
            smoothMode: smoothMode
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

    // MARK: - InputMonitorDelegate

    nonisolated func inputMonitorDidDetectUserInput(_ monitor: InputMonitorService) {
        Task { @MainActor [weak self] in
            self?.handleUserInputDetected()
        }
    }

    private func handleUserInputDetected() {
        guard isAutoScrolling else { return }

        scrollService.stop()
        isAutoScrolling = false

        resumeTask?.cancel()
        resumeTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard let self, !Task.isCancelled else { return }
            self.startAutoScroll()
        }
    }
}
