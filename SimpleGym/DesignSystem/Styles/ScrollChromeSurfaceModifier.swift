import SwiftUI

private struct ScrollChromeSurfaceBackground: View {
    var body: some View {
        ZStack {
            ColorTokens.backgroundPrimary

            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.35)
        }
    }
}

struct ScrollChromeSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
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
