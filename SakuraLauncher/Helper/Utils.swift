//
//  Utils.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/16/21.
//

import Foundation

class Utils {
    static var sakuraTimeBase = Date(timeIntervalSince1970: 1_577_836_800)

    static func parseSakuraTime(seconds: Double) -> Date { Date(timeInterval: seconds, since: sakuraTimeBase) }
}

extension String {
    func groupOf(_ match: NSTextCheckingResult, group: String) -> String {
        if let range = Range(match.range(withName: group), in: self) {
            return String(self[range])
        }
        return ""
    }
}
