import SwiftUI

struct SimpleGymRootView: View {
    var body: some View {
        NavigationStack {
            HomeScreen()
                .toolbar(.hidden, for: .navigationBar)
        }
        .tint(ColorTokens.accentBlue)
        .environment(\.locale, Locale(identifier: "ru_RU"))
    }
}

#Preview {
    SimpleGymRootView()
}
