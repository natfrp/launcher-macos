//
//  TunnelModel.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/4/21.
//

import Foundation

class TunnelModel: ObservableObject {
    var id: Int
    var name: String
    var node: String
    var type: String
    var description: String

    @Published var enabled: Bool = false

    init(id: Int = -1, name: String = "", node: String = "", type: String = "", description: String = "") {
        self.id = id
        self.name = name
        self.node = node
        self.type = type
        self.description = description
    }

    // TODO:
}
