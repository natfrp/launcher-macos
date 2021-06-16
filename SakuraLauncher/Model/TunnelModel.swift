//
//  TunnelModel.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/4/21.
//

import Foundation

class TunnelModel: ObservableObject {
    private let model: LauncherModel

    @Published var proto: Tunnel

    var id: Int32 { proto.id }
    var name: String { proto.name }
    var node: Int32 { proto.node }
    var type: String { proto.type }
    var description: String { proto.description_p }

    var nodeName: String { model.nodes[node]?.name ?? "未知节点" }

    var enabled: Bool {
        get {
            proto.status != .disabled
        }
        set {
            _ = model.pipe.request(RequestBase.with {
                $0.type = .tunnelUpdate
                $0.dataUpdateTunnel = UpdateTunnelStatus.with {
                    $0.id = id
                    $0.status = newValue ? 1 : 0
                }
            })
        }
    }

    init(_ proto: Tunnel, launcher: LauncherModel) {
        self.proto = proto
        model = launcher
    }
}
