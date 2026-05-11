import AppKit
import Carbon
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
                Text(isRecording ? L10n.recorderPrompt : HotkeyFormatter.string(from: currentHotkey))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)

            Text(isRecording ? L10n.recorderInstructionRecording : L10n.recorderInstructionIdle)
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
