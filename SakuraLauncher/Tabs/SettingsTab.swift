import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var model: LauncherModel

    @State var token = ""

    @State var pendingLogin = false
    @State var pendingRefresh = false
    @State var checkingUpdate = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                accountOpts
                Divider()
                launcherOpts
                Divider()
                serviceOpts
            }
        }
        .padding(.leading, 24)
        .padding(.trailing, 24)
    }

    var accountOpts: some View {
        VStack(alignment: .leading, spacing: 16) {
            if model.user.status == .loggedIn {
                HStack {
                    AsyncImage(url: URL(string: model.user.avatar)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 8) {
                        Text("#\(model.user.id) \(model.user.name)")
                            .font(.title3)
                        Text("\(model.user.group.name) \(model.user.speed)")
                            .font(.subheadline)
                    }
                    .padding(.leading, 12)

                    Button("刷新节点列表") {
                        pendingRefresh = true
                        model.rpcWithAlert({
                            _ = try await model.RPC?.reloadNodes(model.rpcEmpty)
                        }) { pendingRefresh = false }
                    }
                    .padding(.leading)
                    .disabled(pendingRefresh)

                    Button("退出") {
                        pendingLogin = true
                        model.rpcWithAlert({
                            _ = try await model.RPC?.logout(model.rpcEmpty)
                        }) { pendingLogin = false }
                    }
                    .padding(.leading)
                    .disabled(pendingLogin)
                }
                .disabled(!model.connected)
            } else {
                HStack(spacing: 16) {
                    Text("登录账户:")
                    TextField("访问密钥", text: model.user.status == .noLogin ? $token : .constant("****************"))
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
        }
    }

    var launcherOpts: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("启动器").font(.title2)
            HStack {
                Text("隧道状态通知: ")
                Menu(model.notificationMode == 0 ? "显示所有" : model.notificationMode == 1 ? "隐藏所有" : "隐藏启动成功") {
                    Button("显示所有", action: { model.notificationMode = 0 })
                    Button("隐藏所有", action: { model.notificationMode = 1 })
                    Button("隐藏启动成功", action: { model.notificationMode = 2 })
                }
                .frame(width: 150)
            }
        }
    }

    var serviceOpts: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("核心服务").font(.title2)
            Toggle("绕过系统代理", isOn: $model.bypassProxy)
                .toggleStyle(SwitchToggleStyle())
                .disabled(!model.connected)
            HStack(spacing: 16) {
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
            Text("高级设置").font(.title2)
            Toggle("强制使能 frpc TLS", isOn: $model.enableFrpcTls)
                .toggleStyle(SwitchToggleStyle())
                .disabled(!model.connected)
            HStack(spacing: 16) {
                Toggle("启用远程管理", isOn: $model.enableRemoteManagement)
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(!model.connected || model.config.remoteManagementKey != "SET")
                Button("设置密码") {
                    model.showPopup(AnyView(RemoteConfigPopup()))
                }
            }
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
