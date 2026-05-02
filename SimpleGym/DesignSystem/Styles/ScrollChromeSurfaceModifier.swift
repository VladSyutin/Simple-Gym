import SwiftUI

private struct ScrollChromeSurfaceBackground: View {
    var body: some View {
        Rectangle()
            .fill(.bar)
    }
}

struct ScrollChromeSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollEdgeEffectStyle(.hard, for: .all)
            .background {
                ScrollChromeSurfaceBackground()
                    .ignoresSafeArea(edges: .top)
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
