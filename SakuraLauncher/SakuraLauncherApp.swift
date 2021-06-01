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
                .frame(minWidth: 725, idealWidth: 782, minHeight: 380, idealHeight: 500)
                .navigationTitle("Sakura Launcher")
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
