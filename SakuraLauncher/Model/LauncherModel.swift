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
    
    init(preview: Bool) {
        if preview {
            logTextWrapping = true
            disableNotification = false
            return
        }

        UserDefaults.standard.register(defaults: [
            "logTextWrapping": true,
            "disableNotification": false,
        ])
        logTextWrapping = UserDefaults.standard.bool(forKey: "logTextWrapping")
        disableNotification = UserDefaults.standard.bool(forKey: "disableNotification")
    }
    
    @Published var connected: Bool = false
    
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
