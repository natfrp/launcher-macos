import Foundation
import SwiftUI

extension String {
    func groupOf(_ match: NSTextCheckingResult, group: String) -> String {
        if let range = Range(match.range(withName: group), in: self) {
            return String(self[range])
        }
        return ""
    }
}

extension Color {
    static let background = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
}
