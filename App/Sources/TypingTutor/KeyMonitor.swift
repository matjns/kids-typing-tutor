import AppKit
import SwiftUI

/// Listens for real keystrokes while a lesson or game is on screen.
struct KeyMonitor: NSViewRepresentable {
    var onCharacter: (Character) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCharacter: onCharacter)
    }

    func makeNSView(context: Context) -> NSView {
        context.coordinator.start()
        return NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.onCharacter = onCharacter
    }

    final class Coordinator {
        var onCharacter: (Character) -> Void
        var monitor: Any?

        init(onCharacter: @escaping (Character) -> Void) {
            self.onCharacter = onCharacter
        }

        func start() {
            guard monitor == nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self else { return event }
                if event.modifierFlags.contains(.command) || event.modifierFlags.contains(.control) {
                    return event
                }
                guard let text = event.characters, text.count == 1, let character = text.first else {
                    return event
                }
                let scalarValue = character.unicodeScalars.first?.value ?? 0
                guard scalarValue >= 32, scalarValue != 127 else {
                    return event
                }
                let deliver = self.onCharacter
                Task { @MainActor in
                    deliver(character)
                }
                return nil
            }
        }

        deinit {
            if let monitor {
                NSEvent.removeMonitor(monitor)
            }
        }
    }
}
