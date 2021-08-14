//
//  RemoteConfigPopup.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/17/21.
//

import SwiftUI

struct RemoteConfigPopup: View {
    @EnvironmentObject var model: LauncherModel

    var close: () -> Void

    @State var password = ""

    var body: some View {
        VStack(alignment: .center) {
            Text("配置远程管理")
                .font(.title)

            SecureField("管理密码", text: $password)

            Text("该功能为高级功能，我们不推荐普通用户启用该功能，并且不为启用此功能造成的任何后果承担任何责任\n远程管理采用端到端加密进行通信，请设置一个安全的密码来确保其他人无法控制您的启动器")

            HStack {
                Button("取消") {
                    withAnimation(.linear(duration: 0.1), close)
                }
                .keyboardShortcut(.cancelAction)

                Button("更新") {
                    if password == "" {
                        return
                    }
                    model.config?.remoteKeyNew = password
                    model.pushServiceConfig()
                    withAnimation(.linear(duration: 0.1), close)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(maxWidth: 440)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color.background))
    }
}

struct RemoteConfigPopup_Previews: PreviewProvider {
    static var previews: some View {
        RemoteConfigPopup(close: {})
    }
}
