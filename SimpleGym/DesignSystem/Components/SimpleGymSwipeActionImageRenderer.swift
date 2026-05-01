import SwiftUI
import UIKit

enum SimpleGymSwipeActionImageRenderer {
    private static let buttonDiameter: CGFloat = 50
    private static let buttonHorizontalInset: CGFloat = 5
    private static let canvasSize = CGSize(
        width: buttonDiameter + buttonHorizontalInset * 2,
        height: buttonDiameter
    )

    static func make(for swipeAction: SimpleGymRowSwipeAction) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let circleRect = CGRect(
            x: buttonHorizontalInset,
            y: 0,
            width: buttonDiameter,
            height: buttonDiameter
        )
        let symbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: swipeAction.symbolPointSize,
            weight: .regular
        )
        let symbolImage = UIImage(
            systemName: swipeAction.systemImage,
            withConfiguration: symbolConfiguration
        )?.withTintColor(.white, renderingMode: .alwaysOriginal)

        return renderer.image { _ in
            let circlePath = UIBezierPath(ovalIn: circleRect)
            UIColor(swipeAction.tint).setFill()
            circlePath.fill()

            guard let symbolImage else { return }

            let symbolRect = CGRect(
                x: circleRect.midX - symbolImage.size.width / 2,
                y: circleRect.midY - symbolImage.size.height / 2,
                width: symbolImage.size.width,
                height: symbolImage.size.height
            )
            symbolImage.draw(in: symbolRect)
        }
        .withRenderingMode(.alwaysOriginal)
    }
}
