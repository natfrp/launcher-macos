import Foundation

@MainActor class TunnelModel: ObservableObject {
    private let model: LauncherModel

    @Published var proto: Tunnel

    var id: Int32 { proto.id }
    var name: String { proto.name }
    var node: Int32 { proto.node }
    var type: String { proto.type.uppercased() }
    var description: String {
        switch proto.type {
        case "tcp", "udp":
            return "\(proto.remote) → \(proto.localIp):\(proto.localPort)"
        case "http", "https":
            return "\(proto.type.uppercased()) → \(proto.localIp):\(proto.localPort)"
        case "etcp", "eudp":
            return "\(proto.localIp):\(proto.localPort)"
        default:
            return "-"
        }
    }

    var nodeName: String { model.nodes[node]?.name ?? "未知节点" }

    var enabled: Bool {
        get { proto.enabled }
        set {
            model.rpcWithAlert { [self] in
                _ = try await model.RPC?.updateTunnel(.with {
                    $0.action = .update
                    $0.tunnel = .with {
                        $0.id = proto.id
                        $0.enabled = newValue
                    }
                })
            }
        }
    }

    init(_ proto: Tunnel, launcher: LauncherModel) {
        self.proto = proto
        model = launcher
    }
}
