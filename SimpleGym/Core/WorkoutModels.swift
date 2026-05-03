import Foundation
import SwiftUI

enum HomeWorkoutKind: Equatable {
    case freeform
    case program
}

enum WorkoutExerciseKind: String, Codable, Hashable {
    case strength
    case cardio

    var primaryMetricTitle: String {
        switch self {
        case .strength:
            return "ВЕС"
        case .cardio:
            return "ВРЕМЯ"
        }
    }

    var secondaryMetricTitle: String {
        switch self {
        case .strength:
            return "ПОВТОРЫ"
        case .cardio:
            return "ДИСТАНЦИЯ"
        }
    }
}

enum WorkoutApproachMetric: Hashable {
    case primary
    case secondary
}

struct WorkoutExecutionField: Hashable {
    let exerciseID: UUID
    let approachID: UUID
    let metric: WorkoutApproachMetric
}

struct WorkoutApproach: Identifiable, Hashable {
    let id: UUID
    var primaryValue: String
    var secondaryValue: String

    init(
        id: UUID = UUID(),
        primaryValue: String = "",
        secondaryValue: String = ""
    ) {
        self.id = id
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
    }

    var isEmpty: Bool {
        primaryValue.isEmpty && secondaryValue.isEmpty
    }

    func resetIdentity() -> WorkoutApproach {
        WorkoutApproach(
            primaryValue: primaryValue,
            secondaryValue: secondaryValue
        )
    }
}

struct HomeWorkoutSession: Equatable {
    let title: String
    let kind: HomeWorkoutKind
    var exercises: [HomeWorkoutExercise]
}

struct HomeWorkoutExercise: Identifiable, Hashable {
    let id: UUID
    var title: String
    let imageName: String
    let kind: WorkoutExerciseKind
    var approaches: [WorkoutApproach]
    var previousApproaches: [WorkoutApproach]

    init(
        id: UUID = UUID(),
        title: String,
        imageName: String,
        kind: WorkoutExerciseKind,
        approaches: [WorkoutApproach]? = nil,
        previousApproaches: [WorkoutApproach]? = nil
    ) {
        self.id = id
        self.title = title
        self.imageName = imageName
        self.kind = kind
        self.approaches = approaches ?? [WorkoutApproach()]
        self.previousApproaches = previousApproaches ?? []
    }

    var showsCopyPreviousButton: Bool {
        approaches.allSatisfy(\.isEmpty) && !previousApproaches.isEmpty
    }

    func replacingIdentity(
        title: String,
        imageName: String,
        kind: WorkoutExerciseKind,
        previousApproaches: [WorkoutApproach]
    ) -> HomeWorkoutExercise {
        HomeWorkoutExercise(
            id: id,
            title: title,
            imageName: imageName,
            kind: kind,
            approaches: [WorkoutApproach()],
            previousApproaches: previousApproaches
        )
    }
}

struct ExercisePickerCategory: Identifiable, Hashable {
    let title: String
    let imageName: String
    let creationKind: WorkoutExerciseKind
    var exercises: [String]

    var id: String { title }
}

enum ExerciseCatalog {
    static func categories(merging initialExercises: [HomeWorkoutExercise]) -> [ExercisePickerCategory] {
        var categories = baseCategories

        for exercise in initialExercises {
            guard
                let categoryTitle = categoryTitle(for: exercise.imageName),
                let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle })
            else {
                continue
            }

            let normalizedTitle = exercise.title.replacingOccurrences(of: "\n", with: " ")
            if !categories[categoryIndex].exercises.contains(normalizedTitle) {
                categories[categoryIndex].exercises.append(normalizedTitle)
            }
        }

        return categories.map { category in
            var category = category
            category.exercises = sortTitles(category.exercises)
            return category
        }
    }

    static func categoryTitle(for imageName: String) -> String? {
        categoryTitleByImageName[imageName]
    }

    static func initialSelections(from exercises: [HomeWorkoutExercise]) -> [String: Set<String>] {
        var selections: [String: Set<String>] = [:]

        for exercise in exercises {
            guard let categoryTitle = categoryTitle(for: exercise.imageName) else { continue }
            let normalizedTitle = exercise.title.replacingOccurrences(of: "\n", with: " ")
            selections[categoryTitle, default: []].insert(normalizedTitle)
        }

        return selections
    }

    static func makeExercise(
        title: String,
        imageName: String,
        kind: WorkoutExerciseKind
    ) -> HomeWorkoutExercise {
        HomeWorkoutExercise(
            title: title,
            imageName: imageName,
            kind: kind
        )
    }
    static func mergeExercises(
        _ exercises: [HomeWorkoutExercise],
        preservingExistingStateFrom existingExercises: [HomeWorkoutExercise]
    ) -> [HomeWorkoutExercise] {
        sortExercises(exercises.map { exercise in
            if let existing = existingExercises.first(where: { $0.title == exercise.title && $0.kind == exercise.kind }) {
                return existing
            }

            return exercise
        })
    }

    static func sortExercises(_ exercises: [HomeWorkoutExercise]) -> [HomeWorkoutExercise] {
        exercises.sorted { lhs, rhs in
            compareTitles(lhs.title, rhs.title) == .orderedAscending
        }
    }

    static func sortTitles(_ titles: [String]) -> [String] {
        titles.sorted { lhs, rhs in
            compareTitles(lhs, rhs) == .orderedAscending
        }
    }

    private static func compareTitles(_ lhs: String, _ rhs: String) -> ComparisonResult {
        lhs.localizedCompare(rhs)
    }

    private static let baseCategories: [ExercisePickerCategory] = [
        ExercisePickerCategory(
            title: "Грудь",
            imageName: "WorkoutIllustrationBreast",
            creationKind: .strength,
            exercises: [
                "Жим гантелей лёжа на наклонной скамье",
                "Жим штанги лёжа",
                "Отжимания",
                "Сведение рук в тренажёре",
            ]
        ),
        ExercisePickerCategory(
            title: "Кардио",
            imageName: "WorkoutIllustrationCardio",
            creationKind: .cardio,
            exercises: [
                "Беговая дорожка",
                "Эллипсоид",
                "Велотренажёр",
            ]
        ),
        ExercisePickerCategory(
            title: "Ноги",
            imageName: "WorkoutIllustrationLegs",
            creationKind: .strength,
            exercises: [
                "Приседания со штангой",
                "Жим ногами",
                "Выпады с гантелями",
            ]
        ),
        ExercisePickerCategory(
            title: "Плечи",
            imageName: "WorkoutIllustrationShoulders",
            creationKind: .strength,
            exercises: [
                "Разведение гантелей в стороны",
                "Жим гантелей сидя",
                "Тяга штанги к подбородку",
            ]
        ),
        ExercisePickerCategory(
            title: "Пресс",
            imageName: "WorkoutIllustrationPress",
            creationKind: .strength,
            exercises: [
                "Подъём ног к груди в висе",
                "Скручивания на полу",
                "Планка",
            ]
        ),
        ExercisePickerCategory(
            title: "Растяжка",
            imageName: "WorkoutIllustrationStretching",
            creationKind: .strength,
            exercises: []
        ),
        ExercisePickerCategory(
            title: "Руки",
            imageName: "WorkoutIllustrationArms",
            creationKind: .strength,
            exercises: [
                "Подъём гантелей на бицепс",
                "Французский жим лёжа",
                "Разгибание рук на блоке",
            ]
        ),
        ExercisePickerCategory(
            title: "Спина",
            imageName: "WorkoutIllustrationBack",
            creationKind: .strength,
            exercises: [
                "Вертикальная тяга блока широким хватом к груди",
                "Тяга штанги в наклоне",
                "Гиперэкстензия",
            ]
        ),
    ]

    private static let categoryTitleByImageName: [String: String] = [
        "WorkoutIllustrationBreast": "Грудь",
        "WorkoutIllustrationCardio": "Кардио",
        "WorkoutIllustrationLegs": "Ноги",
        "WorkoutIllustrationShoulders": "Плечи",
        "WorkoutIllustrationPress": "Пресс",
        "WorkoutIllustrationStretching": "Растяжка",
        "WorkoutIllustrationArms": "Руки",
        "WorkoutIllustrationBack": "Спина",
    ]
}
