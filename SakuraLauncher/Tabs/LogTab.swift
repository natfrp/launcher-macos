//
//  LogTab.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/3/21.
//

import SwiftUI

struct LogTab: View {
    let timeColor = Color(red: 0.31, green: 0.55, blue: 0.86),
        sourceColor = Color(red: 0.96, green: 0.87, blue: 0.70),
        dataColor = Color(red: 0.75, green: 0.75, blue: 0.75)

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var model: LauncherModel

    @State var filter = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("日志")
                    .font(.title)
                    .padding(.leading, 24)
                Button(action: {
                    model.logs = []
                    model.logFilters = [:]

                    filter = ""
                }) {
                    Image(systemName: "trash")
                }
                .buttonStyle(PlainButtonStyle())
                .font(.system(size: 16))

                Spacer()

                Menu(filter == "" ? "过滤..." : filter) {
                    Button("显示所有日志", action: {
                        filter = ""
                    })
                    ForEach(Array(model.logFilters.keys), id: \.self) { f in
                        Button(f, action: {
                            filter = f
                        })
                    }
                }
                .frame(width: 200)
                .padding(.trailing)
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if model.logTextWrapping {
                        ForEach(filter == "" ? model.logs : model.logs.filter { $0.source == filter }, id: \.self) { l in
                            logLine(l)
                        }
                    } else {
                        ForEach(filter == "" ? model.logs : model.logs.filter { $0.source == filter }, id: \.self) { l in
                            logLine(l).lineLimit(1)
                        }
                    }
                }
                .font(.custom("monaco", size: 12))
                .padding(8)
            }
            .background((colorScheme == .dark ? Color.black : Color.white).opacity(0.2))
            .border(Color.secondary.opacity(0.8), width: 2)
            .padding()
        }
    }

    private func logLine(_ l: LogModel) -> some View {
        Text("\(l.time) ").foregroundColor(timeColor) +
            Text("\(l.level.rawValue) ").foregroundColor(l.levelColor()) +
            Text("\(l.source) ").foregroundColor(sourceColor) +
            Text(l.data).foregroundColor(dataColor)
    }
}

#if DEBUG
    struct LogTab_Previews: PreviewProvider {
        static var previews: some View {
            LogTab()
                .previewLayout(.fixed(width: 602, height: 500))
                .environmentObject({ () -> LauncherModel in
                    let m = LauncherModel(preview: true)
                    for l in [
                        LogModel(source: "Service", time: "2021/01/01 23:33:33", level: .info, data: "PA47"),
                        LogModel(source: "Service", time: "2021/01/01 23:33:33", level: .warning, data: "PA47!!"),
                        LogModel(source: "Service", time: "2021/01/01 23:33:33", level: .error, data: "PA47!!!"),
                        LogModel(source: "Tunnel/JESUS_TUNNEL", time: "2021/01/01 23:33:33", level: .info, data: "[XXXXXXXX] [wdn**666.JESUS_TUNNEL] 隧道启动成功"),
                        LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: .none, data: "UDP 类型隧道启动成功"),
                        LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: .none, data: "使用 [us-sj-cuvip.sakurafrp.com:2333] 来连接到你的隧道"),
                        LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: .none, data: "或使用 IP 地址连接（不推荐）：[114.51.4.19:19810]"),
                    ] {
                        m.log(l)
                    }
                    return m
                }())
        }
    }
#endif
