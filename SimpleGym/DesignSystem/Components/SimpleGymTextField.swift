import SwiftUI

struct SimpleGymTextField: View {
    let prompt: LocalizedStringKey
    @Binding var text: String
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

                TextField("", text: $text)
                    .textFieldStyle(.plain)
                    .simpleGymTextStyle(.bodyRegular)
                    .submitLabel(.done)
                    .accessibilityLabel(Text(prompt))
            }
            .frame(minHeight: 51, alignment: .center)
        }
        .padding(.horizontal, Spacing.small)
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .top)
    }
}

#Preview {
    @Previewable @State var comment = ""

    ZStack {
        ColorTokens.backgroundPrimary.ignoresSafeArea()

        SimpleGymTextField(
            prompt: "Комментарий",
            text: $comment
        )
    }
}
