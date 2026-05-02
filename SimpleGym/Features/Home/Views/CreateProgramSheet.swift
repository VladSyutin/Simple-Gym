import SwiftUI

struct ProgramEditorContent: View {
    let titleText: String
    let leadingSystemImage: String
    let leadingAccessibilityLabel: LocalizedStringKey
    let onLeadingTap: () -> Void
    let onSave: ([HomeWorkoutExercise], String) -> Void

    @State private var programTitle: String
    @State private var exercises: [HomeWorkoutExercise]
    @State private var isExerciseSheetPresented = false
    @FocusState private var isNameFieldFocused: Bool

    init(
        titleText: String = "Создание программы",
        initialTitle: String = "",
        initialExercises: [HomeWorkoutExercise] = [],
        leadingSystemImage: String,
        leadingAccessibilityLabel: LocalizedStringKey,
        onLeadingTap: @escaping () -> Void,
        onSave: @escaping ([HomeWorkoutExercise], String) -> Void
    ) {
        self.titleText = titleText
        self.leadingSystemImage = leadingSystemImage
        self.leadingAccessibilityLabel = leadingAccessibilityLabel
        self.onLeadingTap = onLeadingTap
        self.onSave = onSave
        _programTitle = State(initialValue: initialTitle)
        _exercises = State(initialValue: initialExercises)
    }

    private var trimmedTitle: String {
        programTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedTitle.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorTokens.backgroundPrimary)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            addExerciseBottomBar
        }
        .sheet(isPresented: $isExerciseSheetPresented) {
            AddExerciseSheet(
                initialExercises: exercises,
                onSave: { updatedExercises in
                    exercises = updatedExercises
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(38)
            .presentationBackground(ColorTokens.backgroundPrimary)
        }
        .task {
            isNameFieldFocused = true
        }
    }

    private var toolbar: some View {
        ZStack {
            Text(titleText)
                .simpleGymTextStyle(.bodyEmphasized)
                .frame(maxWidth: .infinity)

            HStack {
                LiquidGlassSymbolButton(
                    systemImage: leadingSystemImage,
                    accessibilityLabel: leadingAccessibilityLabel
                ) {
                    onLeadingTap()
                }

                Spacer()

                if canSave {
                    LiquidGlassSymbolButton(
                        systemImage: "checkmark",
                        accessibilityLabel: "Сохранить программу",
                        variant: .tinted
                    ) {
                        onSave(exercises, trimmedTitle)
                    }
                } else {
                    Color.clear
                        .frame(width: 48, height: 48)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.horizontal, Spacing.small)
        .frame(height: 54)
        .padding(.bottom, Spacing.xxSmall)
    }

    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.medium) {
                titleField

                if !exercises.isEmpty {
                    WorkoutExerciseList(
                        exercises: exercises,
                        swipeActions: makeDefaultWorkoutExerciseSwipeActions(),
                        onSelect: { _ in }
                    )
                    .frame(height: WorkoutExerciseList.height(for: exercises))
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.bottom, 108)
        }
        .scrollIndicators(.hidden)
    }

    private var titleField: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ColorTokens.separatorVibrant)
                .frame(height: 1)

            HStack(spacing: 0) {
                TextField("", text: $programTitle)
                    .textFieldStyle(.plain)
                    .simpleGymTextStyle(.bodyMedium)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done)
                    .accessibilityLabel("Название программы")
                    .overlay(alignment: .leading) {
                        if programTitle.isEmpty {
                            Text("Название программы")
                                .simpleGymTextStyle(.bodyMedium, color: ColorTokens.labelTertiary)
                                .allowsHitTesting(false)
                        }
                    }

                if !programTitle.isEmpty {
                    Button {
                        programTitle = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(ColorTokens.labelTertiary)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Очистить название программы")
                }
            }
            .frame(minHeight: 51)
            .padding(.horizontal, Spacing.small)
        }
    }

    private var addExerciseBottomBar: some View {
        VStack(spacing: 0) {
            LiquidGlassButton(
                title: "Добавить упражнение",
                systemImage: "plus",
                variant: exercises.isEmpty ? .tinted : .clear
            ) {
                isExerciseSheetPresented = true
            }
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

struct CreateProgramSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([HomeWorkoutExercise], String) -> Void
    let initialTitle: String
    let initialExercises: [HomeWorkoutExercise]

    init(
        initialTitle: String = "",
        initialExercises: [HomeWorkoutExercise] = [],
        onSave: @escaping ([HomeWorkoutExercise], String) -> Void = { _, _ in }
    ) {
        self.initialTitle = initialTitle
        self.initialExercises = initialExercises
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            ProgramEditorContent(
                initialTitle: initialTitle,
                initialExercises: initialExercises,
                leadingSystemImage: "xmark",
                leadingAccessibilityLabel: "Закрыть",
                onLeadingTap: {
                    dismiss()
                },
                onSave: { exercises, title in
                    onSave(exercises, title)
                    dismiss()
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorTokens.backgroundPrimary)
    }

    private var grabber: some View {
        Capsule()
            .fill(ColorTokens.labelTertiary.opacity(0.55))
            .frame(width: 36, height: 5)
            .padding(.top, Spacing.xxSmall)
            .padding(.bottom, 3)
            .accessibilityHidden(true)
    }
}

#Preview {
    CreateProgramSheet()
        .presentationDetents([.large])
}
