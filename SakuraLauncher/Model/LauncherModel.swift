//
//  LauncherModel.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/11/21.
//

import Foundation

class LauncherModel: ObservableObject {
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

    func Log(l: LogModel) {
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
