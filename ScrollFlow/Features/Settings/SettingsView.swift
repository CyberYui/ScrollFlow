import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("基础设置") {
                Toggle(
                    "开机自启",
                    isOn: Binding(
                        get: { appModel.launchAtLoginEnabled },
                        set: { appModel.updateLaunchAtLogin($0) }
                    )
                )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("滚动速度")
                        Spacer()
                        Text(appModel.speedDescription)
                            .foregroundStyle(.secondary)
                    }

                    Slider(
                        value: Binding(
                            get: { appModel.scrollSpeed },
                            set: { appModel.updateScrollSpeed($0) }
                        ),
                        in: 1 ... 12,
                        step: 1
                    )
                }
            }

            Section("全局快捷键") {
                HotkeyRecorderView(currentHotkey: appModel.hotkey) { newHotkey in
                    appModel.updateHotkey(newHotkey)
                }

                Text("设置后可在任意应用内一键开启 / 暂停自动滚动。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("权限") {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: appModel.accessibilityAuthorized ? "checkmark.shield.fill" : "hand.raised.fill")
                        .foregroundStyle(appModel.accessibilityAuthorized ? .green : .orange)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(appModel.accessibilityAuthorized ? "辅助功能权限已就绪" : "需要辅助功能权限")
                            .font(.headline)
                        Text("ScrollFlow 仅在本机运行。为了向系统发送滚动事件，需要你在系统设置中授予辅助功能权限。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button("请求辅助功能权限") {
                    appModel.requestAccessibilityPermission()
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 460)
    }
}
