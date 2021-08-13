//
//  TunnelTab.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/3/21.
//

import SwiftUI

struct TunnelTab: View {
    @EnvironmentObject var model: LauncherModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("隧道")
                    .font(.title)
                    .padding(.leading, 24)

                Button(action: {
                    // TODO: Create tunnel window
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(PlainButtonStyle())
                .font(.system(size: 16))
                .padding(.leading, 8)

                Button(action: {
                    model.tunnels.removeAll()
                    model.requestWithSimpleFailureAlert(.tunnelReload)
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
                .font(.system(size: 16))
                .padding(.leading, 8)
            }
            if model.tunnels.count == 0 {
                Text("还没有隧道哦")
                    .font(.title2)
                    .foregroundColor(.primary.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.adaptive(minimum: 260), spacing: 20), count: Int(geometry.size.width / 260)), alignment: .leading, spacing: 20) {
                            ForEach(model.tunnels, id: \.id) { t in
                                TunnelItemView(tunnel: t).contextMenu {
                                    Button("删除隧道") {
                                        model.alertContent = Alert(title: Text("操作确认"), message: Text("是否确认删除隧道 #\(String(t.id)) \(t.name)?"), primaryButton: .destructive(Text("确认删除"), action: {
                                            model.deleteTunnel(t.id)
                                        }), secondaryButton: .cancel())
                                        model.showAlert = true
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 24)
                        .padding(.leading, 24)
                        .padding(.trailing, 24)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct TunnelTab_Previews: PreviewProvider {
    static var previews: some View {
        TunnelTab()
            .environmentObject(LauncherModel_Preview() as LauncherModel)
    }
}
#endif
