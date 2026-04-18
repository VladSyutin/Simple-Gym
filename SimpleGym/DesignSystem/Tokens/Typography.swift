import SwiftUI

enum Typography {
    case title2Emphasized
    case title3Regular
    case bodyEmphasized
    case captionSemibold
    case dayNumber
    case selectedDayNumber

    var font: Font {
        switch self {
        case .title2Emphasized:
            return .system(size: 22, weight: .bold)
        case .title3Regular:
            return .system(size: 20, weight: .regular)
        case .bodyEmphasized:
            return .system(size: 17, weight: .semibold)
        case .captionSemibold:
            return .system(size: 13, weight: .semibold)
        case .dayNumber:
            return .system(size: 20, weight: .regular)
        case .selectedDayNumber:
            return .system(size: 24, weight: .medium)
        }
    }

    var tracking: CGFloat {
        switch self {
        case .title2Emphasized:
            return -0.26
        case .title3Regular:
            return -0.45
        case .bodyEmphasized:
            return -0.43
        case .captionSemibold:
            return 0
        case .dayNumber:
            return -0.45
        case .selectedDayNumber:
            return 0
        }
    }
}
