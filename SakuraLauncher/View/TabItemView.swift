//
//  TabItemView.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/1/21.
//

import SwiftUI

struct TabItemView: View {
    enum Tabs {
        case tunnel
        case log
        case settings
        case about
    }

    let title: String
    let iconImage: String

    let target: Tabs

    @Binding var current: Tabs

    var body: some View {
        Button(action: {
            current = target
        }) {
            HStack {
                Image(systemName: iconImage)
                    .font(.system(size: 20))
                    .frame(width: 20)
                    .padding(.trailing, 8)
                Text(title)
                    .font(.system(size: 16))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .leading)
            .padding(.leading, 20)
            .contentShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .background(current == target ? Color.secondary.opacity(0.15) : Color.clear)
        .animation(.default.speed(1.5), value: current)
        .clipShape(Capsule())
    }
}

#if DEBUG
    struct TabItemView_Previews: PreviewProvider {
        static var previews: some View {
            TabItemView(title: "SAMPLE TAB", iconImage: "gearshape", target: .about, current: .constant(.log))
        }
    }
#endif
