import SwiftUI

struct TextStyleModifier: ViewModifier {
    let style: Typography
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .kerning(style.tracking)
            .foregroundStyle(color)
    }
}

extension View {
    func simpleGymTextStyle(_ style: Typography, color: Color = ColorTokens.labelPrimary) -> some View {
        modifier(TextStyleModifier(style: style, color: color))
    }
}
