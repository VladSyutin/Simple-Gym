import SwiftUI
import UIKit

struct WorkoutExecutionScreen: View {
    @Environment(\.dismiss) private var dismiss

    let workoutTitle: String
    let initialExercises: [HomeWorkoutExercise]
    let initialExerciseID: UUID
    let onExercisesChange: ([HomeWorkoutExercise]) -> Void

    @State private var exercises: [HomeWorkoutExercise]
    @State private var selectedExerciseID: UUID
    @State private var replacementExercise: HomeWorkoutExercise?
    @FocusState private var focusedField: WorkoutExecutionField?

    private var destructiveExerciseIcon: Image {
        let image = UIImage(systemName: "trash")?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        return Image(uiImage: image ?? UIImage())
    }

    init(
        workoutTitle: String,
        initialExercises: [HomeWorkoutExercise],
        initialExerciseID: UUID,
        onExercisesChange: @escaping ([HomeWorkoutExercise]) -> Void
    ) {
        self.workoutTitle = workoutTitle
        self.initialExercises = initialExercises
        self.initialExerciseID = initialExerciseID
        self.onExercisesChange = onExercisesChange
        _exercises = State(initialValue: initialExercises)
        _selectedExerciseID = State(initialValue: initialExerciseID)
    }

    private var selectedExerciseIndex: Int {
        exercises.firstIndex(where: { $0.id == selectedExerciseID }) ?? 0
    }

    private var selectedExercise: HomeWorkoutExercise? {
        guard exercises.indices.contains(selectedExerciseIndex) else { return nil }
        return exercises[selectedExerciseIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            metricTitles
            pager
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorTokens.backgroundPrimary.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            pageControlInset
        }
        .sheet(item: $replacementExercise) { exercise in
            ReplaceExerciseSheet(exercise: exercise) { updatedTitle in
                replaceSelectedExerciseTitle(with: updatedTitle)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(38)
            .presentationBackground(ColorTokens.backgroundPrimary)
        }
        .onChange(of: exercises) { _, updatedExercises in
            onExercisesChange(updatedExercises)
            normalizeSelectionIfNeeded()
        }
        .onAppear {
            normalizeSelectionIfNeeded()
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            LiquidGlassSymbolButton(
                systemImage: "chevron.left",
                accessibilityLabel: "Назад"
            ) {
                dismiss()
            }

            Spacer(minLength: Spacing.xxSmall)

            VStack(spacing: 1) {
                Text(selectedExercise?.title ?? "")
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.23)
                    .foregroundStyle(ColorTokens.labelPrimary)
                    .lineLimit(1)

                Text(workoutTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ColorTokens.labelSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: 250)

            Spacer(minLength: Spacing.xxSmall)

            Menu {
                Button {
                } label: {
                    Label("Посмотреть статистику", systemImage: "chart.xyaxis.line")
                }

                Button {
                    replacementExercise = selectedExercise
                } label: {
                    Label("Изменить упражнение", systemImage: "pencil.line")
                }

                Button(role: .destructive) {
                    deleteSelectedExercise()
                } label: {
                    HStack(spacing: Spacing.xSmall) {
                        destructiveExerciseIcon
                        Text("Удалить упражнение")
                            .foregroundStyle(ColorTokens.accentRed)
                        Spacer(minLength: 0)
                    }
                }
            } label: {
                LiquidGlassSymbolLabel(systemImage: "ellipsis")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.small)
        .padding(.top, Spacing.xxSmall)
        .padding(.bottom, Spacing.xxSmall)
    }

    private var metricTitles: some View {
        let primaryTitle = selectedExercise?.kind.primaryMetricTitle ?? ""
        let secondaryTitle = selectedExercise?.kind.secondaryMetricTitle ?? ""

        return HStack(spacing: Spacing.xxSmall) {
            Text(primaryTitle)
                .frame(maxWidth: .infinity)

            Text(secondaryTitle)
                .frame(maxWidth: .infinity)
        }
        .font(.system(size: 13, weight: .semibold))
        .tracking(-0.08)
        .foregroundStyle(ColorTokens.labelTertiary)
        .padding(.horizontal, Spacing.xLarge)
        .padding(.top, Spacing.xxSmall)
        .padding(.bottom, Spacing.xxxSmall)
    }

    private var pager: some View {
        TabView(selection: $selectedExerciseID) {
            ForEach($exercises) { $exercise in
                exercisePage(exercise: $exercise)
                    .tag(exercise.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.22), value: exercises)
    }

    private func exercisePage(exercise: Binding<HomeWorkoutExercise>) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.xxSmall) {
                ForEach(Array(exercise.approaches.wrappedValue.enumerated()), id: \.element.id) { index, approach in
                    WorkoutApproachRow(
                        exerciseID: exercise.wrappedValue.id,
                        index: index,
                        metricTitles: (
                            exercise.wrappedValue.kind.primaryMetricTitle,
                            exercise.wrappedValue.kind.secondaryMetricTitle
                        ),
                        approach: Binding(
                            get: {
                                exercise.approaches.wrappedValue[index]
                            },
                            set: { updatedApproach in
                                exercise.approaches.wrappedValue[index] = updatedApproach
                            }
                        ),
                        focus: $focusedField,
                        isDeleteEnabled: exercise.approaches.wrappedValue.count > 1
                    ) {
                        deleteApproach(approachID: approach.id, exerciseID: exercise.wrappedValue.id)
                    }
                }

                actionButton(for: exercise)
                    .padding(.top, Spacing.xxSmall)
                    .padding(.horizontal, Spacing.xLarge)
            }
            .padding(.top, Spacing.xxxSmall)
            .padding(.bottom, 120)
        }
        .onTapGesture {
            focusedField = nil
        }
    }

    private func actionButton(for exercise: Binding<HomeWorkoutExercise>) -> some View {
        let showsCopy = exercise.wrappedValue.showsCopyPreviousButton

        return LiquidGlassButton(
            title: showsCopy ? "Копировать прошлые" : "Добавить подход",
            systemImage: showsCopy ? "doc.on.doc" : "plus",
            variant: .clear
        ) {
            if showsCopy {
                copyPreviousApproaches(for: exercise.wrappedValue.id)
            } else {
                addApproach(to: exercise.wrappedValue.id)
            }
        }
    }

    private var pageControlInset: some View {
        VStack(spacing: 0) {
            if exercises.count > 1 {
                HStack(spacing: Spacing.xxSmall) {
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        Circle()
                            .fill(index == selectedExerciseIndex ? ColorTokens.labelPrimary : ColorTokens.labelTertiary.opacity(0.45))
                            .frame(width: 8, height: 8)
                            .accessibilityHidden(true)
                            .id(exercise.id)
                    }
                }
                .padding(.vertical, Spacing.small)
            }
        }
        .frame(maxWidth: .infinity)
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

    private func addApproach(to exerciseID: UUID) {
        updateExercise(exerciseID) { exercise in
            exercise.approaches.append(WorkoutApproach())
        }
    }

    private func copyPreviousApproaches(for exerciseID: UUID) {
        updateExercise(exerciseID) { exercise in
            exercise.approaches = exercise.previousApproaches.map { $0.resetIdentity() }
        }
    }

    private func deleteApproach(approachID: UUID, exerciseID: UUID) {
        updateExercise(exerciseID) { exercise in
            exercise.approaches.removeAll { $0.id == approachID }
            if exercise.approaches.isEmpty {
                exercise.approaches = [WorkoutApproach()]
            }
        }
    }

    private func replaceSelectedExerciseTitle(with updatedTitle: String) {
        guard let current = selectedExercise else { return }

        updateExercise(current.id) { exercise in
            exercise.title = updatedTitle
        }
    }

    private func deleteSelectedExercise() {
        guard let current = selectedExercise else { return }

        let previousIndex = selectedExerciseIndex
        exercises.removeAll { $0.id == current.id }

        guard !exercises.isEmpty else {
            dismiss()
            return
        }

        let fallbackIndex = min(previousIndex, exercises.count - 1)
        selectedExerciseID = exercises[fallbackIndex].id
    }

    private func updateExercise(_ exerciseID: UUID, transform: (inout HomeWorkoutExercise) -> Void) {
        guard let index = exercises.firstIndex(where: { $0.id == exerciseID }) else { return }
        transform(&exercises[index])
    }

    private func normalizeSelectionIfNeeded() {
        guard !exercises.isEmpty else { return }
        if !exercises.contains(where: { $0.id == selectedExerciseID }) {
            selectedExerciseID = exercises[min(selectedExerciseIndex, exercises.count - 1)].id
        }
    }
}

#Preview("Strength") {
    NavigationStack {
        WorkoutExecutionScreen(
            workoutTitle: "Произвольная тренировка",
            initialExercises: [
                HomeWorkoutExercise(
                    title: "Жим штанги лёжа",
                    imageName: "WorkoutIllustrationBreast",
                    kind: .strength,
                    approaches: [WorkoutApproach()],
                    previousApproaches: [
                        WorkoutApproach(primaryValue: "10", secondaryValue: "10")
                    ]
                ),
                HomeWorkoutExercise(
                    title: "Беговая дорожка",
                    imageName: "WorkoutIllustrationCardio",
                    kind: .cardio
                ),
            ],
            initialExerciseID: UUID()
        ) { _ in }
    }
}
