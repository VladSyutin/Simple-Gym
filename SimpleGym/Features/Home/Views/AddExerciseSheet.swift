import SwiftUI

struct AddExerciseSheet: View {
    let initialExercises: [HomeWorkoutExercise]

    init(initialExercises: [HomeWorkoutExercise] = []) {
        self.initialExercises = initialExercises
    }

    var body: some View {
        ExercisePickerContent(
            sheetTitle: "Добавление упражнения",
            initialExercises: initialExercises
        )
    }
}

#Preview {
    AddExerciseSheet(
        initialExercises: [
            HomeWorkoutExercise(title: "Жим гантелей лёжа на наклонной скамье", imageName: "WorkoutIllustrationBreast"),
            HomeWorkoutExercise(title: "Беговая дорожка", imageName: "WorkoutIllustrationCardio"),
            HomeWorkoutExercise(title: "Приседания со штангой", imageName: "WorkoutIllustrationLegs"),
            HomeWorkoutExercise(title: "Разведение гантелей в стороны", imageName: "WorkoutIllustrationShoulders"),
            HomeWorkoutExercise(title: "Подъём ног к груди в висе", imageName: "WorkoutIllustrationPress"),
            HomeWorkoutExercise(title: "Подъём гантелей на бицепс", imageName: "WorkoutIllustrationArms"),
            HomeWorkoutExercise(title: "Вертикальная тяга блока широким хватом к груди", imageName: "WorkoutIllustrationBack"),
        ]
    )
        .presentationDetents([.large])
}
