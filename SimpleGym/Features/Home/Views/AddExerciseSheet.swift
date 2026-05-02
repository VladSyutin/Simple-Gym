import SwiftUI

struct AddExerciseSheet: View {
    let initialExercises: [HomeWorkoutExercise]
    let onSave: ([HomeWorkoutExercise]) -> Void

    init(
        initialExercises: [HomeWorkoutExercise] = [],
        onSave: @escaping ([HomeWorkoutExercise]) -> Void = { _ in }
    ) {
        self.initialExercises = initialExercises
        self.onSave = onSave
    }

    var body: some View {
        ExercisePickerContent(
            sheetTitle: "Добавление упражнения",
            initialExercises: initialExercises,
            onSave: onSave
        )
    }
}

#Preview {
    AddExerciseSheet(
        initialExercises: [
            HomeWorkoutExercise(title: "Жим гантелей лёжа на наклонной скамье", imageName: "WorkoutIllustrationBreast", kind: .strength),
            HomeWorkoutExercise(title: "Беговая дорожка", imageName: "WorkoutIllustrationCardio", kind: .cardio),
            HomeWorkoutExercise(title: "Приседания со штангой", imageName: "WorkoutIllustrationLegs", kind: .strength),
            HomeWorkoutExercise(title: "Разведение гантелей в стороны", imageName: "WorkoutIllustrationShoulders", kind: .strength),
            HomeWorkoutExercise(title: "Подъём ног к груди в висе", imageName: "WorkoutIllustrationPress", kind: .strength),
            HomeWorkoutExercise(title: "Подъём гантелей на бицепс", imageName: "WorkoutIllustrationArms", kind: .strength),
            HomeWorkoutExercise(title: "Вертикальная тяга блока широким хватом к груди", imageName: "WorkoutIllustrationBack", kind: .strength),
        ]
    )
        .presentationDetents([.large])
}
