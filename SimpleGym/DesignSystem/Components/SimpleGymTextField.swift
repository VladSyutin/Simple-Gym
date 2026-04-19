import SwiftUI

struct SimpleGymTextField: View {
    let prompt: LocalizedStringKey
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    @Environment(\.displayScale) private var displayScale

    private var separatorHeight: CGFloat {
        1 / max(displayScale, 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ColorTokens.separatorVibrant)
                .frame(height: separatorHeight)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(prompt)
                        .font(Typography.bodyMedium.font)
                        .kerning(Typography.bodyMedium.tracking)
                        .foregroundStyle(ColorTokens.labelTertiary)
                        .allowsHitTesting(false)
                }

                TextField("", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .simpleGymTextStyle(.bodyRegular)
                    .lineLimit(1...4)
                    .focused(isFocused)
                    .accessibilityLabel(Text(prompt))
            }
            .frame(minHeight: 51, alignment: .top)
            .padding(.vertical, Spacing.xSmall)
        }
        .padding(.horizontal, Spacing.small)
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .top)
    }
}

#Preview {
    @Previewable @State var comment = ""
    @FocusState var isFocused: Bool

    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        SimpleGymTextField(
            prompt: "Комментарий",
            text: $comment,
            isFocused: $isFocused
        )
    }
}
