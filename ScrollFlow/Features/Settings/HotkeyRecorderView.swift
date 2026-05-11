import AppKit
import SwiftUI

struct HotkeyRecorderView: View {
    let currentHotkey: Hotkey
    let onCapture: (Hotkey) -> Void

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                isRecording ? stopRecording() : startRecording()
            } label: {
                Text(isRecording ? "请按下新的组合键…" : HotkeyFormatter.string(from: currentHotkey))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)

            Text(isRecording ? "按下带 Command / Option / Control / Shift 的组合键，按 Esc 取消。" : "点击按钮后录制新的全局快捷键。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onDisappear {
            stopRecording()
        }
    }

    private func startRecording() {
        stopRecording()
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == UInt16(kVK_Escape) {
                stopRecording()
                return nil
            }

            guard let hotkey = Hotkey.from(event: event) else {
                return nil
            }

            onCapture(hotkey)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        isRecording = false
    }
}
