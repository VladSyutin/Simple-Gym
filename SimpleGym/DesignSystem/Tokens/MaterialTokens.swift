import SwiftUI

enum MaterialTokens {
    static func buttonGlass(for variant: LiquidGlassButtonVariant) -> Glass {
        switch variant {
        case .tinted:
            return Glass.regular
                .tint(ColorTokens.accentBlue)
                .interactive(true)
        case .clear:
            return Glass.regular
                .interactive(true)
        }
    }
}
