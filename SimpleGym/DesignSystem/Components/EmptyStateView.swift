import SwiftUI

struct EmptyStateView: View {
    let iconSystemName: String
    let title: String
    let message: String

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

                Text(message)
                    .simpleGymTextStyle(.title3Regular, color: ColorTokens.labelSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: 302)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        EmptyStateView(
            iconSystemName: "dumbbell.fill",
            title: "Нет тренировок",
            message: "Добавьте упражнение\nили программу."
        )
    }
}
