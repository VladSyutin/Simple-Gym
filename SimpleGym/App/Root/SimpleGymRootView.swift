import SwiftUI

private enum AppTab: Hashable {
    case buttons
    case home
}

struct SimpleGymRootView: View {
    @State private var selectedTab: AppTab = .buttons

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                LiquidGlassButtonTestingScreen()
            }
            .tabItem {
                Label("Buttons", systemImage: "capsule.portrait")
            }
            .tag(AppTab.buttons)

            NavigationStack {
                HomeScreen()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.home)
        }
        .tint(ColorTokens.accentBlue)
        .environment(\.locale, Locale(identifier: "ru_RU"))
    }
}

#Preview {
    SimpleGymRootView()
}
