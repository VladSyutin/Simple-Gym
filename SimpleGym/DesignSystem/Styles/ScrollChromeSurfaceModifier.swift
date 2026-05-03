import SwiftUI

private struct ScrollChromeSurfaceBackground: View {
    var body: some View {
        Rectangle()
            .fill(.bar)
    }
}

private struct TranslucentChromeSurfaceBackground: View {
    private enum Metrics {
        static let fadeExtension: CGFloat = 28
    }

    private func fadeStopLocation(for chromeHeight: CGFloat) -> CGFloat {
        let fullHeight = chromeHeight + Metrics.fadeExtension
        guard fullHeight > 0 else { return 0 }
        return max(0, min(1, chromeHeight / fullHeight))
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: proxy.size.height)

                LinearGradient(
                    colors: [
                        ColorTokens.backgroundPrimary,
                        ColorTokens.backgroundPrimary.opacity(0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: Metrics.fadeExtension)
            }
        }
    }
}

private struct TopScrollChromeSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollEdgeEffectStyle(.soft, for: .top)
            .background(alignment: .top) {
                TranslucentChromeSurfaceBackground()
                    .ignoresSafeArea(edges: .top)
            }
            .zIndex(1)
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

    func topScrollChromeSurface() -> some View {
        modifier(TopScrollChromeSurfaceModifier())
    }
}
