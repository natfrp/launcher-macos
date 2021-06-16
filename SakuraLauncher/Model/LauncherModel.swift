//
//  LauncherModel.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/11/21.
//

import Foundation

class LauncherModel: ObservableObject {
    // REGION: Settings
    
    @Published var logTextWrapping: Bool {
        willSet { UserDefaults.standard.setValue(newValue, forKey: "logTextWrapping") }
    }
    
    @Published var disableNotification: Bool {
        willSet { UserDefaults.standard.setValue(newValue, forKey: "disableNotification") }
    }
    
#if DEBUG
    init(preview: Bool) {
        assert(preview)
        logTextWrapping = true
        disableNotification = false
    }
#endif

    init() {
        UserDefaults.standard.register(defaults: [
            "logTextWrapping": true,
            "disableNotification": false,
        ])
        logTextWrapping = UserDefaults.standard.bool(forKey: "logTextWrapping")
        disableNotification = UserDefaults.standard.bool(forKey: "disableNotification")

        // TODO: Start
    }

    }
    
    @Published var connected: Bool = false
    
    let pipe = SocketClient("/tmp/")

    // REGION: User

    @Published var user = User()
    
    func login(_ token: String, autologin: Bool = false) -> String? {
        if user.status != .noLogin {
            return user.status == .pending ? "操作进行中, 请稍候" : "用户已登录"
        }
        if token.count < 16 {
            return "访问密钥无效, 请检查您的输入是否正确"
        }
        user.status = .pending
        
        
        
        return nil
    }
    
    // MARK: - Tunnels & Nodes

    @Published var nodes: [Int32: NodeModel] = [:]

    @Published var tunnels: [TunnelModel] = []

    // REGION: Logging
    
    @Published var logs: [LogModel] = []
    @Published var logFilters: [String: Int] = [:]

    func log(_ l: LogModel) {
        logs.append(l)
        if logFilters[l.source] == nil {
            logFilters[l.source] = 1
        } else {
            logFilters[l.source]! += 1
        }
        
        while logs.count > 4096 {
            let del = logs.remove(at: 0)
            logFilters[del.source]! -= 1
        }
    }
    
    // REGION: Tunnels
    
    @Published var tunnels: [TunnelModel] = []
}

#if DEBUG
class LauncherModel_Preview: LauncherModel {
    override init() {
        super.init(preview: true)
        nodes[1] = NodeModel(Node.with {
            $0.id = 1
            $0.name = "PA47 Node"
            $0.host = "1.2.3.4"
        })
        nodes[2] = NodeModel(Node.with {
            $0.id = 2
            $0.name = "LMAO BGP"
            $0.host = "66.66.66.66"
        })

        tunnels.append(TunnelModel(Tunnel.with {
            $0.id = 1
            $0.name = "SampleTunnel 1"
            $0.node = 1
            $0.type = "TCP"
            $0.description_p = "2333 -> 127.0.0.1:2333"
        }, launcher: self))
        tunnels.append(TunnelModel(Tunnel.with {
            $0.id = 2
            $0.name = "SampleTunnel 2"
            $0.node = 2
            $0.type = "UDP"
            $0.description_p = "2333 -> 127.0.0.1:6666"
        }, launcher: self))
        tunnels.append(TunnelModel(Tunnel.with {
            $0.id = 3
            $0.name = "SampleTunnel 3"
            $0.node = 3
            $0.type = "HTTP"
            $0.description_p = "berd.moe -> 127.0.0.1:8080"
        }, launcher: self))

        for l in [
            LogModel(source: "Service", time: "2021/01/01 23:33:33", level: .info, data: "PA47"),
            LogModel(source: "Service", time: "2021/01/01 23:33:33", level: .warning, data: "PA47!!"),
            LogModel(source: "Service", time: "2021/01/01 23:33:33", level: .error, data: "PA47!!!"),
            LogModel(source: "Tunnel/JESUS_TUNNEL", time: "2021/01/01 23:33:33", level: .info, data: "[XXXXXXXX] [wdn**666.JESUS_TUNNEL] 隧道启动成功"),
            LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: .none, data: "UDP 类型隧道启动成功"),
            LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: .none, data: "使用 [us-sj-cuvip.sakurafrp.com:2333] 来连接到你的隧道"),
            LogModel(source: "Tunnel/JESUS_TUNNEL", time: "", level: .none, data: "或使用 IP 地址连接（不推荐）：[114.51.4.19:19810]"),
        ] {
            log(l)
        }
    }
}
#endif
