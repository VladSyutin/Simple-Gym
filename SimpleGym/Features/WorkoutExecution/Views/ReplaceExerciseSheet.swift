import SwiftUI

struct ReplaceExerciseSheet: View {
    let exercise: HomeWorkoutExercise
    let onReplace: (String) -> Void

    var body: some View {
        CreateExerciseSheet(
            categoryTitle: ExerciseCatalog.categoryTitle(for: exercise.imageName) ?? "",
            creationKind: exercise.kind,
            initialTitle: exercise.title,
            onCreate: onReplace
        )
    }
}

#Preview {
    ReplaceExerciseSheet(
        exercise: HomeWorkoutExercise(
            title: "Жим штанги лёжа",
            imageName: "WorkoutIllustrationBreast",
            kind: .strength
        )
    ) { _ in }
}
