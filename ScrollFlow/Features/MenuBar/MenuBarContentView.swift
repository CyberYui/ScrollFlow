import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                appModel.isAutoScrolling ? L10n.menuRunning : L10n.menuPaused,
                systemImage: appModel.isAutoScrolling ? "pause.circle.fill" : "play.circle.fill"
            )
            .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.menuSpeed(appModel.speedDescription))
                Text(L10n.menuHotkey(HotkeyFormatter.string(from: appModel.hotkey)))
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            if !appModel.accessibilityAuthorized {
                Label(L10n.menuPermissionHint, systemImage: "hand.raised.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let lastErrorMessage = appModel.lastErrorMessage {
                Text(lastErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            Button(appModel.isAutoScrolling ? L10n.menuPauseButton : L10n.menuStartButton) {
                appModel.toggleAutoScroll()
            }

            SettingsLink {
                Label(L10n.menuSettingsButton, systemImage: "gearshape")
            }

            Divider()

            Button(L10n.menuQuitButton) {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(14)
        .frame(width: 280)
    }
}
