import SwiftUI

struct CreateTunnelPopup: View {
    @EnvironmentObject var model: LauncherModel

    @State var type = "tcp"
    @State var name = ""
    @State var note = ""
    @State var local_ip = ""
    @State var local_port = ""
    @State var remote_port = ""
    @State var node = ""

    @State var creating = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("创建隧道")
                .font(.title2)

            VStack {
                HStack {
                    TextField("本地 IP", text: $local_ip).frame(width: 160)
                    TextField("端口", text: $local_port)
                }
                TextField("隧道名称 (留空随机)", text: $name)
                TextField("备注 (可空)", text: $note)
                HStack {
                    Picker(selection: $type, label: Text("隧道类型:")) {
                        Text("TCP").tag("tcp")
                        Text("UDP").tag("udp")
                    }
                    TextField("远程端口 (留空随机)", text: $remote_port)
                }
                Picker(selection: $node, label: Text("穿透节点:")) {
                    ForEach(Array(model.nodes.filter { _, v in v.acceptNew }.keys), id: \.self) { n in
                        Text(model.nodes[n]!.friendlyName).tag(String(n))
                    }
                }
            }
            .frame(width: 264)
            .padding()

            HStack {
                Button("取消") {
                    model.closePopup()
                }
                .keyboardShortcut(.cancelAction)

                Button("创建") {
                    if node == "" {
                        model.showAlert("请选择穿透节点")
                        return
                    }
                    guard let lport = Int32(local_port), lport > 0, lport < 65536 else {
                        model.showAlert("请输入正确的本地端口")
                        return
                    }
                    creating = true
                    model.rpcWithAlert {
                        _ = try await model.RPC?.updateTunnel(.with {
                            $0.action = .add
                            $0.tunnel = Tunnel.with {
                                $0.name = name
                                $0.note = note
                                $0.type = type
                                $0.localPort = lport
                                $0.localIp = local_ip
                                $0.remote = remote_port
                                $0.node = Int32(node)!
                            }
                        })
                        model.closePopup()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(creating)
            }
        }
        .padding()
    }
}

#if DEBUG
struct CreateTunnelPopup_Previews: PreviewProvider {
    static var previews: some View {
        CreateTunnelPopup()
            .environmentObject(LauncherModel_Preview() as LauncherModel)
    }
}
#endif
