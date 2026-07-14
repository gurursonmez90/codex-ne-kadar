import AppKit
import Darwin
import ServiceManagement
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let monitor = LimitMonitor()
#if DEBUG
    private var previewWindow: NSWindow?
#endif

    func applicationDidFinishLaunching(_: Notification) {
        if CommandLine.arguments.contains("--self-test") {
            SelfTest.run()
            exit(0)
        }
        configureLaunchAtLogin()
        monitor.start()

#if DEBUG
        if CommandLine.arguments.contains("--ui-preview") || CommandLine.arguments.contains("--settings-preview") {
            showPreviewWindow(settings: CommandLine.arguments.contains("--settings-preview"))
        }
#endif
    }

    private func configureLaunchAtLogin() {
        UserDefaults.standard.register(defaults: ["launchAtLogin": true])
        guard UserDefaults.standard.bool(forKey: "launchAtLogin") else { return }
        guard SMAppService.mainApp.status != .enabled else { return }

        do {
            try SMAppService.mainApp.register()
        } catch {
            NSLog("Girişte başlatma kaydedilemedi: %@", error.localizedDescription)
        }
    }

#if DEBUG
    private func showPreviewWindow(settings: Bool) {
        NSApp.setActivationPolicy(.regular)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: settings ? 460 : 382, height: settings ? 560 : 600),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = settings ? "Codex Ne Kadar - Ayarlar Önizleme" : "Codex Ne Kadar - Arayüz Önizleme"
        window.isReleasedWhenClosed = false
        let rootView = settings
            ? AnyView(SettingsView(monitor: monitor))
            : AnyView(LimitPopover(monitor: monitor))
        window.contentViewController = NSHostingController(rootView: rootView)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        previewWindow = window
    }
#endif
}

@main
struct CodexNeKadarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            LimitPopover(monitor: appDelegate.monitor)
        } label: {
            StatusBarLabel(monitor: appDelegate.monitor)
        }
        .menuBarExtraStyle(.window)
    }
}
