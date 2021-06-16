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
            Text("隧道")
                .font(.title)
                .padding(.leading, 24)
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
                                TunnelItemView(tunnel: t)
                            }
                        }
                        .padding()
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
