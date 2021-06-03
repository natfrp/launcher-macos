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
        Button (action: {
            current = target
        }){
            HStack {
                Image(systemName: iconImage)
                    .font(.system(size: 20))
                    .frame(width: 20)
                    .padding(.trailing, 8)
                Text(title)
                    .font(.system(size: 16))
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            }
            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 48, maxHeight: 48, alignment: .leading)
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
struct TabItemView_Previews_2 : View {
    @State var currentTab = TabItemView.Tabs.log
    
    var body: some View {
        TabItemView(title: "SAMPLE TAB", iconImage: "gearshape", target: .about, current: $currentTab)
    }
}

struct TabItemView_Previews: PreviewProvider {
    static var previews: some View {
        TabItemView_Previews_2()
    }
}
#endif
