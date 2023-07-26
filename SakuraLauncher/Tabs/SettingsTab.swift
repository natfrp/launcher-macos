import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var model: LauncherModel

    @State var token = ""

    @State var pendingLogin = false
    @State var checkingUpdate = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("设置")
                .font(.title)
                .padding(.leading, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if model.connected && model.user.status == .loggedIn {
                        HStack {
                            Text("\(model.user.name)")
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Button("退出") {
                                pendingLogin = true
                                model.rpcWithAlert({
                                    _ = try await model.RPC?.logout(model.rpcEmpty)
                                }) { pendingLogin = false }
                            }.padding(.leading)
                                .disabled(pendingLogin)
                        }
                    } else {
                        HStack {
                            Text("登录账户:")
                            TextField("访问密钥", text: !model.connected || model.user.status == .noLogin ? $token : .constant("****************"))
                                .frame(width: 200)
                            Button(model.user.status == .pending ? "登录中..." : "登录") {
                                pendingLogin = true
                                model.rpcWithAlert({
                                    _ = try await model.RPC?.login(.with {
                                        $0.token = token
                                    })
                                }) { pendingLogin = false }
                            }
                            .disabled(pendingLogin)
                        }
                        .disabled(!model.connected || model.user.status == .pending)
                    }
                    Divider()
                    Toggle("日志自动换行", isOn: $model.logTextWrapping)
                        .toggleStyle(SwitchToggleStyle())
//                    Toggle("隧道状态通知", isOn: $model.notificationMode)
//                        .toggleStyle(SwitchToggleStyle())
                    Toggle("绕过系统代理", isOn: $model.bypassProxy)
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(!model.connected)
                    HStack {
                        Toggle("自动检查更新", isOn: $model.checkUpdate)
                            .toggleStyle(SwitchToggleStyle())
                            .disabled(!model.connected)
                        Button("立即检查") {
                            checkingUpdate = true
                            model.rpcWithAlert({
                                _ = try await model.RPC?.checkUpdate(model.rpcEmpty)
                            }) { checkingUpdate = false }
                        }
                        .disabled(!model.connected || !model.checkUpdate || checkingUpdate)
                    }
                    Divider()
                    HStack {
                        Toggle("启用远程管理", isOn: $model.enableRemoteManagement)
                            .toggleStyle(SwitchToggleStyle())
                            .disabled(!model.connected || model.config.remoteManagementKey != "SET")
                        Button("设置密码") {
                            model.showPopup(AnyView(RemoteConfigPopup()))
                        }
                    }
                    Divider()
                    HStack {
                        // TODO: Move to status menu
                        Button("退出启动器") {
                            NSApplication.shared.terminate(self)
                        }
                        Button("彻底退出启动器和服务") {
                            model.daemon?.stopDaemon()
                            NSApplication.shared.terminate(self)
                        }
                    }
                }
            }
            .padding(.leading, 24)
            .padding(.trailing, 24)
        }
    }
}

#if DEBUG
struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
            .previewLayout(.fixed(width: 602, height: 500))
            .environmentObject(LauncherModel_Preview() as LauncherModel)
    }
}
#endif
