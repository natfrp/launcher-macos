//
//  AppDelegate.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/9/21.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var isPreview = true

    var mainWindow: NSWindow?
    var statusBarItem: NSStatusItem?

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

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let btn = statusBarItem?.button {
            btn.title = "SakuraFrp Launcher [TODO]"
            btn.action = #selector(statusBarAction)
        }
    }

    func showWindow() {
        NSApplication.shared.setActivationPolicy(.regular)

        mainWindow?.orderFront(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    @objc func statusBarAction(_: AnyObject?) {
        showWindow()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.setActivationPolicy(.accessory)

        sender.orderOut(self)
        return false
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
