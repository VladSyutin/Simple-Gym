import SwiftUI

private enum AddWorkoutSheetTab: String, CaseIterable, Identifiable {
    case exercises
    case programs

    var id: String { rawValue }

    var title: String {
        switch self {
        case .exercises:
            return "Упражнения"
        case .programs:
            return "Программы"
        }
    }
}

private struct AddWorkoutExerciseCategory: Identifiable {
    let title: String
    let imageName: String

    var id: String { title }
}

struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: AddWorkoutSheetTab = .exercises

    private let exerciseCategories: [AddWorkoutExerciseCategory] = [
        AddWorkoutExerciseCategory(title: "Грудь", imageName: "WorkoutIllustrationBreast"),
        AddWorkoutExerciseCategory(title: "Кардио", imageName: "WorkoutIllustrationCardio"),
        AddWorkoutExerciseCategory(title: "Ноги", imageName: "WorkoutIllustrationLegs"),
        AddWorkoutExerciseCategory(title: "Плечи", imageName: "WorkoutIllustrationShoulders"),
        AddWorkoutExerciseCategory(title: "Пресс", imageName: "WorkoutIllustrationPress"),
        AddWorkoutExerciseCategory(title: "Растяжка", imageName: "WorkoutIllustrationStretching"),
        AddWorkoutExerciseCategory(title: "Руки", imageName: "WorkoutIllustrationArms"),
        AddWorkoutExerciseCategory(title: "Спина", imageName: "WorkoutIllustrationBack"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            grabber
            toolbar
            segmentedControl

            Group {
                switch selectedTab {
                case .exercises:
                    exerciseList
                case .programs:
                    programsEmptyState
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorTokens.backgroundPrimary)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if selectedTab == .programs {
                VStack(spacing: 0) {
                    LiquidGlassButton(
                        title: "Создать программу",
                        systemImage: "plus",
                        variant: .tinted
                    ) {}
                    .padding(.horizontal, Spacing.xLarge)
                    .padding(.top, Spacing.large)
                    .padding(.bottom, Spacing.xxSmall)
                }
                .background {
                    LinearGradient(
                        colors: [
                            ColorTokens.backgroundPrimary.opacity(0),
                            ColorTokens.backgroundPrimary.opacity(0.92),
                            ColorTokens.backgroundPrimary,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
    }

    private var grabber: some View {
        Capsule()
            .fill(ColorTokens.labelTertiary.opacity(0.55))
            .frame(width: 36, height: 5)
            .padding(.top, Spacing.xxSmall)
            .padding(.bottom, 3)
            .accessibilityHidden(true)
    }

    private var toolbar: some View {
        ZStack {
            Text("Добавление тренировки")
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
    }

    private var segmentedControl: some View {
        Picker("Тип добавления", selection: $selectedTab) {
            ForEach(AddWorkoutSheetTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Spacing.small)
        .padding(.bottom, Spacing.small)
    }

    private var exerciseList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(exerciseCategories) { category in
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

    private var programsEmptyState: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            EmptyStateView(
                iconSystemName: "dumbbell.fill",
                title: "Нет программ",
                message: "Создайте первую программу."
            )

            Spacer(minLength: 0)
        }
        .padding(.bottom, 108)
    }
}

#Preview("Exercises") {
    AddWorkoutSheet()
        .presentationDetents([.large])
}
