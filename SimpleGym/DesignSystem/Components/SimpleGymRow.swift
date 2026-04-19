import SwiftUI

struct SimpleGymRow: View {
    let title: String
    var detail: String? = nil
    var imageName: String? = nil
    var showsDisclosureIndicator = true
    var showsCheckmark = false
    var showsReorderHandle = false
    var isLifted = false

    private enum Metrics {
        static let height: CGFloat = 68
        static let imageSize: CGFloat = 68
        static let accessorySpacing: CGFloat = 16
        static let titleSpacing: CGFloat = 8
        static let reorderInset: CGFloat = 12
        static let liftedShadowRadius: CGFloat = 16
    }

    var body: some View {
        HStack(spacing: 0) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Metrics.imageSize, height: Metrics.imageSize)
                    .padding(.trailing, Spacing.xxSmall)
                    .accessibilityHidden(true)
            }

            HStack(spacing: Metrics.titleSpacing) {
                Text(title)
                    .simpleGymTextStyle(.bodyRegular)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: Metrics.accessorySpacing) {
                    if let detail {
                        Text(detail)
                            .simpleGymTextStyle(.bodyRegular, color: ColorTokens.labelSecondary)
                            .lineLimit(1)
                    }

                    if showsCheckmark {
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(ColorTokens.accentBlue)
                            .frame(width: 22, height: 22)
                            .accessibilityHidden(true)
                    }

                    if showsDisclosureIndicator {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(ColorTokens.labelTertiary)
                            .accessibilityHidden(true)
                    }
                }
                .fixedSize()
            }
            .frame(minHeight: Metrics.height)

            if showsReorderHandle {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(ColorTokens.labelTertiary)
                    .padding(.leading, Metrics.reorderInset)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, Spacing.small)
        .frame(minHeight: Metrics.height)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if isLifted {
                ColorTokens.backgroundPrimary
                    .shadow(
                        color: Color.black.opacity(0.2),
                        radius: Metrics.liftedShadowRadius
                    )
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview("Default") {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        VStack(spacing: 0) {
            SimpleGymRow(
                title: "Приседания со штангой",
                imageName: "WorkoutIllustrationLegs"
            )

            SimpleGymRow(
                title: "Жим гантелей лёжа на наклонной скамье",
                detail: "3 подхода",
                imageName: "WorkoutIllustrationBreast",
                showsCheckmark: true
            )
        }
    }
}

#Preview("Lifted") {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        SimpleGymRow(
            title: "Приседания со штангой",
            imageName: "WorkoutIllustrationLegs",
            showsDisclosureIndicator: false,
            showsReorderHandle: true,
            isLifted: true
        )
        .padding(Spacing.small)
    }
}
