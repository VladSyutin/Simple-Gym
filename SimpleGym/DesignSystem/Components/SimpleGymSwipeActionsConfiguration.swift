import SwiftUI
import UIKit

@MainActor
enum SimpleGymSwipeActionsConfiguration {
    static func make(
        actions: [SimpleGymRowSwipeAction],
        handler: @escaping (SimpleGymRowSwipeAction, @escaping (Bool) -> Void) -> Void
    ) -> UISwipeActionsConfiguration? {
        let resolvedActions = trailingActionsOrderedForFullSwipe(actions)
        guard !resolvedActions.isEmpty else { return nil }

        let contextualActions = resolvedActions.map { swipeAction in
            let style: UIContextualAction.Style = swipeAction.role == .destructive ? .destructive : .normal
            let action = UIContextualAction(style: style, title: swipeAction.title) { _, _, completion in
                handler(swipeAction, completion)
            }

            action.image = UIImage(systemName: swipeAction.systemImage)
            action.backgroundColor = UIColor(swipeAction.tint)
            return action
        }

        let configuration = UISwipeActionsConfiguration(actions: contextualActions)
        configuration.performsFirstActionWithFullSwipe = resolvedActions.first?.role == .destructive
        return configuration
    }

    private static func trailingActionsOrderedForFullSwipe(
        _ actions: [SimpleGymRowSwipeAction]
    ) -> [SimpleGymRowSwipeAction] {
        let destructiveActions = actions.filter { $0.role == .destructive }
        let regularActions = actions.filter { $0.role != .destructive }

        return destructiveActions + regularActions
    }
}

extension UITableViewCell {
    func simpleGymSwipeRevealProgress(maximumRevealWidth: CGFloat) -> CGFloat {
        let presentationFrame = contentView.layer.presentation()?.frame ?? contentView.frame
        let frameRevealWidth = max(
            0,
            -presentationFrame.minX,
            bounds.width - presentationFrame.maxX
        )
        let transformRevealWidth = max(0, -contentView.transform.tx)
        let revealWidth = max(frameRevealWidth, transformRevealWidth)

        guard maximumRevealWidth > 0 else { return 0 }
        return max(0, min(1, revealWidth / maximumRevealWidth))
    }

    func applySimpleGymSwipeBackground(progress: CGFloat, cornerRadius: CGFloat) {
        let resolvedProgress = max(0, min(1, progress))

        contentView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(resolvedProgress)
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = resolvedProgress > 0
    }
}
