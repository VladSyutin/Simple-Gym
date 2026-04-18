import SwiftUI

struct EmptyStateView: View {
    let iconSystemName: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: Spacing.small) {
            ZStack {
                Circle()
                    .fill(ColorTokens.accentBlue.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: iconSystemName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(ColorTokens.accentBlue)
            }

            VStack(spacing: 0) {
                Text(title)
                    .simpleGymTextStyle(.title2Emphasized)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)

                Text(message)
                    .simpleGymTextStyle(.title3Regular, color: ColorTokens.labelSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(width: 302)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Generic Empty State") {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        EmptyStateView(
            iconSystemName: "play.fill",
            title: "Header",
            message: "Description."
        )
    }
}

#Preview("Home Empty State") {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        EmptyStateView(
            iconSystemName: "dumbbell.fill",
            title: "Нет тренировок",
            message: "Добавьте упражнение или программу."
        )
    }
}
