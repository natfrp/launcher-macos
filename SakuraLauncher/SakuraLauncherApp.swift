//
//  SakuraLauncherApp.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/1/21.
//

import SwiftUI

@main
struct SakuraLauncherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 725, idealWidth: 782, minHeight: 400, idealHeight: 500)
                .navigationTitle("Sakura Launcher")
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                    for window in NSApplication.shared.windows {
                        window.standardWindowButton(.zoomButton)!.isHidden = true
                        window.isMovableByWindowBackground = true
                    }
                })
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
