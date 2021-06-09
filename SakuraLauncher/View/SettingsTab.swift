//
//  SettingsTab.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/3/21.
//

import SwiftUI

struct SettingsTab: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("设置")
                .font(.title)
                .padding(.leading, 24)

            ScrollView {}
        }
    }
}

#if DEBUG
    struct SettingsTab_Previews: PreviewProvider {
        static var previews: some View {
            SettingsTab()
        }
    }
#endif
