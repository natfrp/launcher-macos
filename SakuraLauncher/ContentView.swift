//
//  ContentView.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/1/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: LauncherModel

    @State var currentTab = TabItemView.Tabs.settings
    @State var currentPopup: AnyView?

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                sidebar
                content.transition(.opacity.animation(.default.speed(2.5)))
            }
            .alert(isPresented: $model.showAlert, content: {
                Alert(title: Text(model.alertTitle), message: Text(model.alertText))
            })
            if let popup = currentPopup {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                popup
            }
        }
    }

    var sidebar: some View {
        List {
            LogoView()
            TabItemView(title: "隧道", iconImage: "server.rack", target: .tunnel, current: $currentTab)
                .disabled(!model.connected || model.user.status != .loggedIn)
            TabItemView(title: "日志", iconImage: "doc.text", target: .log, current: $currentTab)
            TabItemView(title: "设置", iconImage: "gearshape", target: .settings, current: $currentTab)
            TabItemView(title: "关于", iconImage: "info.circle", target: .about, current: $currentTab)
        }
        .frame(width: 180)
        .listStyle(SidebarListStyle())
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            switch currentTab {
            case .tunnel:
                TunnelTab()
            case .log:
                LogTab()
            case .settings:
                SettingsTab(currentPopup: $currentPopup)
            case .about:
                AboutTab()
            }
            if !model.connected {
                Text("未连接到守护进程, 大部分功能将不可用, 请尝试重启启动器")
                    .font(.system(size: 18))
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 782, height: 500))
            .environmentObject(LauncherModel_Preview() as LauncherModel)
    }
}
#endif
