import SwiftUI

struct LiquidGlassButtonTestingScreen: View {
    @State private var buttonsEnabled = true
    @State private var lastTappedButton = "Еще не нажато"

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xLarge) {
                VStack(spacing: Spacing.xxSmall) {
                    Text("Liquid Glass Button")
                        .simpleGymTextStyle(.title2Emphasized)

                    Text("Экран для проверки Figma-кнопки на реальном iPhone.")
                        .simpleGymTextStyle(.title3Regular, color: ColorTokens.labelSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.xxLarge)

                VStack(spacing: 18) {
                    LiquidGlassButton(
                        title: "Label",
                        systemImage: "checkmark",
                        variant: .tinted,
                        isEnabled: buttonsEnabled
                    ) {
                        lastTappedButton = "Tinted"
                    }
                    .frame(width: 329)

                    LiquidGlassButton(
                        title: "Label",
                        systemImage: "checkmark",
                        variant: .clear,
                        isEnabled: buttonsEnabled
                    ) {
                        lastTappedButton = "Clear"
                    }
                    .frame(width: 329)
                }

                Toggle(isOn: $buttonsEnabled) {
                    Text("Кнопки активны")
                        .simpleGymTextStyle(.bodyEmphasized)
                }
                .frame(maxWidth: 329)
                .padding(.top, Spacing.small)

                VStack(spacing: Spacing.xxSmall) {
                    Text("Последнее нажатие")
                        .simpleGymTextStyle(.bodyEmphasized, color: ColorTokens.labelSecondary)

                    Text(lastTappedButton)
                        .simpleGymTextStyle(.title2Emphasized)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.medium)

                Text("Вкладка временно добавлена в приложение, чтобы кнопку было удобно тестировать на устройстве.")
                    .simpleGymTextStyle(.bodyEmphasized, color: ColorTokens.labelSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)

                Spacer(minLength: Spacing.xxxLarge)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.large)
            .padding(.bottom, Spacing.xxxLarge)
        }
        .background(ColorTokens.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("Buttons")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LiquidGlassButtonTestingScreen()
    }
}
