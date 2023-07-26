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
//                    _ = model.pipe.request(.logClear)

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
                        ForEach(filter == "" ? model.logs : model.logs.filter { $0.source == filter }, id: \.id) { l in
                            logLine(l)
                        }
                    } else {
                        ForEach(filter == "" ? model.logs : model.logs.filter { $0.source == filter }, id: \.id) { l in
                            logLine(l).lineLimit(1)
                        }
                    }
                }
                .font(.custom("monaco", size: 12))
                .padding(8)
            }
            .background(Color.black.opacity(colorScheme == .dark ? 0.2 : 0.8))
            .border(colorScheme == .dark ? Color.secondary.opacity(0.8) : Color.gray, width: 2)
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
            .environmentObject(LauncherModel_Preview() as LauncherModel)
    }
}
#endif
