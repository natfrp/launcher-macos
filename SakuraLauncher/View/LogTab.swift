//
//  LogTab.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/3/21.
//

import SwiftUI

struct LogTab: View {
    var body: some View {
        VStack (alignment: .leading) {
            Text("日志")
                .font(.title)
                .padding(.leading, 24)
            
            ScrollView {
                
            }
        }
    }
}

#if DEBUG
struct LogTab_Previews: PreviewProvider {
    static var previews: some View {
        LogTab()
    }
}
#endif
