import SwiftUI

@main
struct DeveloperDashApp: App {
    @NSApplicationDelegateAdaptor((AppDelegate).self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {}
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?
    
    private var bitBucketViewModel = BitBucketViewModel()
    
    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "list.dash", accessibilityDescription: "DeveloperDash")
            statusButton.action = #selector(statusItemClicked)
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        setUpPopover()
        setUpShortCutObserver()
    }
    
    @objc private func setUpPopover() {
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 480, height: 300)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView(bitbucketViewModel: bitBucketViewModel))
    }
    
    @objc private func setUpShortCutObserver() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.keyCode == 43 { // 43 is the keyCode for comma
                self.showSettings()
                return nil
            }
            return event
        }
    }

    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        if let event = NSApp.currentEvent {
            if event.type == .rightMouseUp {
                toggleMenu()
            } else {
                togglePopover()
            }
        }
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                Task {
                    await self.bitBucketViewModel.fetchOpenPullRequests()
                }
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    @objc private func toggleMenu() {
        let menu = NSMenu()
        
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: ",")
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        
        menu.addItem(settingsItem)
        menu.addItem(quitItem)

        if let statusMenu = statusItem {
            statusMenu.menu = menu
            statusMenu.button?.performClick(nil)
            statusMenu.menu = nil
        }
    }
    
    @objc func showSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView(bitbucketViewModel: bitBucketViewModel)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.contentViewController = NSHostingController(rootView: settingsView)
            window.title = "Settings"
            window.makeKeyAndOrderFront(nil)
            window.isReleasedWhenClosed = false
            settingsWindow = window
        } else {
            settingsWindow?.makeKeyAndOrderFront(nil)
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
