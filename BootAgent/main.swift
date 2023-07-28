import Cocoa

let d = BootAgentDelegate()
NSApplication.shared.delegate = d
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
