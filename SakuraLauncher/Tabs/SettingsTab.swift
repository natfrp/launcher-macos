//
//  SettingsTab.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/3/21.
//

import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var model: LauncherModel

    @State var token = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("设置")
                .font(.title)
                .padding(.leading, 24)

            ScrollView {
                VStack(alignment: .leading) {
                    if model.user.status == .loggedIn {
                        HStack {
                            Text("\(model.user.name) - \(model.user.meta)")
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Button("退出", action: {
                                model.user.status = .noLogin
                            }).padding(.leading)
                        }
                    } else {
                        HStack {
                            Text("登录账户:")
                            TextField("访问密钥", text: model.user.status == .noLogin ? $token : .constant("****************"))
                                .frame(width: 200)
                            Button("登录", action: {
                                if let err = model.login(token) {
                                    // TODO: show error
                                }
                            })
                        }
                        .disabled(model.user.status == .pending)
                    }
                    Divider()
                    Toggle("日志自动换行", isOn: $model.logTextWrapping)
                    Toggle("关闭状态通知", isOn: $model.disableNotification)
                }
            }
            .padding(.leading)
            .padding(.trailing)
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
