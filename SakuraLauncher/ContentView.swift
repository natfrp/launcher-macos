//
//  ContentView.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/1/21.
//

import SwiftUI

struct ContentView: View {
    @State private var logs: [LogModel] = []
    @State private var logFilters: [String: Int] = [:]

    @State var tunnels: [TunnelModel] = []
    @State var currentTab = TabItemView.Tabs.tunnel

    func Log(l: LogModel) {
        logs.append(l)
        if logFilters[l.source] == nil {
            logFilters[l.source] = 1
        } else {
            logFilters[l.source]! += 1
        }

        while logs.count > 4096 {
            let del = logs.remove(at: 0)
            logFilters[del.source]! -= 1
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            content.transition(.opacity.animation(.default.speed(2.5)))
        }
    }

    var sidebar: some View {
        List {
            LogoView()
            TabItemView(title: "隧道", iconImage: "server.rack", target: .tunnel, current: $currentTab)
            TabItemView(title: "日志", iconImage: "doc.text", target: .log, current: $currentTab)
            TabItemView(title: "设置", iconImage: "gearshape", target: .settings, current: $currentTab)
            TabItemView(title: "关于", iconImage: "info.circle", target: .about, current: $currentTab)
        }
        .frame(width: 180)
        .listStyle(SidebarListStyle())
    }

    @ViewBuilder
    var content: some View {
        switch currentTab {
        case .tunnel:
            TunnelTab(tunnels: $tunnels)
        case .log:
            LogTab(logs: $logs, filters: $logFilters)
        case .settings:
            SettingsTab()
        case .about:
            AboutTab()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 782, height: 500))
    }
}
#endif
