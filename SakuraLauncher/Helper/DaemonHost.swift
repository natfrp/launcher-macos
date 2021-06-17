//
//  DaemonHost.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/17/21.
//

import AppKit
import Foundation

class DaemonHost {
    let model: LauncherModel
    let queue = DispatchQueue.global()

    var process: NSRunningApplication?
    var running: Bool { !(process?.isTerminated ?? true) }

    var state = 0

    init(_ model: LauncherModel) {
        self.model = model
        DispatchQueue(label: "Daemon Host Watchdog", qos: .background).async {
            let runLoop = RunLoop.current
            runLoop.add(Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
                if running {
                    return
                }

                process = findInstance()
                if running {
                    return
                }

                queue.sync {
                    if state == 2 {
                        timer.invalidate()
                        return
                    }
                    if state == 1 {
                        return
                    }
                    state = 1
                    startDaemon()
                }
            }, forMode: .default)
            runLoop.run()
        }
    }

    func findInstance() -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == "moe.berd.SakuraLauncher.Service" }
    }

    func startDaemon() {
        var url = Bundle.main.resourceURL!
        url.appendPathComponent("SakuraFrpService.app")
        NSWorkspace.shared.openApplication(at: url, configuration: .init()) { [self] app, err in
            if let err = err {
                print(err)
                return
            }
            process = app
            queue.async {
                state = 0
            }
        }
    }

    /**
     Calling this method means we want to do a complete exit.
     DO NOT call startDaemon after stopping it, create a new DaemonHost instead.
     */
    func stopDaemon() {
        queue.sync {
            state = 2
        }
        if model.pipe.connected {
            _ = model.pipe.request(.controlExit)
        }
        queue.async { [self] in
            let date = Date()
            while date.timeIntervalSinceNow > -2 {
                if !running {
                    return
                }
                usleep(100_000)
            }
            print("WTF, not a clean exit")
            process?.terminate()
        }
    }
}
