import SwiftUI

struct ScrollChromeSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
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
