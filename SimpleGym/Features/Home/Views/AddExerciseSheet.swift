import SwiftUI

private struct AddExerciseCategory: Identifiable {
    let title: String
    let imageName: String

    var id: String { title }
}

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let categories: [AddExerciseCategory] = [
        AddExerciseCategory(title: "Грудь", imageName: "WorkoutIllustrationBreast"),
        AddExerciseCategory(title: "Кардио", imageName: "WorkoutIllustrationCardio"),
        AddExerciseCategory(title: "Ноги", imageName: "WorkoutIllustrationLegs"),
        AddExerciseCategory(title: "Плечи", imageName: "WorkoutIllustrationShoulders"),
        AddExerciseCategory(title: "Пресс", imageName: "WorkoutIllustrationPress"),
        AddExerciseCategory(title: "Растяжка", imageName: "WorkoutIllustrationStretching"),
        AddExerciseCategory(title: "Руки", imageName: "WorkoutIllustrationArms"),
        AddExerciseCategory(title: "Спина", imageName: "WorkoutIllustrationBack"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(ColorTokens.labelTertiary.opacity(0.55))
                .frame(width: 36, height: 5)
                .padding(.top, Spacing.xxSmall)
                .padding(.bottom, 3)
                .accessibilityHidden(true)

            ZStack {
                Text("Добавление упражнения")
                    .simpleGymTextStyle(.bodyEmphasized)
                    .frame(maxWidth: .infinity)

                HStack {
                    LiquidGlassSymbolButton(
                        systemImage: "xmark",
                        accessibilityLabel: "Закрыть"
                    ) {
                        dismiss()
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, Spacing.small)
            .frame(height: 44)
            .padding(.bottom, Spacing.small)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(categories) { category in
                        Button {
                        } label: {
                            SimpleGymRow(
                                title: category.title,
                                imageName: category.imageName
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, Spacing.xxLarge)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorTokens.backgroundPrimary)
    }
}

#Preview {
    AddExerciseSheet()
        .presentationDetents([.large])
}
