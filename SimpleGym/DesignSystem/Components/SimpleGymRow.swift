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
    @Environment(\.colorScheme) private var colorScheme

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
        static let liftedShadowRadius: CGFloat = 16
        static let disclosureIndicatorSize: CGFloat = 14
        static let reorderHandleSize: CGFloat = 15
    }

    static let height: CGFloat = Metrics.height

    private var backgroundShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
    }

    private var backgroundFillColor: Color {
        let interfaceStyle: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        let traitCollection = UITraitCollection(userInterfaceStyle: interfaceStyle)
        let primaryColor = UIColor(ColorTokens.backgroundPrimary).resolvedColor(with: traitCollection)
        let secondaryColor = UIColor(ColorTokens.backgroundSecondary).resolvedColor(with: traitCollection)
        let clampedProgress = max(0, min(1, swipeRevealProgress))

        return Color(
            uiColor: primaryColor.mixed(with: secondaryColor, progress: clampedProgress)
        )
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
        .background {
            backgroundShape
                .fill(backgroundFillColor)
                .opacity(1)
                .shadow(
                    color: isLifted ? Color.black.opacity(0.2) : .clear,
                    radius: isLifted ? Metrics.liftedShadowRadius : 0
                )
        }
        .clipShape(backgroundShape)
        .contentShape(backgroundShape)
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

private extension UIColor {
    func mixed(with color: UIColor, progress: CGFloat) -> UIColor {
        let clampedProgress = max(0, min(1, progress))
        let source = rgbaComponents
        let destination = color.rgbaComponents

        return UIColor(
            red: source.red + (destination.red - source.red) * clampedProgress,
            green: source.green + (destination.green - source.green) * clampedProgress,
            blue: source.blue + (destination.blue - source.blue) * clampedProgress,
            alpha: source.alpha + (destination.alpha - source.alpha) * clampedProgress
        )
    }

    private var rgbaComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red, green, blue, alpha)
        }

        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            return (white, white, white, alpha)
        }

        return (0, 0, 0, 0)
    }
}
