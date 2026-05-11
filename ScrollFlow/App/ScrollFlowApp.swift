import SwiftUI

@main
struct ScrollFlowApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        MenuBarExtra("ScrollFlow", systemImage: appModel.isAutoScrolling ? "pause.circle" : "text.justify") {
            MenuBarContentView()
                .environmentObject(appModel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appModel)
        }
    }
}
