import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ application: NSApplication) -> Bool {
        true
    }
}

@main
struct TypingTutorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup("Typing Tutor") {
            RootView()
                .environmentObject(model)
                .frame(minWidth: 960, minHeight: 640)
                .preferredColorScheme(.light)
        }
        .defaultSize(width: 1140, height: 780)
        .windowResizability(.contentMinSize)
    }
}
