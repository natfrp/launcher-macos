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

    @State var filter = ""

    @Binding var logs: [LogModel]
    @Binding var filters: [String: Int]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("日志")
                    .font(.title)
                    .padding(.leading, 24)
                Button(action: {
                    logs = []
                    filters = [:]
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
                    ForEach(Array(filters.keys), id: \.self) { f in
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
                    ForEach(filter == "" ? logs : logs.filter { $0.source == filter }, id: \.self) { l in
                        HStack(alignment: .center, spacing: 6) {
                            Text(l.time)
                                .foregroundColor(timeColor)
                            Text(l.level)
                                .foregroundColor(l.levelColor)
                            Text(l.source)
                                .foregroundColor(sourceColor)
                            Text(l.data)
                                .foregroundColor(dataColor)
                        }
                    }
                }
                .font(.custom("monaco", size: 12))
                .padding(8)
            }
            .background((colorScheme == .dark ? Color.black : Color.white).opacity(0.2))
            .border(Color.secondary.opacity(0.8), width: 2)
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
        }
    }
}

#if DEBUG
    struct LogTab_Previews: PreviewProvider {
        static var previews: some View {
            LogTab(logs: .constant([
                LogModel(source: "Service", time: "2021/01/01 23:33:33", level: "I", data: "PA47", levelColor: LogModel.infoColor),
                LogModel(source: "Service", time: "2021/01/01 23:33:33", level: "W", data: "PA47!!", levelColor: LogModel.warningColor),
                LogModel(source: "Service", time: "2021/01/01 23:33:33", level: "E", data: "PA47!!!", levelColor: LogModel.errorColor),
                LogModel(source: "Tunnel/JESUS_TUNNEL", time: "2021/01/01 23:33:33", level: "I", data: "[XXXXXXXX] [wdn**666.JESUS_TUNNEL] 隧道启动成功", levelColor: LogModel.infoColor),
                LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: "", data: "UDP 类型隧道启动成功", levelColor: LogModel.infoColor),
                LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: "", data: "使用 [us-sj-cuvip.sakurafrp.com:2333] 来连接到你的隧道", levelColor: LogModel.infoColor),
                LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: "", data: "或使用 IP 地址连接（不推荐）：[114.51.4.19:19810]", levelColor: LogModel.infoColor),
            ]), filters: .constant([:]))
                .previewLayout(.fixed(width: 782, height: 500))
        }
    }
#endif
