import SwiftUI

enum ColorTokens {
    private static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        )
    }

    static let accentBlue = Color(red: 0 / 255, green: 136 / 255, blue: 255 / 255)
    static let accentOrange = Color(red: 1, green: 141 / 255, blue: 40 / 255)
    static let accentGray = Color(uiColor: .systemGray)
    static let accentRed = Color(uiColor: .systemRed)
    static let accentBlueSelectionBackground = dynamicColor(
        light: UIColor(red: 214 / 255, green: 236 / 255, blue: 255 / 255, alpha: 1),
        dark: UIColor(red: 0 / 255, green: 136 / 255, blue: 255 / 255, alpha: 0.12)
    )
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let backgroundSecondary = dynamicColor(
        light: UIColor(red: 229 / 255, green: 229 / 255, blue: 234 / 255, alpha: 1),
        dark: UIColor.secondarySystemBackground
    )
    static let labelPrimary = Color(uiColor: .label)
    static let labelSecondary = Color(uiColor: .secondaryLabel)
    static let labelTertiary = Color(uiColor: .tertiaryLabel)
    static let labelVibrantControlPrimary = dynamicColor(
        light: UIColor(red: 64 / 255, green: 64 / 255, blue: 64 / 255, alpha: 1),
        dark: UIColor.label
    )
    static let separator = Color(uiColor: .separator)
    static let separatorVibrant = dynamicColor(
        light: UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1),
        dark: UIColor.separator.withAlphaComponent(0.6)
    )
    static let white = Color.white
}
