import SwiftUI

private enum ScrollChromeMetrics {
    static let softEdgeHeight: CGFloat = 8
}

private struct ScrollChromeSurfaceBackground: View {
    var body: some View {
        Rectangle()
            .fill(.bar)
    }
}

private struct TranslucentChromeSurfaceBackground: View {
    private enum Metrics {
        static let topFadeOpacity: CGFloat = 0.8
    }

    var body: some View {
        GeometryReader { proxy in
            let chromeHeight = proxy.size.height
            let surfaceHeight = chromeHeight + ScrollChromeMetrics.softEdgeHeight

            LinearGradient(
                stops: [
                    .init(color: ColorTokens.backgroundPrimary.opacity(Metrics.topFadeOpacity), location: 0),
                    .init(color: ColorTokens.backgroundPrimary.opacity(0.64), location: 0.4),
                    .init(color: ColorTokens.backgroundPrimary.opacity(0.32), location: 0.78),
                    .init(color: ColorTokens.backgroundPrimary.opacity(0), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: surfaceHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
