import SwiftUI

struct LogoView: View {
    var body: some View {
        HStack {
            Spacer()
            Image("Logo")
                .frame(width: 120, height: 120, alignment: .center)
                .clipShape(Circle())
                .shadow(radius: 8)
            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, 24)
    }
}

#if DEBUG
    struct LogoView_Previews: PreviewProvider {
        static var previews: some View {
            LogoView()
        }
    }
#endif
