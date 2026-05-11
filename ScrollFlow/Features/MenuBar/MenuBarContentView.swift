import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                appModel.isAutoScrolling ? "自动滚动中" : "已暂停",
                systemImage: appModel.isAutoScrolling ? "pause.circle.fill" : "play.circle.fill"
            )
            .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text("滚动速度：\(appModel.speedDescription)")
                Text("全局快捷键：\(HotkeyFormatter.string(from: appModel.hotkey))")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            if !appModel.accessibilityAuthorized {
                Label("需授予辅助功能权限后才能滚动其他应用内容。", systemImage: "hand.raised.fill")
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

            Button(appModel.isAutoScrolling ? "暂停自动滚动" : "开启自动滚动") {
                appModel.toggleAutoScroll()
            }

            SettingsLink {
                Label("设置…", systemImage: "gearshape")
            }

            Divider()

            Button("退出 ScrollFlow") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(14)
        .frame(width: 280)
    }
}
