//
//  TunnelItemView.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/4/21.
//

import SwiftUI

struct TunnelItemView: View {
    @State var tunnel: TunnelModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            HStack (spacing: 0) {
                Text(tunnel.name)
                    .font(.title)
                Spacer()
                Toggle(isOn: $tunnel.enabled) {}
                    .toggleStyle(SwitchToggleStyle(tint: .red))
                    .labelsHidden()
            }
            Spacer()
            Text(tunnel.node)
                .font(.system(size: 14))
                .padding(.bottom, 4)
            HStack (spacing: 0) {
                Text(tunnel.description)
                    .foregroundColor(Color.primary.opacity(0.8))
                Spacer()
                Text(tunnel.type)
            }
            .font(.system(size: 13))
        }
        .padding()
        .frame(minWidth: 0, idealWidth: 256, maxWidth: 512, minHeight: 128, maxHeight: 128, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(Color.secondary.opacity(0.15))
        .cornerRadius(4)
    }
}

#if DEBUG
struct TunnelItemView_Previews: PreviewProvider {
    static var previews: some View {
        TunnelItemView(tunnel: TunnelModel(id: 0, name: "SampleTunnel", node: "#1 PA47 Node", type: "TCP", description: "2333 -> 127.0.0.1:2333"))
    }
}
#endif
