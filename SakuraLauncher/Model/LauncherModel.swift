//
//  LauncherModel.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/11/21.
//

import SwiftUI

class LauncherModel: ObservableObject {
    let pipe = SocketClient(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "moe.berd.SakuraL")!.path + "/Library/Caches")
    var daemon: DaemonHost?

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

        logDateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        daemon = DaemonHost(self)
        pipe.onPushMessage = onServerPush

        // This looks silly, but prevents the alert from showing multiple times (a bug)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            if let alert = queuedAlert {
                queuedAlert = nil
                alertContent = Alert(title: Text(alert.1), message: Text(alert.0))
                showAlert = true
            }
        }

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] _ in
            if pipe.connected {
                return
            }
            connected = false

            if !pipe.connect() {
                return
            }
            if !syncUser() || !syncAll() {
                pipe.close()
                return
            }
            connected = true
        }
    }

    // MARK: - Daemon IPC

    func syncUser() -> Bool {
        let resp = pipe.request(.userInfo)
        if resp.success {
            user = resp.dataUser
        }
        return resp.success
    }

    func syncAll() -> Bool {
        if !syncLog() || !syncConfig() || !syncUpdate() {
            return false
        }
        _ = syncNodes()
        _ = syncTunnels()
        return true
    }

    func syncLog() -> Bool {
        let resp = pipe.request(.logGet)
        DispatchQueue.main.async { [self] in
            if resp.success {
                logs.removeAll()
                for l in resp.dataLog.data {
                    log(l)
                }
            } else {
                showAlert(resp.message, title: "日志同步失败")
            }
        }
        return resp.success
    }

    func syncConfig() -> Bool {
        let resp = pipe.request(.controlConfigGet)
        DispatchQueue.main.async { [self] in
            if resp.success {
                config = resp.dataConfig
            } else {
                showAlert(resp.message, title: "守护进程配置同步失败")
            }
        }
        return resp.success
    }

    func syncUpdate() -> Bool {
        let resp = pipe.request(.controlGetUpdate)
        DispatchQueue.main.async { [self] in
            if resp.success {
                update = resp.dataUpdate
            } else {
                showAlert(resp.message, title: "更新状态同步失败")
            }
        }
        return resp.success
    }

    func syncNodes() -> Bool {
        let resp = pipe.request(.nodeList)
        if resp.success {
            DispatchQueue.main.async {
                self.loadNodes(resp.dataNodes.nodes)
            }
        }
        return resp.success
    }

    func syncTunnels() -> Bool {
        let resp = pipe.request(.tunnelList)
        if resp.success {
            DispatchQueue.main.async {
                self.loadTunnels(resp.dataTunnels.tunnels)
            }
        }
        return resp.success
    }

    func onServerPush(msg: PushMessageBase) {
        switch msg.type {
        case .updateUser:
            user = msg.dataUser
        case .updateTunnel:
            for t in tunnels {
                if t.id == msg.dataTunnel.id {
                    t.proto = msg.dataTunnel
                    break
                }
            }
        case .updateTunnels:
            loadTunnels(msg.dataTunnels.tunnels)
        case .updateNodes:
            nodes.removeAll()
            loadNodes(msg.dataNodes.nodes)
        case .appendLog:
            for l in msg.dataLog.data {
                log(l)
            }
        case .pushUpdate:
            update = msg.dataUpdate
            if checkingUpdate {
                checkingUpdate = false
                if !update!.updateAvailable {
                    showAlert("您当前使用的启动器为最新版本")
                }
            }
        case .pushConfig:
            config = msg.dataConfig
        default:
            assertionFailure("收到未知 PUSH")
        }
    }

    func requestWithSimpleFailureAlert(_ msg: MessageID, _ success: (() -> Void)? = nil) {
        requestWithSimpleFailureAlert(RequestBase.with {
            $0.type = msg
        }, success)
    }

    func requestWithSimpleFailureAlert(_ msg: RequestBase, _ success: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            let resp = pipe.request(msg)
            if !resp.success {
                showAlert(resp.message, title: "错误")
            } else if let s = success {
                DispatchQueue.main.sync(execute: s)
            }
        }
    }

    // MARK: - View: Generic & User

    var queuedAlert: (String, String)?

    @Published var showAlert: Bool = false
    @Published var alertContent: Alert?
    @Published var popupContent: AnyView?

    func showAlert(_ text: String, title: String = "提示") {
        DispatchQueue.main.async {
            self.queuedAlert = (text, title)
        }
    }

    func showPopup(_ popup: AnyView) {
        withAnimation(.linear(duration: 0.1)) {
            popupContent = popup
        }
    }

    func closePopup() {
        withAnimation(.linear(duration: 0.1)) {
            popupContent = nil
        }
    }

    @Published var connected: Bool = false

    @Published var user = User()

    // MARK: - View: Launcher Settings

    @Published var logTextWrapping: Bool {
        willSet { UserDefaults.standard.setValue(newValue, forKey: "logTextWrapping") }
    }

    @Published var disableNotification: Bool {
        willSet { UserDefaults.standard.setValue(newValue, forKey: "disableNotification") }
    }

    // MARK: - Tunnels & Nodes

    @Published var nodes: [Int32: NodeModel] = [:]

    private func loadNodes(_ list: [Node]) {
        nodes.removeAll()
        for n in list {
            nodes[n.id] = NodeModel(n)
        }
    }

    @Published var tunnels: [TunnelModel] = []

    private func loadTunnels(_ list: [Tunnel]) {
        tunnels.removeAll()
        for t in list {
            tunnels.append(TunnelModel(t, launcher: self))
        }
    }

    func deleteTunnel(_ id: Int32) {
        requestWithSimpleFailureAlert(RequestBase.with {
            $0.type = .tunnelDelete
            $0.dataID = id
        })
    }

    // MARK: - Logging

    @Published var logs: [LogModel] = []
    @Published var logFilters: [String: Int] = [:]

    private var logDateFormatter = DateFormatter()

    func log(_ l: Log) {
        let entry = LogModel(source: l.source, data: l.data)
        if l.category == 0 // CATEGORY_FRPC
        {
            entry.source = "Tunnel/" + entry.source
            if let match = LogModel.pattern.firstMatch(in: l.data, range: NSRange(l.data.startIndex..., in: l.data)) {
                entry.time = l.data.groupOf(match, group: "Time")
                entry.data = l.data.groupOf(match, group: "Content")
                switch l.data.groupOf(match, group: "Level") {
                case "W":
                    entry.level = .warning
                case "E":
                    entry.level = .error
                case "I":
                    fallthrough
                default:
                    entry.level = .info
                }
            }
        } else {
            entry.time = logDateFormatter.string(from: Utils.parseSakuraTime(seconds: Double(l.time)))
            switch l.category {
            case 2:
                entry.level = .warning
            case 3:
                entry.level = .error
            case 4: // Notice INFO
                fallthrough
            case 5: // Notice WARNING
                fallthrough
            case 6: // Notice ERROR
                if !disableNotification {
                    // TODO: Notification
                }
                return
            case 1:
                fallthrough
            default:
                entry.level = .info
            }
        }

        logs.append(entry)
        if logFilters[entry.source] == nil {
            logFilters[entry.source] = 1
        } else {
            logFilters[entry.source]! += 1
        }

        while logs.count > 4096 {
            let del = logs.remove(at: 0)
            logFilters[del.source]! -= 1
            if logFilters[del.source]! == 0 {
                logFilters.removeValue(forKey: del.source)
            }
        }
    }

    // MARK: - Service Config & Update

    @Published var config: ServiceConfig?

    @Published var update: UpdateStatus?
    @Published var checkingUpdate = false

    var bypassProxy: Bool {
        get {
            config?.bypassProxy ?? false
        }
        set {
            config?.bypassProxy = newValue
            pushServiceConfig()
        }
    }

    var checkUpdate: Bool {
        get {
            update != nil && config?.updateInterval ?? -1 != -1
        }
        set {
            config?.updateInterval = newValue ? 86400 : -1
            pushServiceConfig()
        }
    }

    var enableRemoteManagement: Bool {
        get {
            (config?.remoteManagement ?? false) && (config?.remoteKeySet ?? false)
        }
        set {
            config?.remoteManagement = newValue
            pushServiceConfig()
        }
    }

    func pushServiceConfig() {
        guard let config = config else {
            return
        }
        requestWithSimpleFailureAlert(RequestBase.with {
            $0.type = .controlConfigSet
            $0.dataConfig = config
        })
    }
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

        logs = [
            LogModel(source: "Service", data: "PA47", time: "2021/01/01 23:33:33", level: .info),
            LogModel(source: "Service", data: "PA47!!", time: "2021/01/01 23:33:33", level: .warning),
            LogModel(source: "Service", data: "PA47!!!", time: "2021/01/01 23:33:33", level: .error),
            LogModel(source: "Tunnel/JESUS_TUNNEL", data: "[XXXXXXXX] [wdn**666.JESUS_TUNNEL] 隧道启动成功", time: "2021/01/01 23:33:33", level: .info),
            LogModel(source: "Tunnel/JESUS_TUNNEL", data: "UDP 类型隧道启动成功", time: "", level: .none),
            LogModel(source: "Tunnel/JESUS_TUNNEL", data: "使用 [us-sj-cuvip.sakurafrp.com:2333] 来连接到你的隧道", time: "", level: .none),
            LogModel(source: "Tunnel/JESUS_TUNNEL", data: "或使用 IP 地址连接（不推荐）：[114.51.4.19:19810]", time: "", level: .none),
        ]
    }
}
#endif
