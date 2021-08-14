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

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                sidebar
                content.transition(.opacity.animation(.default.speed(2.5)))
            }
            .alert(isPresented: $model.showAlert, content: {
                model.alertContent ?? Alert(title: Text("出现了奇怪的错误"))
            })
            if let popup = model.popupContent {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                popup
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.background))
                    .shadow(radius: 16)
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
                SettingsTab()
            case .about:
                AboutTab()
            }
            if !model.connected {
                Text("未连接到守护进程, 大部分功能将不可用, 请尝试重启启动器")
                    .font(.system(size: 18))
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
            } else {
                updateBar
            }
        }
    }

    @ViewBuilder
    var updateBar: some View {
        if let u = model.update, u.updateAvailable {
            Button(action: {
                NSWorkspace.shared.open(URL(string: u.updateReadyDir)!)
            }) {
                Text("发现新版本，点此下载新版安装包")
                    .font(.system(size: 18))
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0, green: 0.5, blue: 0.5))
            }.buttonStyle(PlainButtonStyle())
            /* Can't open the pkg installer programmatically due to sandboxing.
             if u.updateReadyDir != "" {
                 Button(action: {
                     // Ugly workaround
                     // NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: u.updateReadyDir).appendingPathComponent("SakuraLauncherMac.pkg")])
                     if NSWorkspace.shared.open(URL(fileURLWithPath: u.updateReadyDir).appendingPathComponent("SakuraLauncherMac.pkg")) {
                         model.daemon?.stopDaemon()
                         NSApplication.shared.terminate(self)
                     }
                 }) {
                     Text("更新准备完成, 点此进行更新")
                         .font(.system(size: 18))
                         .padding(4)
                         .frame(maxWidth: .infinity)
                         .background(Color(red: 0, green: 0.5, blue: 0.5))
                 }.buttonStyle(PlainButtonStyle())
             } else {
                 Text("下载更新中... \(Double(u.downloadCurrent) / 1_048_576, specifier: "%.2f")MiB/\(Double(u.downloadTotal) / 1_048_576, specifier: "%.2f")MiB")
                     .font(.system(size: 18))
                     .padding(4)
                     .frame(maxWidth: .infinity)
                     .background(Color(red: 0, green: 0.5, blue: 0.5))
             }
             */
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
