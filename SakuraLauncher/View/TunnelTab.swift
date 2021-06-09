//
//  TunnelTab.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/3/21.
//

import SwiftUI

struct TunnelTab: View {
    @Binding var tunnels: [TunnelModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("隧道")
                .font(.title)
                .padding(.leading, 24)
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: Array(repeating: .init(.adaptive(minimum: 260), spacing: 20), count: Int(geometry.size.width / 260)), alignment: .leading, spacing: 20) {
                        ForEach(tunnels, id: \.id) { t in
                            TunnelItemView(tunnel: t)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#if DEBUG
    struct TunnelTab_Previews: PreviewProvider {
        static func tunnels() -> [TunnelModel] {
            let t = [
                TunnelModel(id: 0, name: "SampleTunnel 1", node: "#1 PA47 Node", type: "TCP", description: "2333 -> 127.0.0.1:2333"),
                TunnelModel(id: 1, name: "SampleTunnel 2", node: "#1 PA47 Node", type: "UDP", description: "2333 -> 127.0.0.1:2333"),
                TunnelModel(id: 2, name: "SampleTunnel 3", node: "#1 PA47 Node", type: "HTTP", description: "example.ltd"),
            ]
            t[2].enabled = true
            return t
        }

        static var previews: some View {
            TunnelTab(tunnels: .constant(tunnels()))
        }
    }
#endif
