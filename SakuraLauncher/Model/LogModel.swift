//
//  LogModel.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/8/21.
//

import SwiftUI

class LogModel: ObservableObject, Hashable {
    static let infoColor = Color.white,
               warningColor = Color.orange,
               errorColor = Color(red: 0.86, green: 0.31, blue: 0.21)

    static func == (lhs: LogModel, rhs: LogModel) -> Bool {
        lhs.time == rhs.time &&
            lhs.source == rhs.source &&
            lhs.data == rhs.data &&
            lhs.level == rhs.level
    }

    var source: String
    var time: String
    var level: String
    var data: String
    var levelColor: Color

    internal init(source: String, time: String, level: String, data: String, levelColor: Color) {
        self.source = source
        self.time = time
        self.level = level
        self.data = data
        self.levelColor = levelColor
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(source)
        hasher.combine(time)
        hasher.combine(level)
        hasher.combine(data)
    }
}
