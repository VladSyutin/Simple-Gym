import SwiftUI

enum LiquidGlassButtonVariant: String, CaseIterable, Identifiable {
    case tinted
    case clear

    var id: String { rawValue }

    var foregroundColor: Color {
        switch self {
        case .tinted:
            return ColorTokens.white
        case .clear:
            return ColorTokens.vibrantControlPrimary
        }
    }
}

struct LiquidGlassButton: View {
    let title: LocalizedStringKey
    var systemImage: String? = nil
    var variant: LiquidGlassButtonVariant = .tinted
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxxSmall) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .medium))
                }

                Text(title)
                    .simpleGymTextStyle(.buttonLabel, color: variant.foregroundColor)
                    .lineLimit(1)
            }
            .foregroundStyle(variant.foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .glassEffect(MaterialTokens.buttonGlass(for: variant), in: Capsule())
        .opacity(isEnabled ? 1 : 0.55)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("Variants") {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        VStack(spacing: 18) {
            LiquidGlassButton(title: "Label", systemImage: "checkmark", variant: .tinted) {}
                .frame(width: 329)

            LiquidGlassButton(title: "Label", systemImage: "checkmark", variant: .clear) {}
                .frame(width: 329)
        }
        .padding(16)
    }
}

#Preview("Home CTA") {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        LiquidGlassButton(
            title: "Добавить тренировку",
            systemImage: "plus",
            variant: .tinted
        ) {}
        .padding(.horizontal, 32)
    }
}
