import SwiftUI

struct ScrollChromeSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    ColorTokens.backgroundPrimary

                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.9)
                        .blendMode(.multiply)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(ColorTokens.separator.opacity(0.75))
                    .frame(height: 0.5)
            }
    }
}

extension View {
    func scrollChromeSurface() -> some View {
        modifier(ScrollChromeSurfaceModifier())
    }
}
