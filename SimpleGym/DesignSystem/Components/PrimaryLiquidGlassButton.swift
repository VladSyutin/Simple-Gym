import SwiftUI

struct PrimaryLiquidGlassButton: View {
    let title: LocalizedStringKey
    var systemImage: String = "plus"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .simpleGymTextStyle(.bodyEmphasized, color: ColorTokens.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .glassEffect(MaterialTokens.primaryAction, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 8, y: 1)
        .shadow(color: .black.opacity(0.10), radius: 1)
        .accessibilityHint("Открывает создание новой тренировки")
    }
}

#Preview {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        PrimaryLiquidGlassButton(title: "Добавить тренировку") {}
            .padding(.horizontal, Spacing.xLarge)
    }
}
