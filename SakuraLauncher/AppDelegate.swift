import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSMenuDelegate {
    var isPreview = true

    var model: LauncherModel?

    var mainWindow: NSWindow!
    var statusBarMenu: NSMenu!
    var statusBarItem: NSStatusItem!

    func applicationDidFinishLaunching(_: Notification) {
        if isPreview {
            return
        }

        UNUserNotificationCenter.current().delegate = self

        mainWindow = NSApplication.shared.windows[0]
        if let window = mainWindow {
            window.delegate = self
            window.isMovableByWindowBackground = true
            window.standardWindowButton(.zoomButton)!.isHidden = true
        }

        showWindow()

        statusBarMenu = NSMenu()
        statusBarMenu.delegate = self
        statusBarMenu.addItem(withTitle: "显示启动器", action: #selector(exitAction), keyEquivalent: "")
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(withTitle: "退出", action: #selector(showAction), keyEquivalent: "")
        statusBarMenu.addItem(withTitle: "彻底退出", action: #selector(exitFullAction), keyEquivalent: "")

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let btn = statusBarItem.button {
            btn.image = NSImage(imageLiteralResourceName: "StatusBarIcon")
            btn.image!.isTemplate = true
            btn.action = #selector(statusAction)
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    func showWindow() {
        NSApplication.shared.setActivationPolicy(.regular)
        mainWindow?.orderFront(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.setActivationPolicy(.accessory)

        sender.orderOut(self)
        return false
    }

    @objc func statusAction(sender _: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(nil)
        } else {
            showWindow()
        }
    }

    @objc func menuDidClose(_: NSMenu) {
        statusBarItem.menu = nil // remove menu so button works as before
    }

    @objc func showAction(_: AnyObject?) {
        showWindow()
    }

    @objc func exitAction(_: AnyObject?) {
        NSApplication.shared.terminate(self)
    }

    @MainActor @objc func exitFullAction(_: AnyObject?) {
        statusBarMenu.items[3].isEnabled = false
        model!.daemon.fullShutdown()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
