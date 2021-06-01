//
//  TabItemView.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/1/21.
//

import SwiftUI

struct TabItemView: View {
    var title: String
    var iconImage: String
    
    var body: some View {
        HStack {
            Image(systemName: iconImage)
                .font(.system(size: 20))
                .frame(width: 20)
                .padding(.trailing, 8)
            Text(title)
                .font(.system(size: 16))
        }
        .frame(width: 180, height: 48, alignment: .leading)
        .padding(.leading, 16)
    }
}

struct TabItemView_Previews: PreviewProvider {
    static var previews: some View {
        TabItemView(title: "SAMPLE TAB", iconImage: "gearshape")
    }
}
