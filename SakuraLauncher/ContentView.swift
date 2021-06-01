//
//  ContentView.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/1/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            sidebar
            content
        }
    }
    
    var sidebar: some View {
        List {
            LogoView()
            TabItemView(title: "隧道", iconImage: "server.rack")
            TabItemView(title: "日志", iconImage: "doc.text")
            TabItemView(title: "设置", iconImage: "gearshape")
            TabItemView(title: "关于", iconImage: "info.circle")
        }
        .frame(width: 180)
        .listStyle(SidebarListStyle())
    }
    
    var content: some View {
        List {
            Text("@fengberd: hAoYe")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
