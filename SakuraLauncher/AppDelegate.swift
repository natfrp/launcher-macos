//
//  AppDelegate.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/9/21.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var mainWindow: NSWindow?
    var statusBarItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        mainWindow = NSApplication.shared.windows[0]
        if let window = mainWindow {
            window.delegate = self
            window.isMovableByWindowBackground = true
            window.standardWindowButton(.zoomButton)!.isHidden = true
        }

        // TODO: call NSApp.hide(nil) when started automatically
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

    @objc func statusBarAction(_ sender: AnyObject?) {
        showWindow()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.setActivationPolicy(.accessory)

        sender.orderOut(self)
        return false
    }
}
