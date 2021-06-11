//
//  SettingsTab.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/3/21.
//

import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var model: LauncherModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("设置")
                .font(.title)
                .padding(.leading, 24)

            ScrollView {
                VStack(alignment: .leading) {
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
                .environmentObject(LauncherModel())
        }
    }
#endif
