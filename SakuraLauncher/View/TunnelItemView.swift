import SwiftUI

struct TunnelItemView: View {
    @ObservedObject var tunnel: TunnelModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(tunnel.name)
                    .font(.title)
                Spacer()
                Toggle(isOn: $tunnel.enabled) {}
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .labelsHidden()
            }
            Spacer()
            Text("#\(tunnel.node) \(tunnel.nodeName)")
                .font(.system(size: 14))
                .padding(.bottom, 4)
            HStack(spacing: 0) {
                Text(tunnel.description)
                    .foregroundColor(Color.primary.opacity(0.8))
                Spacer()
                Text(tunnel.type)
            }
            .font(.system(size: 13))
        }
        .padding()
        .frame(minWidth: 0, idealWidth: 256, maxWidth: 512, minHeight: 128, maxHeight: 128, alignment: .center)
        .background(Color.secondary.opacity(0.15))
        .cornerRadius(4)
    }
}

#if DEBUG
struct TunnelItemView_Previews: PreviewProvider {
    static var model = LauncherModel_Preview()

    static var previews: some View {
        TunnelItemView(tunnel: model.tunnels[0])
    }
}
#endif
