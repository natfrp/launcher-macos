//
//  NodeModel.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/15/21.
//

import Foundation

class NodeModel: ObservableObject {
    @Published var proto: Node

    var id: Int32 { proto.id }
    var name: String { proto.name }
    var host: String { proto.host }
    var acceptNew: Bool { proto.acceptNew }

    init(_ n: Node) {
        proto = n
    }

    var friendlyName: String {
        id < 0 ? name : "#\(id) \(name)"
    }
}
