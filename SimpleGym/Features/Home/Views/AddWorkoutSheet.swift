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

private enum ProgramNavigationDirection {
    case forward
    case backward
}

private struct WorkoutProgramDraft: Identifiable {
    let id: UUID
    let title: String
    let exercises: [HomeWorkoutExercise]

    init(id: UUID = UUID(), title: String, exercises: [HomeWorkoutExercise]) {
        self.id = id
        self.title = title
        self.exercises = exercises
    }
}

struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: AddWorkoutSheetTab = .exercises
    @State private var showsExerciseTabSwitcher = true
    @State private var isCreateProgramSheetPresented = false
    @State private var editingProgram: WorkoutProgramDraft?
    @State private var createdPrograms: [WorkoutProgramDraft] = []
    @State private var programsNavigationDirection: ProgramNavigationDirection = .forward

    private enum Metrics {
        static let externalSegmentedTopInset: CGFloat = 78
        static let externalSegmentedReservedHeight: CGFloat = 44
    }

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch selectedTab {
                case .exercises:
                    ExercisePickerContent(
                        sheetTitle: "Добавление тренировки",
                        showsTopAccessory: $showsExerciseTabSwitcher,
                        reservedTopAccessoryHeight: Metrics.externalSegmentedReservedHeight
                    )
                case .programs:
                    VStack(spacing: 0) {
                        grabber
                        ZStack {
                            if let editingProgram {
                                programEditor(for: editingProgram)
                                    .transition(programsPaneTransition)
                            } else {
                                VStack(spacing: 0) {
                                    toolbar
                                    Color.clear
                                        .frame(height: Metrics.externalSegmentedReservedHeight)
                                        .accessibilityHidden(true)
                                    programsContent
                                }
                                .transition(programsPaneTransition)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
            }

            if shouldShowSegmentedControl {
                segmentedControl
                    .padding(.top, Metrics.externalSegmentedTopInset)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorTokens.backgroundPrimary)
        .animation(.easeInOut(duration: 0.28), value: shouldShowSegmentedControl)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if selectedTab == .programs, editingProgram == nil {
                VStack(spacing: 0) {
                    LiquidGlassButton(
                        title: "Создать программу",
                        systemImage: "plus",
                        variant: .tinted
                    ) {
                        isCreateProgramSheetPresented = true
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
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .programs {
                showsExerciseTabSwitcher = true
            }
        }
        .sheet(isPresented: $isCreateProgramSheetPresented) {
            CreateProgramSheet(
                onSave: { exercises, title in
                    createdPrograms.append(
                        WorkoutProgramDraft(
                            title: title,
                            exercises: exercises
                        )
                    )
                }
            )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(38)
                .presentationBackground(ColorTokens.backgroundPrimary)
        }
    }

    private var shouldShowSegmentedControl: Bool {
        if selectedTab == .programs {
            return editingProgram == nil
        }

        return showsExerciseTabSwitcher
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
        .frame(height: 54)
        .padding(.bottom, Spacing.xxSmall)
    }

    private var segmentedControl: some View {
        Picker("Тип добавления", selection: $selectedTab) {
            ForEach(AddWorkoutSheetTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Spacing.small)
        .frame(height: Metrics.externalSegmentedReservedHeight)
    }

    @ViewBuilder
    private var programsContent: some View {
        if createdPrograms.isEmpty {
            programsEmptyState
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(createdPrograms) { program in
                        Button {
                            programsNavigationDirection = .forward
                            withAnimation(.easeInOut(duration: 0.28)) {
                                editingProgram = program
                            }
                        } label: {
                            SimpleGymRow(
                                title: program.title,
                                imageName: nil,
                                showsDisclosureIndicator: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 108)
            }
            .scrollIndicators(.hidden)
        }
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

    private var programsPaneTransition: AnyTransition {
        switch programsNavigationDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        }
    }

    private func programEditor(for program: WorkoutProgramDraft) -> some View {
        ProgramEditorContent(
            initialTitle: program.title,
            initialExercises: program.exercises,
            leadingSystemImage: "arrow.left",
            leadingAccessibilityLabel: "Назад",
            onLeadingTap: {
                programsNavigationDirection = .backward
                withAnimation(.easeInOut(duration: 0.28)) {
                    editingProgram = nil
                }
            },
            onSave: { exercises, title in
                guard let index = createdPrograms.firstIndex(where: { $0.id == program.id }) else { return }
                createdPrograms[index] = WorkoutProgramDraft(
                    id: program.id,
                    title: title,
                    exercises: exercises
                )
                programsNavigationDirection = .backward
                withAnimation(.easeInOut(duration: 0.28)) {
                    editingProgram = nil
                }
            }
        )
    }

}

#Preview("Exercises") {
    AddWorkoutSheet()
        .presentationDetents([.large])
}
