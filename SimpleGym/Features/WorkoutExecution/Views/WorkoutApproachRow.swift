import SwiftUI

struct WorkoutApproachRow: View {
    private enum Metrics {
        static let revealWidth: CGFloat = 58
        static let buttonSize: CGFloat = 50
        static let swipeActivationThreshold: CGFloat = 26
    }

    private static let settleAnimation = Animation.interactiveSpring(response: 0.28, dampingFraction: 0.86, blendDuration: 0.12)

    let exerciseID: UUID
    let index: Int
    let metricTitles: (primary: String, secondary: String)
    @Binding var approach: WorkoutApproach
    var focus: FocusState<WorkoutExecutionField?>.Binding
    var isDeleteEnabled = true
    let onDelete: () -> Void

    @State private var swipeOffset: CGFloat = 0

    private var revealProgress: CGFloat {
        max(0, min(1, -swipeOffset / Metrics.revealWidth))
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            if isDeleteEnabled {
                Button(role: .destructive) {
                    withAnimation(Self.settleAnimation) {
                        swipeOffset = 0
                    }
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.white)
                        .frame(width: Metrics.buttonSize, height: Metrics.buttonSize)
                        .background(ColorTokens.accentRed, in: Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, Spacing.small)
                .opacity(revealProgress)
                .scaleEffect(0.84 + (0.16 * revealProgress), anchor: .trailing)
                .animation(.easeOut(duration: 0.16), value: revealProgress)
            }

            contentRow
                .offset(x: swipeOffset)
                .highPriorityGesture(deleteSwipeGesture)
        }
        .clipped()
    }

    private var contentRow: some View {
        HStack(spacing: Spacing.xxxSmall) {
            Text("\(index + 1)")
                .font(.system(size: 15, weight: .semibold))
                .tracking(-0.23)
                .foregroundStyle(ColorTokens.labelTertiary)
                .frame(width: 21)

            HStack(spacing: Spacing.xxSmall) {
                approachField(
                    title: metricTitles.primary,
                    text: $approach.primaryValue,
                    metric: .primary
                )

                approachField(
                    title: metricTitles.secondary,
                    text: $approach.secondaryValue,
                    metric: .secondary
                )
            }
        }
        .padding(.leading, 7)
        .padding(.trailing, Spacing.xLarge)
    }

    private var deleteSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged { value in
                guard isDeleteEnabled else { return }
                guard abs(value.translation.width) > abs(value.translation.height) else { return }

                let baseOffset = swipeOffset == 0 ? 0 : -Metrics.revealWidth
                let rawOffset = baseOffset + value.translation.width
                let clampedOffset = max(-Metrics.revealWidth, min(0, rawOffset))
                let overshoot = rawOffset - clampedOffset

                swipeOffset = clampedOffset + (overshoot * 0.18)
            }
            .onEnded { value in
                guard isDeleteEnabled else { return }
                guard abs(value.translation.width) > abs(value.translation.height) else { return }

                let baseOffset = swipeOffset == 0 ? 0 : -Metrics.revealWidth
                let projectedOffset = baseOffset + value.predictedEndTranslation.width
                let shouldReveal = projectedOffset < -Metrics.swipeActivationThreshold

                withAnimation(Self.settleAnimation) {
                    swipeOffset = shouldReveal ? -Metrics.revealWidth : 0
                }
            }
    }

    private func approachField(
        title: String,
        text: Binding<String>,
        metric: WorkoutApproachMetric
    ) -> some View {
        let field = WorkoutExecutionField(
            exerciseID: exerciseID,
            approachID: approach.id,
            metric: metric
        )
        let isFocused = focus.wrappedValue == field

        return TextField("", text: text)
            .textFieldStyle(.plain)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 34, weight: .bold))
            .tracking(0.4)
            .tint(ColorTokens.accentBlue)
            .foregroundStyle(text.wrappedValue.isEmpty ? ColorTokens.labelTertiary.opacity(0.4) : ColorTokens.labelPrimary)
            .focused(focus, equals: field)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(ColorTokens.backgroundSecondary.opacity(0.7))
            )
            .overlay {
                if text.wrappedValue.isEmpty && !isFocused {
                    Text("—")
                        .font(.system(size: 34, weight: .bold))
                        .tracking(0.4)
                        .foregroundStyle(ColorTokens.labelTertiary.opacity(0.4))
                        .allowsHitTesting(false)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .accessibilityLabel(title)
    }
}

#Preview {
    @Previewable @State var approach = WorkoutApproach(primaryValue: "25", secondaryValue: "12")
    @FocusState var focus: WorkoutExecutionField?

    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        WorkoutApproachRow(
            exerciseID: UUID(),
            index: 0,
            metricTitles: ("ВЕС", "ПОВТОРЫ"),
            approach: $approach,
            focus: $focus
        ) {}
        .padding(.horizontal, Spacing.small)
    }
}
