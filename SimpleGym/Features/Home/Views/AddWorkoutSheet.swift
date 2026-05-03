import SwiftUI
import UIKit

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

struct WorkoutProgramDraft: Identifiable {
    let id: UUID
    let title: String
    let exercises: [HomeWorkoutExercise]

    init(id: UUID = UUID(), title: String, exercises: [HomeWorkoutExercise]) {
        self.id = id
        self.title = title
        self.exercises = ExerciseCatalog.sortExercises(exercises)
    }
}

struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: AddWorkoutSheetTab = .exercises
    @State private var showsExerciseTabSwitcher = true
    @State private var isCreateProgramSheetPresented = false
    @State private var editingProgram: WorkoutProgramDraft?
    @State private var programsNavigationDirection: ProgramNavigationDirection = .forward

    @Binding private var programs: [WorkoutProgramDraft]
    let onAddWorkout: (HomeWorkoutSession) -> Void

    private enum Metrics {
        static let externalSegmentedTopInset: CGFloat = 78
        static let externalSegmentedReservedHeight: CGFloat = 44
    }

    init(
        programs: Binding<[WorkoutProgramDraft]> = .constant([]),
        onAddWorkout: @escaping (HomeWorkoutSession) -> Void = { _ in }
    ) {
        self._programs = programs
        self.onAddWorkout = onAddWorkout
    }

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch selectedTab {
                case .exercises:
                    ExercisePickerContent(
                        sheetTitle: "Добавление тренировки",
                        showsTopAccessory: $showsExerciseTabSwitcher,
                        reservedTopAccessoryHeight: Metrics.externalSegmentedReservedHeight,
                        onSave: addCustomWorkout(_:)
                    )
                case .programs:
                    ZStack(alignment: .top) {
                        if let editingProgram {
                            programEditor(for: editingProgram)
                                .transition(programsPaneTransition)
                        } else {
                            programsPane
                                .transition(programsPaneTransition)
                        }
                    }
                }
            }

            if shouldShowSegmentedControl {
                segmentedControl
                    .padding(.top, Metrics.externalSegmentedTopInset)
                    .transition(segmentedControlTransition)
                    .zIndex(2)
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
                    programs.append(
                        WorkoutProgramDraft(
                            title: title,
                            exercises: exercises
                        )
                    )
                    programs = sortedPrograms(programs)
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

    private var topChrome: some View {
        VStack(spacing: 0) {
            grabber
            toolbar

            if shouldShowSegmentedControl {
                Color.clear
                    .frame(height: Metrics.externalSegmentedReservedHeight)
                    .accessibilityHidden(true)
            }
        }
        .topScrollChromeSurface()
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

    private var segmentedControlTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading),
            removal: .move(edge: .leading)
        )
    }

    @ViewBuilder
    private var programsContent: some View {
        if programs.isEmpty {
            programsEmptyState
        } else {
            ProgramDraftList(
                programs: sortedPrograms(programs),
                topContentInset: programsTopContentInset,
                swipeActionsProvider: programSwipeActions(for:),
                onSelect: addProgramWorkout(_:)
            )
            .padding(.bottom, 108)
        }
    }

    private var programsPane: some View {
        ZStack(alignment: .top) {
            programsContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            topChrome
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var programsTopContentInset: CGFloat {
        Metrics.externalSegmentedTopInset
            + Metrics.externalSegmentedReservedHeight
    }

    private func programSwipeActions(for program: WorkoutProgramDraft) -> [SimpleGymRowSwipeAction] {
        [
            SimpleGymRowSwipeAction(
                title: "Редактировать",
                systemImage: "pencil.line",
                tint: ColorTokens.accentGray,
                symbolPointSize: 18
            ) {
                openProgramEditor(program)
            },
            SimpleGymRowSwipeAction(
                title: "Удалить",
                systemImage: "trash",
                tint: ColorTokens.accentRed,
                role: .destructive,
                symbolPointSize: 18
            ) {
                deleteProgram(program)
            }
        ]
    }

    private func openProgramEditor(_ program: WorkoutProgramDraft) {
        programsNavigationDirection = .forward
        withAnimation(.easeInOut(duration: 0.28)) {
            editingProgram = program
        }
    }

    private func addCustomWorkout(_ exercises: [HomeWorkoutExercise]) {
        guard !exercises.isEmpty else { return }

        onAddWorkout(
            HomeWorkoutSession(
                title: "Произвольная тренировка",
                kind: .freeform,
                exercises: ExerciseCatalog.sortExercises(exercises)
            )
        )
    }

    private func addProgramWorkout(_ program: WorkoutProgramDraft) {
        onAddWorkout(
            HomeWorkoutSession(
                title: program.title,
                kind: .program,
                exercises: ExerciseCatalog.sortExercises(program.exercises)
            )
        )
        dismiss()
    }

    private func deleteProgram(_ program: WorkoutProgramDraft) {
        guard let index = programs.firstIndex(where: { $0.id == program.id }) else { return }

        withAnimation(.easeInOut(duration: 0.22)) {
            _ = programs.remove(at: index)
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
        .padding(.top, programsTopContentInset)
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
                guard let index = programs.firstIndex(where: { $0.id == program.id }) else { return }
                programs[index] = WorkoutProgramDraft(
                    id: program.id,
                    title: title,
                    exercises: exercises
                )
                programs = sortedPrograms(programs)
                programsNavigationDirection = .backward
                withAnimation(.easeInOut(duration: 0.28)) {
                    editingProgram = nil
                }
            }
        )
    }

    private func sortedPrograms(_ programs: [WorkoutProgramDraft]) -> [WorkoutProgramDraft] {
        programs.sorted { lhs, rhs in
            lhs.title.localizedCompare(rhs.title) == .orderedAscending
        }
    }

}

private struct ProgramDraftList: UIViewRepresentable {
    let programs: [WorkoutProgramDraft]
    var topContentInset: CGFloat = 0
    let swipeActionsProvider: (WorkoutProgramDraft) -> [SimpleGymRowSwipeAction]
    let onSelect: (WorkoutProgramDraft) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(ProgramDraftCell.self, forCellReuseIdentifier: Coordinator.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = SimpleGymRow.height
        tableView.estimatedRowHeight = SimpleGymRow.height
        tableView.contentInset = UIEdgeInsets(top: topContentInset, left: 0, bottom: 0, right: 0)
        tableView.layoutMargins = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false

        if #available(iOS 15.0, *) {
            tableView.fillerRowHeight = 0
            tableView.sectionHeaderTopPadding = 0
        }

        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) {
        context.coordinator.parent = self
        tableView.contentInset.top = topContentInset
        tableView.reloadData()
    }
}

extension ProgramDraftList {
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        static let reuseIdentifier = "ProgramDraftCell"

        var parent: ProgramDraftList

        init(parent: ProgramDraftList) {
            self.parent = parent
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            parent.programs.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Self.reuseIdentifier,
                for: indexPath
            ) as? ProgramDraftCell else {
                return UITableViewCell()
            }

            cell.configure(with: parent.programs[indexPath.row])
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            parent.onSelect(parent.programs[indexPath.row])
            tableView.deselectRow(at: indexPath, animated: true)
        }

        func tableView(
            _ tableView: UITableView,
            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
        ) -> UISwipeActionsConfiguration? {
            let program = parent.programs[indexPath.row]
            let actions = parent.swipeActionsProvider(program).map { swipeAction in
                let style: UIContextualAction.Style = swipeAction.role == .destructive ? .destructive : .normal
                let action = UIContextualAction(style: style, title: nil) { _, _, completion in
                    swipeAction.action()
                    completion(true)
                }

                action.backgroundColor = .clear
                action.image = SimpleGymSwipeActionImageRenderer.make(for: swipeAction)
                return action
            }

            let configuration = UISwipeActionsConfiguration(actions: actions)
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
}

private final class ProgramDraftCell: UITableViewCell {
    private var program: WorkoutProgramDraft?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        layoutMargins = .zero
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        backgroundView = nil
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with program: WorkoutProgramDraft) {
        self.program = program
        applyContentConfiguration()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        program = nil
    }

    private func applyContentConfiguration() {
        guard let program else {
            contentConfiguration = nil
            return
        }

        contentConfiguration = UIHostingConfiguration {
            SimpleGymRow(
                title: program.title,
                detail: exerciseCountText,
                imageName: nil,
                showsDisclosureIndicator: false
            )
            .background(Color.clear)
        }
        .margins(.all, 0)
    }

    private var exerciseCountText: String {
        let count = program?.exercises.count ?? 0
        return "\(count)"
    }
}

#Preview("Exercises") {
    AddWorkoutSheet()
        .presentationDetents([.large])
}
