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
    
    init() {
        UserDefaults.standard.register(defaults: [
            "logTextWrapping": true,
            "disableNotification": false,
        ])
        logTextWrapping = UserDefaults.standard.bool(forKey: "logTextWrapping")
        disableNotification = UserDefaults.standard.bool(forKey: "disableNotification")
    }
    
    // REGION: User
    
    struct UserState {
        enum Status {
            case NoLogin, Pending, LoggedIn
        }
        
        var id: Int = -1
        var name = ""
        var meta = ""
        var status = Status.NoLogin
    }

    @Published var user = UserState()
    
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
