import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section(L10n.settingsSectionGeneral) {
                Toggle(
                    L10n.settingsLaunchAtLogin,
                    isOn: Binding(
                        get: { appModel.launchAtLoginEnabled },
                        set: { appModel.updateLaunchAtLogin($0) }
                    )
                )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(L10n.settingsSpeedTitle)
                        Spacer()
                        Text(appModel.speedDescription)
                            .foregroundStyle(.secondary)
                    }

                    Slider(
                        value: Binding(
                            get: { appModel.scrollSpeed },
                            set: { appModel.updateScrollSpeed($0) }
                        ),
                        in: AppSettings.minimumScrollSpeed ... AppSettings.maximumScrollSpeed,
                        step: 1
                    )
                }
            }

            Section(L10n.settingsSectionHotkey) {
                HotkeyRecorderView(currentHotkey: appModel.hotkey) { newHotkey in
                    appModel.updateHotkey(newHotkey)
                }

                Text(L10n.settingsHotkeyHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(L10n.settingsSectionPermissions) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: appModel.accessibilityAuthorized ? "checkmark.shield.fill" : "hand.raised.fill")
                        .foregroundStyle(appModel.accessibilityAuthorized ? .green : .orange)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(appModel.accessibilityAuthorized ? L10n.settingsPermissionReady : L10n.settingsPermissionNeeded)
                            .font(.headline)
                        Text(L10n.settingsPermissionDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button(L10n.settingsRequestPermission) {
                    appModel.requestAccessibilityPermission()
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 460)
    }
}
