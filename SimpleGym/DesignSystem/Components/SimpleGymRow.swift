import SwiftUI

struct SimpleGymRowSwipeAction: Identifiable {
    let id = UUID()
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color
    var role: ButtonRole? = nil
    var symbolPointSize: CGFloat = 17
    let action: () -> Void
}

struct SimpleGymRow: View {
    let title: String
    var detail: String? = nil
    var imageName: String? = nil
    var showsDisclosureIndicator = true
    var showsCheckmark = false
    var showsReorderHandle = false
    var isLifted = false
    var swipeRevealProgress: CGFloat = 0

    private enum Metrics {
        static let height: CGFloat = 68
        static let imageSize: CGFloat = 68
        static let accessorySpacing: CGFloat = 16
        static let titleSpacing: CGFloat = 8
        static let reorderInset: CGFloat = 12
        static let disclosureIndicatorSize: CGFloat = 14
        static let reorderHandleSize: CGFloat = 15
    }

    static let height: CGFloat = Metrics.height

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
                            .font(.system(size: Metrics.disclosureIndicatorSize, weight: .semibold))
                            .foregroundStyle(ColorTokens.labelTertiary)
                            .accessibilityHidden(true)
                    }
                }
                .fixedSize()
            }
            .frame(minHeight: Metrics.height)

            if showsReorderHandle {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: Metrics.reorderHandleSize, weight: .regular))
                    .foregroundStyle(ColorTokens.labelTertiary)
                    .padding(.leading, Metrics.reorderInset)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, Spacing.small)
        .frame(minHeight: Metrics.height)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview("Default") {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        VStack(spacing: Spacing.small) {
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

#Preview("Swipe") {
    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        SimpleGymRow(
            title: "Приседания со штангой",
            imageName: "WorkoutIllustrationLegs",
            swipeRevealProgress: 1
        )
        .padding(Spacing.small)
    }
}
