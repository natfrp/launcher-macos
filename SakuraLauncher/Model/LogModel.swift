//
//  LogModel.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/8/21.
//

import SwiftUI

enum LogLevel: String {
    case info = "I",
         warning = "W",
         error = "E"
    case none = ""
}

class LogModel: ObservableObject, Hashable {
    var source: String
    var time: String
    var level: LogLevel
    var data: String

    internal init(source: String, time: String, level: LogLevel, data: String) {
        self.source = source
        self.time = time
        self.level = level
        self.data = data
    }

    func levelColor() -> Color {
        switch level {
        case .warning:
            return Color.orange
        case .error:
            return Color(red: 0.86, green: 0.31, blue: 0.21)
        default:
            return Color.white
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(source)
        hasher.combine(time)
        hasher.combine(level)
        hasher.combine(data)
    }

    static func == (lhs: LogModel, rhs: LogModel) -> Bool {
        lhs.time == rhs.time &&
            lhs.source == rhs.source &&
            lhs.data == rhs.data &&
            lhs.level == rhs.level
    }
}
