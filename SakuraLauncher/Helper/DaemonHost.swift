import AppKit
import Foundation

class DaemonHost {
    let model: LauncherModel

    var process: NSRunningApplication?
    var running: Bool { !(process?.isTerminated ?? true) }

    init(_ model: LauncherModel) {
        self.model = model
        Task(priority: .background) {
            var counter = 0, suppressed = false
            while true {
                if process == nil, let p = findInstance() {
                    process = p
                }
                if !running, await model.connected == false {
                    let opts = NSWorkspace.OpenConfiguration()
                    opts.activates = false
                    opts.addsToRecentItems = false
                    opts.promptsUserIfNeeded = false

                    NSWorkspace.shared.openApplication(
                        at: Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS/natfrp-service.app"),
                        configuration: opts
                    ) { _, _ in
                        // ignored, we will use findInstance to get app
                        // this async block won't be called until app exits
                    }

                    counter += 1

                    if counter > 4, !suppressed {
                        let t = await Task { @MainActor in
                            let alert = NSAlert()
                            
                            alert.messageText = "守护进程启动失败"
                            alert.informativeText = "按 \"忽略\" 屏蔽此提示, \"终止\" 退出启动器"
                            alert.alertStyle = .critical
                            alert.addButton(withTitle: "重试")
                            alert.addButton(withTitle: "忽略")
                            alert.addButton(withTitle: "终止")
                            
                            switch alert.runModal() {
                            case .alertSecondButtonReturn:
                                return true
                            case .alertThirdButtonReturn:
                                NSApplication.shared.terminate(self)
                            default:
                                break
                            }
                            return false
                        }.value
                        if t {
                            suppressed = true
                        }
                    }
                } else {
                    counter = 0
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func findInstance() -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == "com.natfrp.launcher" }
    }

    func fullShutdown() {
        Task { @MainActor in
            defer {
                NSApplication.shared.terminate(self)
            }

            if model.connected {
                _ = try? await model.RPC?.shutdown(model.rpcEmpty)
            }

            guard let p = process else {
                return
            }
            var c = 0
            while c < 100 {
                if p.isTerminated {
                    return
                }

                try? await Task.sleep(nanoseconds: 100_000_000)
                c = c + 1
            }
            p.forceTerminate()
        }
    }
}
