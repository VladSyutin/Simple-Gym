import SwiftUI
import UIKit

private let simpleGymCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "ru_RU")
    calendar.firstWeekday = 2
    return calendar
}()

private func performWithoutAnimation(_ updates: () -> Void) {
    var transaction = Transaction(animation: nil)
    transaction.disablesAnimations = true
    withTransaction(transaction) {
        updates()
    }
}

private let calendarTransitionAnimation = Animation.spring(response: 0.32, dampingFraction: 0.9)
private let calendarLayoutTransitionAnimation = Animation.timingCurve(0.2, 0.88, 0.24, 1, duration: 0.42)
private let calendarRowCountAnimation = Animation.timingCurve(0.2, 0.88, 0.24, 1, duration: 0.36)
private let calendarTransitionSettleDuration: TimeInterval = 0.46

private enum HomeSheetDestination: Identifiable {
    case addWorkout
    case addExercise

    var id: String {
        switch self {
        case .addWorkout:
            return "addWorkout"
        case .addExercise:
            return "addExercise"
        }
    }
}

private struct CreateProgramContext: Identifiable {
    let title: String
    let exercises: [HomeWorkoutExercise]

    var id: String {
        [
            title,
            exercises.map(\.id.uuidString).joined(separator: "|")
        ].joined(separator: "::")
    }
}

private struct WorkoutExecutionRoute: Identifiable, Hashable {
    let date: Date
    let exerciseID: UUID

    var id: String {
        "\(date.timeIntervalSince1970)-\(exerciseID.uuidString)"
    }
}

private struct ExerciseReplacementContext: Identifiable {
    let date: Date
    let exercise: HomeWorkoutExercise

    var id: String {
        "\(date.timeIntervalSince1970)-\(exercise.id.uuidString)"
    }
}

struct HomeScreen: View {
    @State private var isCalendarExpanded = false
    @State private var userSelectedDate: Date?
    @State private var visibleMonthPageID: Date? = simpleGymCalendar.startOfMonth(for: Date())
    @State private var visibleWeekPageID: Date? = simpleGymCalendar.startOfWeek(for: Date())
    @State private var transitionDisplayedMonthStart: Date?
    @State private var displayedMonthReleaseWorkItem: DispatchWorkItem?
    @State private var activeSheet: HomeSheetDestination?
    @State private var createProgramContext: CreateProgramContext?
    @State private var workoutComment = ""
    @State private var workoutSessionsByDate = HomeScreen.makeWorkoutSessions()
    @State private var workoutPrograms: [WorkoutProgramDraft] = []
    @State private var workoutExecutionRoute: WorkoutExecutionRoute?
    @State private var exerciseReplacementContext: ExerciseReplacementContext?
    @FocusState private var isCommentFieldFocused: Bool

    private var trainingDates: Set<Date> {
        Set(workoutSessionsByDate.keys)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            screenContent(currentDate: simpleGymCalendar.startOfDay(for: context.date))
        }
    }

    @ViewBuilder
    private func screenContent(currentDate: Date) -> some View {
        let selectedDate = selectedDate(for: currentDate)
        let selectedWorkout = workoutSession(for: selectedDate)
        let displayedMonthStart = transitionDisplayedMonthStart ?? resolvedDisplayedMonthStart(for: selectedDate)
        let isCalendarTransitioning = transitionDisplayedMonthStart != nil
        let calendarHeight = HomeCalendar.height(
            isExpanded: isCalendarExpanded,
            displayedMonthStart: displayedMonthStart,
            showsSectionHeader: selectedWorkout != nil
        )

        ZStack(alignment: .top) {
            if let selectedWorkout {
                workoutContent(
                    for: selectedWorkout,
                    selectedDate: selectedDate,
                    topContentInset: calendarHeight
                )
            } else {
                VStack(spacing: 0) {
                    Spacer(minLength: Spacing.xxLarge)

                    EmptyStateView(
                        iconSystemName: "dumbbell.fill",
                        title: "Нет тренировок",
                        message: "Добавьте упражнение или программу."
                    )
                    .padding(.horizontal, Spacing.large)

                    Spacer()
                }
                .padding(.top, calendarHeight)
            }

            HomeCalendar(
                visibleMonthPageID: $visibleMonthPageID,
                visibleWeekPageID: $visibleWeekPageID,
                currentDate: currentDate,
                selectedDate: selectedDate,
                displayedMonthStart: displayedMonthStart,
                isTransitioning: isCalendarTransitioning,
                isExpanded: isCalendarExpanded,
                sectionTitle: selectedWorkout?.title,
                sectionKind: selectedWorkout?.kind,
                trainingDates: trainingDates,
                onMonthTap: {
                    toggleCalendar(selectedDate: selectedDate)
                },
                onTodayTap: {
                    jumpToToday(currentDate: currentDate)
                },
                onDateTap: { date in
                    setSelectedDate(date, currentDate: currentDate)
                },
                onCopyToToday: {
                    copyWorkoutToToday(from: selectedDate, currentDate: currentDate)
                },
                onSaveAsProgram: {
                    saveWorkoutAsProgram(selectedWorkout)
                },
                onDeleteWorkout: {
                    deleteWorkout(for: selectedDate)
                }
            )
            .onChange(of: visibleMonthPageID) { _, newValue in
                guard let newValue else { return }
                syncSelectionForVisibleMonth(newValue, currentDate: currentDate)
            }
            .onChange(of: visibleWeekPageID) { _, newValue in
                guard let newValue else { return }
                syncSelectionForVisibleWeek(newValue, currentDate: currentDate)
            }
        }
        .animation(calendarLayoutTransitionAnimation, value: isCalendarExpanded)
        .background(ColorTokens.backgroundPrimary.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                LiquidGlassButton(
                    title: selectedWorkout == nil ? "Добавить тренировку" : "Добавить упражнение",
                    systemImage: "plus",
                    variant: selectedWorkout == nil ? .tinted : .clear
                ) {
                    activeSheet = selectedWorkout == nil ? .addWorkout : .addExercise
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
        .sheet(item: $activeSheet) { destination in
            switch destination {
            case .addWorkout:
                AddWorkoutSheet(
                    programs: $workoutPrograms,
                    onAddWorkout: { workout in
                        addWorkoutSession(workout, for: selectedDate)
                    }
                )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(38)
                    .presentationBackground(ColorTokens.backgroundPrimary)
            case .addExercise:
                AddExerciseSheet(
                    initialExercises: selectedWorkout?.exercises ?? [],
                    onSave: { exercises in
                        updateExercises(exercises, preservingExistingState: true, for: selectedDate)
                    }
                )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(38)
                    .presentationBackground(ColorTokens.backgroundPrimary)
            }
        }
        .sheet(item: $createProgramContext) { context in
            CreateProgramSheet(
                initialTitle: context.title == "Произвольная тренировка" ? "" : context.title,
                initialExercises: context.exercises,
                onSave: { exercises, title in
                    workoutPrograms.append(
                        WorkoutProgramDraft(
                            title: title,
                            exercises: exercises
                        )
                    )
                    convertWorkoutToProgram(
                        title: title,
                        exercises: exercises,
                        for: selectedDate
                    )
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(38)
            .presentationBackground(ColorTokens.backgroundPrimary)
        }
        .sheet(item: $exerciseReplacementContext) { context in
            ReplaceExerciseSheet(exercise: context.exercise) { updatedTitle in
                replaceExerciseTitle(
                    exerciseID: context.exercise.id,
                    with: updatedTitle,
                    forWorkoutOn: context.date
                )
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(38)
            .presentationBackground(ColorTokens.backgroundPrimary)
        }
        .navigationDestination(item: $workoutExecutionRoute) { route in
            if let workout = workoutSession(for: route.date) {
                WorkoutExecutionScreen(
                    workoutTitle: workout.title,
                    initialExercises: workout.exercises,
                    initialExerciseID: route.exerciseID,
                    onExercisesChange: { updatedExercises in
                        updateExercises(updatedExercises, for: route.date)
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func workoutContent(
        for workout: HomeWorkoutSession,
        selectedDate: Date,
        topContentInset: CGFloat
    ) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                WorkoutExerciseList(
                    exercises: workout.exercises,
                    swipeActionsProvider: { exercise in
                        workoutExerciseSwipeActions(for: exercise, selectedDate: selectedDate)
                    },
                    onSelect: { exercise in
                        openExercise(exercise, forWorkoutOn: selectedDate)
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: WorkoutExerciseList.height(for: workout.exercises))

                SimpleGymTextField(
                    prompt: "Комментарий",
                    text: $workoutComment,
                    isFocused: $isCommentFieldFocused
                )
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.top, topContentInset)
            .padding(.bottom, Spacing.xxxLarge)
        }
        .scrollIndicators(.hidden)
        .scrollEdgeEffectStyle(.hard, for: .top)
        .contentShape(Rectangle())
        .onTapGesture {
            isCommentFieldFocused = false
        }
    }

    private func selectedDate(for currentDate: Date) -> Date {
        simpleGymCalendar.startOfDay(for: userSelectedDate ?? currentDate)
    }

    private func workoutSession(for date: Date) -> HomeWorkoutSession? {
        workoutSessionsByDate[simpleGymCalendar.startOfDay(for: date)]
    }

    private func resolvedDisplayedMonthStart(for selectedDate: Date) -> Date {
        if isCalendarExpanded {
            return visibleMonthPageID ?? simpleGymCalendar.startOfMonth(for: selectedDate)
        }

        return simpleGymCalendar.startOfMonth(for: selectedDate)
    }

    private func toggleCalendar(selectedDate: Date) {
        let targetMonthStart = simpleGymCalendar.startOfMonth(for: selectedDate)
        let targetWeekStart = simpleGymCalendar.startOfWeek(for: selectedDate)

        displayedMonthReleaseWorkItem?.cancel()
        displayedMonthReleaseWorkItem = nil

        transitionDisplayedMonthStart = targetMonthStart
        visibleMonthPageID = targetMonthStart
        visibleWeekPageID = targetWeekStart

        isCalendarExpanded.toggle()

        let workItem = DispatchWorkItem {
            transitionDisplayedMonthStart = nil
            displayedMonthReleaseWorkItem = nil
        }

        displayedMonthReleaseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + calendarTransitionSettleDuration, execute: workItem)
    }

    private func setSelectedDate(_ date: Date, currentDate: Date) {
        let normalizedDate = simpleGymCalendar.startOfDay(for: date)

        displayedMonthReleaseWorkItem?.cancel()
        displayedMonthReleaseWorkItem = nil
        transitionDisplayedMonthStart = nil

        performWithoutAnimation {
            userSelectedDate = simpleGymCalendar.isDate(normalizedDate, inSameDayAs: currentDate) ? nil : normalizedDate
            visibleMonthPageID = simpleGymCalendar.startOfMonth(for: normalizedDate)
            visibleWeekPageID = simpleGymCalendar.startOfWeek(for: normalizedDate)
        }
    }

    private func updateExercises(
        _ exercises: [HomeWorkoutExercise],
        preservingExistingState: Bool = false,
        for date: Date
    ) {
        let normalizedDate = simpleGymCalendar.startOfDay(for: date)
        guard let existingWorkout = workoutSessionsByDate[normalizedDate] else { return }
        let resolvedExercises = preservingExistingState
            ? ExerciseCatalog.mergeExercises(
                exercises,
                preservingExistingStateFrom: existingWorkout.exercises
            )
            : exercises

        guard !resolvedExercises.isEmpty else {
            workoutSessionsByDate.removeValue(forKey: normalizedDate)
            return
        }

        workoutSessionsByDate[normalizedDate] = HomeWorkoutSession(
            title: existingWorkout.title,
            kind: existingWorkout.kind,
            exercises: resolvedExercises
        )
    }

    private func openExercise(_ exercise: HomeWorkoutExercise, forWorkoutOn date: Date) {
        workoutExecutionRoute = WorkoutExecutionRoute(
            date: simpleGymCalendar.startOfDay(for: date),
            exerciseID: exercise.id
        )
    }

    private func workoutExerciseSwipeActions(
        for exercise: HomeWorkoutExercise,
        selectedDate: Date
    ) -> [SimpleGymRowSwipeAction] {
        [
            SimpleGymRowSwipeAction(
                title: "Статистика",
                systemImage: "chart.xyaxis.line",
                tint: ColorTokens.accentOrange,
                symbolPointSize: 17
            ) {},
            SimpleGymRowSwipeAction(
                title: "Редактировать",
                systemImage: "pencil.line",
                tint: ColorTokens.accentGray,
                symbolPointSize: 18
            ) {
                openExerciseReplacementSheet(for: exercise, on: selectedDate)
            },
            SimpleGymRowSwipeAction(
                title: "Удалить",
                systemImage: "trash",
                tint: ColorTokens.accentRed,
                role: .destructive,
                symbolPointSize: 18
            ) {
                deleteExercise(exercise, fromWorkoutOn: selectedDate)
            }
        ]
    }

    private func deleteExercise(_ exercise: HomeWorkoutExercise, fromWorkoutOn date: Date) {
        let normalizedDate = simpleGymCalendar.startOfDay(for: date)
        guard let workout = workoutSessionsByDate[normalizedDate] else { return }

        let updatedExercises = workout.exercises.filter { $0.id != exercise.id }
        guard !updatedExercises.isEmpty else {
            workoutSessionsByDate.removeValue(forKey: normalizedDate)
            return
        }

        workoutSessionsByDate[normalizedDate] = HomeWorkoutSession(
            title: workout.title,
            kind: workout.kind,
            exercises: updatedExercises
        )
    }

    private func openExerciseReplacementSheet(for exercise: HomeWorkoutExercise, on date: Date) {
        exerciseReplacementContext = ExerciseReplacementContext(
            date: simpleGymCalendar.startOfDay(for: date),
            exercise: exercise
        )
    }

    private func replaceExerciseTitle(
        exerciseID: UUID,
        with updatedTitle: String,
        forWorkoutOn date: Date
    ) {
        let normalizedDate = simpleGymCalendar.startOfDay(for: date)
        guard let workout = workoutSessionsByDate[normalizedDate] else { return }

        let updatedExercises = workout.exercises.map { exercise in
            guard exercise.id == exerciseID else { return exercise }

            var updatedExercise = exercise
            updatedExercise.title = updatedTitle
            return updatedExercise
        }

        workoutSessionsByDate[normalizedDate] = HomeWorkoutSession(
            title: workout.title,
            kind: workout.kind,
            exercises: updatedExercises
        )
    }

    private func addWorkoutSession(_ workout: HomeWorkoutSession, for date: Date) {
        let normalizedDate = simpleGymCalendar.startOfDay(for: date)
        workoutSessionsByDate[normalizedDate] = workout
        activeSheet = nil
    }

    private func copyWorkoutToToday(from date: Date, currentDate: Date) {
        let sourceDate = simpleGymCalendar.startOfDay(for: date)
        let today = simpleGymCalendar.startOfDay(for: currentDate)

        guard
            sourceDate != today,
            let workout = workoutSessionsByDate[sourceDate]
        else {
            return
        }

        workoutSessionsByDate[today] = workout
        setSelectedDate(today, currentDate: currentDate)
    }

    private func saveWorkoutAsProgram(_ workout: HomeWorkoutSession?) {
        guard let workout, workout.kind == .freeform else { return }

        createProgramContext = CreateProgramContext(
            title: workout.title,
            exercises: workout.exercises
        )
    }

    private func convertWorkoutToProgram(
        title: String,
        exercises: [HomeWorkoutExercise],
        for date: Date
    ) {
        let normalizedDate = simpleGymCalendar.startOfDay(for: date)
        guard workoutSessionsByDate[normalizedDate] != nil else { return }

        workoutSessionsByDate[normalizedDate] = HomeWorkoutSession(
            title: title,
            kind: .program,
            exercises: exercises
        )
    }

    private func deleteWorkout(for date: Date) {
        let normalizedDate = simpleGymCalendar.startOfDay(for: date)
        workoutSessionsByDate.removeValue(forKey: normalizedDate)
    }

    private func jumpToToday(currentDate: Date) {
        let today = simpleGymCalendar.startOfDay(for: currentDate)
        let todayMonthStart = simpleGymCalendar.startOfMonth(for: today)
        let todayWeekStart = simpleGymCalendar.startOfWeek(for: today)

        displayedMonthReleaseWorkItem?.cancel()
        displayedMonthReleaseWorkItem = nil
        transitionDisplayedMonthStart = nil

        performWithoutAnimation {
            userSelectedDate = nil

            if isCalendarExpanded {
                visibleWeekPageID = todayWeekStart
            } else {
                visibleMonthPageID = todayMonthStart
            }
        }

        withAnimation(calendarTransitionAnimation) {
            if isCalendarExpanded {
                visibleMonthPageID = todayMonthStart
            } else {
                visibleWeekPageID = todayWeekStart
            }
        }
    }

    private func syncSelectionForVisibleMonth(_ monthStart: Date, currentDate: Date) {
        guard isCalendarExpanded else { return }

        let normalizedMonthStart = simpleGymCalendar.startOfMonth(for: monthStart)
        let selectedDate = selectedDate(for: currentDate)

        guard !simpleGymCalendar.isDate(normalizedMonthStart, equalTo: selectedDate, toGranularity: .month) else {
            return
        }

        let updatedSelection = simpleGymCalendar.isDate(normalizedMonthStart, equalTo: currentDate, toGranularity: .month)
            ? currentDate
            : normalizedMonthStart
        setSelectedDate(updatedSelection, currentDate: currentDate)
    }

    private func syncSelectionForVisibleWeek(_ weekStart: Date, currentDate: Date) {
        guard !isCalendarExpanded else { return }

        let normalizedWeekStart = simpleGymCalendar.startOfWeek(for: weekStart)
        let selectedDate = selectedDate(for: currentDate)
        let currentWeekStart = simpleGymCalendar.startOfWeek(for: selectedDate)

        guard !simpleGymCalendar.isDate(normalizedWeekStart, inSameDayAs: currentWeekStart) else {
            return
        }

        let weekdayOffset = simpleGymCalendar.weekdayOffset(of: selectedDate)
        guard let updatedSelection = simpleGymCalendar.date(byAdding: .day, value: weekdayOffset, to: normalizedWeekStart) else {
            return
        }

        setSelectedDate(updatedSelection, currentDate: currentDate)
    }

    private static func makeWorkoutSessions() -> [Date: HomeWorkoutSession] {
        guard let workoutDate = simpleGymCalendar.date(from: DateComponents(year: 2026, month: 4, day: 16)) else {
            return [:]
        }

        return [
            simpleGymCalendar.startOfDay(for: workoutDate): HomeWorkoutSession(
                title: "Произвольная тренировка",
                kind: .freeform,
                exercises: [
                    HomeWorkoutExercise(title: "Приседания со штангой", imageName: "WorkoutIllustrationLegs", kind: .strength),
                    HomeWorkoutExercise(title: "Жим гантелей лёжа на наклонной скамье", imageName: "WorkoutIllustrationBreast", kind: .strength),
                    HomeWorkoutExercise(title: "Вертикальная тяга блока широким хватом к груди", imageName: "WorkoutIllustrationBack", kind: .strength),
                    HomeWorkoutExercise(title: "Подъём гантелей на бицепс", imageName: "WorkoutIllustrationArms", kind: .strength),
                    HomeWorkoutExercise(title: "Разведение гантелей в стороны", imageName: "WorkoutIllustrationShoulders", kind: .strength),
                    HomeWorkoutExercise(title: "Подъём ног к груди в висе", imageName: "WorkoutIllustrationPress", kind: .strength),
                    HomeWorkoutExercise(title: "Беговая дорожка", imageName: "WorkoutIllustrationCardio", kind: .cardio),
                ]
            )
        ]
    }
}

struct WorkoutExerciseList: UIViewRepresentable {
    let exercises: [HomeWorkoutExercise]
    let swipeActionsProvider: (HomeWorkoutExercise) -> [SimpleGymRowSwipeAction]
    let onSelect: (HomeWorkoutExercise) -> Void

    init(
        exercises: [HomeWorkoutExercise],
        swipeActions: [SimpleGymRowSwipeAction],
        onSelect: @escaping (HomeWorkoutExercise) -> Void
    ) {
        self.exercises = exercises
        self.swipeActionsProvider = { _ in swipeActions }
        self.onSelect = onSelect
    }

    init(
        exercises: [HomeWorkoutExercise],
        swipeActionsProvider: @escaping (HomeWorkoutExercise) -> [SimpleGymRowSwipeAction],
        onSelect: @escaping (HomeWorkoutExercise) -> Void
    ) {
        self.exercises = exercises
        self.swipeActionsProvider = swipeActionsProvider
        self.onSelect = onSelect
    }

    static func height(for exercises: [HomeWorkoutExercise]) -> CGFloat {
        CGFloat(exercises.count) * SimpleGymRow.height
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.allowsSelection = false
        tableView.register(WorkoutExerciseCell.self, forCellReuseIdentifier: Coordinator.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = SimpleGymRow.height
        tableView.estimatedRowHeight = SimpleGymRow.height
        tableView.contentInset = .zero
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
        tableView.reloadData()
    }
}

extension WorkoutExerciseList {
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        static let reuseIdentifier = "WorkoutExerciseCell"

        var parent: WorkoutExerciseList

        init(parent: WorkoutExerciseList) {
            self.parent = parent
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            parent.exercises.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Self.reuseIdentifier,
                for: indexPath
            ) as? WorkoutExerciseCell else {
                return UITableViewCell()
            }
            let exercise = parent.exercises[indexPath.row]

            cell.configure(with: exercise) {
                self.parent.onSelect(exercise)
            }
            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            SimpleGymRow.height
        }

        func tableView(
            _ tableView: UITableView,
            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
        ) -> UISwipeActionsConfiguration? {
            let exercise = parent.exercises[indexPath.row]
            let actions = parent.swipeActionsProvider(exercise).map { swipeAction in
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

private final class WorkoutExerciseCell: UITableViewCell {
    private static let maximumSwipeRevealWidth: CGFloat = 180

    private var exercise: HomeWorkoutExercise?
    private var onTap: (() -> Void)?
    private var swipeRevealProgress: CGFloat = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

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

    func configure(with exercise: HomeWorkoutExercise, onTap: @escaping () -> Void) {
        self.exercise = exercise
        self.onTap = onTap
        applyContentConfiguration()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        exercise = nil
        onTap = nil
        swipeRevealProgress = 0
        contentConfiguration = nil
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let revealWidth = max(0, bounds.width - contentView.frame.maxX)
        let progress = max(0, min(1, revealWidth / Self.maximumSwipeRevealWidth))

        guard abs(progress - swipeRevealProgress) > 0.001 else { return }

        swipeRevealProgress = progress
        applyContentConfiguration()
    }

    private func applyContentConfiguration() {
        guard let exercise else { return }

        contentConfiguration = UIHostingConfiguration {
            Button(action: {
                self.onTap?()
            }) {
                SimpleGymRow(
                    title: exercise.title,
                    imageName: exercise.imageName,
                    swipeRevealProgress: swipeRevealProgress
                )
            }
            .buttonStyle(.plain)
        }
        .margins(.all, 0)
    }
}

private struct HomeCalendar: View {
    @Binding var visibleMonthPageID: Date?
    @Binding var visibleWeekPageID: Date?

    @State private var monthScrollPageID: Date?
    @State private var showsWeekPagerOverlay = false

    let currentDate: Date
    let selectedDate: Date
    let displayedMonthStart: Date
    let isTransitioning: Bool
    let isExpanded: Bool
    let sectionTitle: String?
    let sectionKind: HomeWorkoutKind?
    let trainingDates: Set<Date>
    let onMonthTap: () -> Void
    let onTodayTap: () -> Void
    let onDateTap: (Date) -> Void
    let onCopyToToday: () -> Void
    let onSaveAsProgram: () -> Void
    let onDeleteWorkout: () -> Void

    private static let weekdaySymbols = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"]

    private var calendar: Calendar {
        simpleGymCalendar
    }

    private var showsTodayButton: Bool {
        !calendar.isDate(selectedDate, inSameDayAs: currentDate)
    }

    private var canCopyWorkoutToToday: Bool {
        !calendar.isDate(selectedDate, inSameDayAs: currentDate)
    }

    private var monthPageAnchors: [Date] {
        (-18 ... 18).compactMap { monthOffset in
            calendar.date(byAdding: .month, value: monthOffset, to: calendar.startOfMonth(for: currentDate))
        }
    }

    private var weekPageAnchors: [Date] {
        (-78 ... 78).compactMap { weekOffset in
            calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfWeek(for: currentDate))
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        formatter.dateFormat = "LLL yyyy"

        let rawTitle = formatter.string(from: displayedMonthStart)
        guard let firstCharacter = rawTitle.first else {
            return rawTitle
        }

        return firstCharacter.uppercased() + rawTitle.dropFirst()
    }

    private var presentedExpandedWeekCount: Int {
        max(calendar.weeksInMonth(containing: displayedMonthStart), 1)
    }

    private var showsAnimatedMonthPager: Bool {
        isExpanded || !showsWeekPagerOverlay
    }

    private var selectedWeekIndexInDisplayedMonth: Int {
        calendar.weekIndex(of: selectedDate, inMonthContaining: displayedMonthStart)
    }

    static func height(
        isExpanded: Bool,
        displayedMonthStart: Date,
        showsSectionHeader: Bool
    ) -> CGFloat {
        let metrics = CalendarLayoutMetrics(width: 0)
        let weekCount = max(simpleGymCalendar.weeksInMonth(containing: displayedMonthStart), 1)
        let weeksHeight = isExpanded
            ? metrics.monthGridHeight(weekCount: weekCount)
            : metrics.weekHeight
        let sectionHeaderHeight = showsSectionHeader ? metrics.sectionHeaderHeight : 0

        return metrics.monthRowHeight + metrics.weekdayRowHeight + weeksHeight + sectionHeaderHeight
    }

    var body: some View {
        GeometryReader { geometry in
            let metrics = CalendarLayoutMetrics(width: geometry.size.width)
            let expandedWeeksHeight = metrics.monthGridHeight(weekCount: presentedExpandedWeekCount)
            let visibleWeeksHeight = isExpanded ? expandedWeeksHeight : metrics.weekHeight

            VStack(spacing: 0) {
                monthBar(metrics: metrics)
                weekdayRow(metrics: metrics)

                ZStack(alignment: .top) {
                    monthPager(metrics: metrics)
                        .frame(height: metrics.monthGridPageHeight, alignment: .top)
                        .offset(y: monthPagerOffset(metrics: metrics))
                        .opacity(isTransitioning ? 0 : (showsAnimatedMonthPager ? 1 : 0))
                        .allowsHitTesting(isExpanded && !isTransitioning)
                        .animation(nil, value: isTransitioning)

                    transitionMonthGrid(metrics: metrics)
                        .opacity(isTransitioning ? 1 : 0)
                        .allowsHitTesting(false)
                        .accessibilityHidden(!isTransitioning)
                        .animation(nil, value: isTransitioning)

                    weekPager(metrics: metrics)
                        .opacity(!isExpanded ? (showsWeekPagerOverlay ? 1 : 0.001) : 0)
                        .allowsHitTesting(!isExpanded)
                        .accessibilityHidden(isExpanded || !showsWeekPagerOverlay)
                }
                .frame(height: visibleWeeksHeight, alignment: .top)
                .clipped()

                if let sectionTitle {
                    HomeSectionHeader(
                        title: sectionTitle,
                        workoutKind: sectionKind ?? .freeform,
                        canCopyToToday: canCopyWorkoutToToday,
                        onCopyToToday: onCopyToToday,
                        onSaveAsProgram: onSaveAsProgram,
                        onDeleteWorkout: onDeleteWorkout
                    )
                }
            }
            .scrollChromeSurface()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: totalHeight)
        .animation(calendarLayoutTransitionAnimation, value: isExpanded)
        .animation(calendarRowCountAnimation, value: presentedExpandedWeekCount)
        .onAppear {
            syncMonthScrollPageIDWithBinding()
        }
        .onChange(of: visibleMonthPageID) { _, _ in
            // Boundary weeks can be rendered by either adjacent month page in collapsed mode.
            // Animating that page swap makes a simple date tap look like an unintended scroll.
            syncMonthScrollPageIDWithBinding(animated: isExpanded)
        }
        .onChange(of: displayedMonthStart) { _, _ in
            guard !isExpanded else { return }
            syncMonthScrollPageIDWithBinding()
        }
        .onChange(of: isExpanded) { _, newValue in
            if newValue {
                performWithoutAnimation {
                    showsWeekPagerOverlay = false
                }
            }
        }
    }

    private var totalHeight: CGFloat {
        Self.height(
            isExpanded: isExpanded,
            displayedMonthStart: displayedMonthStart,
            showsSectionHeader: sectionTitle != nil
        )
    }

    @ViewBuilder
    private func monthBar(metrics: CalendarLayoutMetrics) -> some View {
        HStack(spacing: 0) {
            Button(action: onMonthTap) {
                HStack(spacing: Spacing.xxxSmall) {
                    Text(monthTitle)
                        .simpleGymTextStyle(.bodyEmphasized)

                    Image(systemName: "chevron.right")
                        .font(.system(size: metrics.controlIconSize, weight: .bold))
                        .foregroundStyle(ColorTokens.accentBlue)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            if showsTodayButton {
                Button(action: onTodayTap) {
                    Text("Сегодня")
                        .simpleGymTextStyle(.bodyRegular, color: ColorTokens.accentBlue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, metrics.horizontalInset)
        .frame(height: metrics.monthRowHeight, alignment: .center)
    }

    @ViewBuilder
    private func weekdayRow(metrics: CalendarLayoutMetrics) -> some View {
        HStack(spacing: metrics.daySpacing) {
            ForEach(Self.weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .simpleGymTextStyle(.captionSemibold, color: ColorTokens.labelTertiary)
                    .frame(width: metrics.daySize, alignment: .center)
            }
        }
        .padding(.horizontal, metrics.horizontalInset)
        .frame(height: metrics.weekdayRowHeight, alignment: .center)
    }

    @ViewBuilder
    private func weekPager(metrics: CalendarLayoutMetrics) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(weekPageAnchors, id: \.self) { weekStart in
                    weekRow(
                        days: calendar.daysInWeek(startingAt: weekStart),
                        metrics: metrics
                    )
                        .frame(width: metrics.width)
                        .id(weekStart)
                }
            }
            .scrollTargetLayout()
        }
        .scrollClipDisabled()
        .frame(height: metrics.weekHeight, alignment: .top)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $visibleWeekPageID)
        .disableScrollsToTop()
        .onScrollPhaseChange(handleWeekScrollPhaseChange(_:_:_:))
    }

    @ViewBuilder
    private func monthPager(metrics: CalendarLayoutMetrics) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(monthPageAnchors, id: \.self) { monthStart in
                    monthGrid(monthStart: monthStart, metrics: metrics)
                        .frame(width: metrics.width)
                        .frame(height: metrics.monthGridPageHeight, alignment: .top)
                        .id(monthStart)
                }
            }
            .scrollTargetLayout()
        }
        .scrollClipDisabled()
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $monthScrollPageID)
        .disableScrollsToTop()
        .onScrollPhaseChange(handleMonthScrollPhaseChange(_:_:_:))
    }

    @ViewBuilder
    private func monthGrid(monthStart: Date, metrics: CalendarLayoutMetrics) -> some View {
        VStack(spacing: metrics.weekSpacing) {
            ForEach(Array(calendar.monthWeeks(containing: monthStart).enumerated()), id: \.offset) { _, week in
                monthWeekRow(days: week, monthStart: monthStart, metrics: metrics)
            }
        }
    }

    @ViewBuilder
    private func transitionMonthGrid(metrics: CalendarLayoutMetrics) -> some View {
        let weeks = calendar.monthWeeks(containing: displayedMonthStart)
        let weekCount = max(weeks.count, 1)

        VStack(spacing: 0) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { index, week in
                transitionMonthWeekRow(
                    days: week,
                    monthStart: displayedMonthStart,
                    weekIndex: index,
                    metrics: metrics
                )

                if index < weeks.count - 1 {
                    Color.clear
                        .frame(height: isExpanded ? metrics.weekSpacing : 0)
                }
            }
        }
        .frame(
            height: isExpanded
                ? metrics.monthGridHeight(weekCount: weekCount)
                : metrics.weekHeight,
            alignment: .top
        )
    }

    @ViewBuilder
    private func monthWeekRow(days: [CalendarDay?], monthStart: Date, metrics: CalendarLayoutMetrics) -> some View {
        HStack(spacing: metrics.daySpacing) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                Group {
                    if let day {
                        if isExpanded && !calendar.isDate(day.date, equalTo: monthStart, toGranularity: .month) {
                            Color.clear
                                .accessibilityHidden(true)
                        } else {
                            HomeCalendarDayCell(
                                day: day,
                                style: dayStyle(for: day, referenceMonthStart: monthStart, highlightsOutsideMonth: false),
                                showsTraining: day.containsTraining(in: trainingDates, calendar: calendar),
                                onTap: {
                                    onDateTap(day.date)
                                }
                            )
                        }
                    } else {
                        Color.clear
                            .accessibilityHidden(true)
                    }
                }
                .frame(width: metrics.daySize, height: metrics.weekHeight)
            }
        }
        .padding(.horizontal, metrics.horizontalInset)
        .frame(height: metrics.weekHeight)
    }

    @ViewBuilder
    private func transitionMonthWeekRow(
        days: [CalendarDay?],
        monthStart: Date,
        weekIndex: Int,
        metrics: CalendarLayoutMetrics
    ) -> some View {
        monthWeekRow(days: days, monthStart: monthStart, metrics: metrics)
            .frame(height: metrics.weekHeight)
            .frame(
                height: isExpanded || weekIndex == selectedWeekIndexInDisplayedMonth
                    ? metrics.weekHeight
                    : 0,
                alignment: .top
            )
            .clipped()
            .opacity(isExpanded || weekIndex == selectedWeekIndexInDisplayedMonth ? 1 : 0.001)
            .accessibilityHidden(!(isExpanded || weekIndex == selectedWeekIndexInDisplayedMonth))
    }

    @ViewBuilder
    private func weekRow(days: [CalendarDay], metrics: CalendarLayoutMetrics) -> some View {
        HStack(spacing: metrics.daySpacing) {
            ForEach(days) { day in
                HomeCalendarDayCell(
                    day: day,
                    style: dayStyle(for: day, referenceMonthStart: nil, highlightsOutsideMonth: false),
                    showsTraining: day.containsTraining(in: trainingDates, calendar: calendar),
                    onTap: {
                        onDateTap(day.date)
                    }
                )
                .frame(width: metrics.daySize, height: metrics.weekHeight)
            }
        }
        .padding(.horizontal, metrics.horizontalInset)
        .frame(height: metrics.weekHeight)
    }

    private func dayStyle(
        for day: CalendarDay,
        referenceMonthStart: Date?,
        highlightsOutsideMonth: Bool
    ) -> HomeCalendarDayStyle {
        if calendar.isDate(day.date, inSameDayAs: currentDate) && calendar.isDate(day.date, inSameDayAs: selectedDate) {
            return .todaySelected
        }

        if calendar.isDate(day.date, inSameDayAs: selectedDate) {
            return .selected
        }

        if calendar.isDate(day.date, inSameDayAs: currentDate) {
            return .today
        }

        if
            highlightsOutsideMonth,
            let referenceMonthStart,
            !calendar.isDate(day.date, equalTo: referenceMonthStart, toGranularity: .month)
        {
            return .outsideMonth
        }

        return .current
    }

    private func handleMonthScrollPhaseChange(_ oldPhase: ScrollPhase, _ newPhase: ScrollPhase, _ context: ScrollPhaseChangeContext) {
        guard isExpanded else {
            return
        }

        guard newPhase == .idle else {
            return
        }

        guard let settledMonthPageID = normalizedMonthPageID(monthScrollPageID) else {
            return
        }

        updateSettledMonthPageID(settledMonthPageID, animated: true)
    }

    private func syncMonthScrollPageIDWithBinding(animated: Bool = false) {
        let targetMonthPageID = isExpanded
            ? (normalizedMonthPageID(visibleMonthPageID) ?? displayedMonthStart)
            : displayedMonthStart

        guard monthScrollPageID != targetMonthPageID else {
            return
        }

        if animated {
            withAnimation(calendarTransitionAnimation) {
                monthScrollPageID = targetMonthPageID
            }
        } else {
            monthScrollPageID = targetMonthPageID
        }
    }

    private func normalizedMonthPageID(_ pageID: Date?) -> Date? {
        pageID.map(calendar.startOfMonth(for:))
    }

    private func handleWeekScrollPhaseChange(_ oldPhase: ScrollPhase, _ newPhase: ScrollPhase, _ context: ScrollPhaseChangeContext) {
        guard !isExpanded else {
            performWithoutAnimation {
                showsWeekPagerOverlay = false
            }
            return
        }

        guard oldPhase != newPhase else {
            return
        }

        if newPhase == .idle {
            DispatchQueue.main.async {
                guard !isExpanded else { return }
                performWithoutAnimation {
                    showsWeekPagerOverlay = false
                }
            }
        } else {
            performWithoutAnimation {
                showsWeekPagerOverlay = true
            }
        }
    }

    private func monthPagerOffset(metrics: CalendarLayoutMetrics) -> CGFloat {
        guard !isExpanded else { return 0 }

        return -CGFloat(selectedWeekIndexInDisplayedMonth) * (metrics.weekHeight + metrics.weekSpacing)
    }

    private func updateSettledMonthPageID(_ monthStart: Date, animated: Bool) {
        let normalizedMonthStart = calendar.startOfMonth(for: monthStart)
        guard normalizedMonthPageID(visibleMonthPageID) != normalizedMonthStart else {
            return
        }

        if animated {
            withAnimation(calendarRowCountAnimation) {
                visibleMonthPageID = normalizedMonthStart
            }
        } else {
            visibleMonthPageID = normalizedMonthStart
        }
    }
}

private struct HomeSectionHeader: View {
    let title: String
    let workoutKind: HomeWorkoutKind
    let canCopyToToday: Bool
    let onCopyToToday: () -> Void
    let onSaveAsProgram: () -> Void
    let onDeleteWorkout: () -> Void

    private enum Metrics {
        static let height: CGFloat = 56
    }

    private var destructiveWorkoutIcon: Image {
        let image = UIImage(systemName: "trash")?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        return Image(uiImage: image ?? UIImage())
    }

    var body: some View {
        HStack(spacing: Spacing.small) {
            Text(title)
                .simpleGymTextStyle(.title2Emphasized)
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                if canCopyToToday {
                    Button("Копировать на сегодня", systemImage: "doc.on.doc", action: onCopyToToday)
                }

                if workoutKind == .freeform {
                    Button("Сохранить как программу", systemImage: "bookmark", action: onSaveAsProgram)
                }

                Button(role: .destructive, action: onDeleteWorkout) {
                    HStack(spacing: Spacing.xSmall) {
                        destructiveWorkoutIcon
                        Text("Удалить тренировку")
                            .foregroundStyle(ColorTokens.accentRed)
                        Spacer(minLength: 0)
                    }
                }
            } label: {
                LiquidGlassSymbolLabel(systemImage: "ellipsis")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Дополнительные действия")
        }
        .padding(.horizontal, Spacing.small)
        .frame(height: Metrics.height)
    }
}

private struct HomeCalendarDayCell: View {
    let day: CalendarDay
    let style: HomeCalendarDayStyle
    let showsTraining: Bool
    let onTap: () -> Void

    private enum Metrics {
        static let trainingDotSize: CGFloat = 4
        static let trainingDotBottomInset: CGFloat = 5
    }

    var body: some View {
        Button(action: onTap) {
            Text(day.dayNumberText)
                .simpleGymTextStyle(style.typography, color: style.textColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    if let backgroundColor = style.backgroundColor {
                        Circle()
                            .fill(backgroundColor)
                    }
                }
                .overlay(alignment: .bottom) {
                    if showsTraining {
                        Circle()
                            .fill(style.trainingIndicatorColor)
                            .frame(width: Metrics.trainingDotSize, height: Metrics.trainingDotSize)
                            .padding(.bottom, Metrics.trainingDotBottomInset)
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(day.accessibilityLabel)
        .accessibilityHint(showsTraining ? "Есть тренировка" : "Нет тренировки")
    }
}

private struct CalendarDay: Identifiable, Hashable {
    let date: Date

    var id: Date { date }

    var dayNumberText: String {
        String(simpleGymCalendar.component(.day, from: date))
    }

    var accessibilityLabel: String {
        date.formatted(
            .dateTime
                .locale(Locale(identifier: "ru_RU"))
                .day()
                .month(.wide)
                .year()
        )
    }

    func containsTraining(in trainingDates: Set<Date>, calendar: Calendar) -> Bool {
        trainingDates.contains(where: { trainingDate in
            calendar.isDate(trainingDate, inSameDayAs: date)
        })
    }
}

private enum HomeCalendarDayStyle {
    case current
    case outsideMonth
    case today
    case selected
    case todaySelected

    var typography: Typography {
        switch self {
        case .selected, .todaySelected:
            return .selectedDayNumber
        case .current, .outsideMonth, .today:
            return .dayNumber
        }
    }

    var textColor: Color {
        switch self {
        case .current:
            return ColorTokens.labelPrimary
        case .outsideMonth:
            return ColorTokens.labelTertiary
        case .today, .selected:
            return ColorTokens.accentBlue
        case .todaySelected:
            return ColorTokens.white
        }
    }

    var backgroundColor: Color? {
        switch self {
        case .selected:
            return ColorTokens.accentBlueSelectionBackground
        case .todaySelected:
            return ColorTokens.accentBlue
        case .current, .outsideMonth, .today:
            return nil
        }
    }

    var trainingIndicatorColor: Color {
        switch self {
        case .current:
            return ColorTokens.labelPrimary
        case .outsideMonth:
            return ColorTokens.labelTertiary
        case .today, .selected:
            return ColorTokens.accentBlue
        case .todaySelected:
            return ColorTokens.white
        }
    }
}

private struct CalendarLayoutMetrics {
    static let monthPageWeekCount: Int = 6

    let width: CGFloat

    let horizontalInset: CGFloat = 16
    let daySize: CGFloat = 44
    let controlIconSize: CGFloat = 15
    let monthRowHeight: CGFloat = 40
    let weekdayRowHeight: CGFloat = 20
    let weekHeight: CGFloat = 44
    let weekSpacing: CGFloat = 7
    let sectionHeaderHeight: CGFloat = 56

    var monthGridPageHeight: CGFloat {
        monthGridHeight(weekCount: Self.monthPageWeekCount)
    }

    var daySpacing: CGFloat {
        max((width - (horizontalInset * 2) - (daySize * 7)) / 6, 0)
    }

    func monthGridHeight(weekCount: Int) -> CGFloat {
        let clampedWeekCount = max(weekCount, 1)
        return CGFloat(clampedWeekCount) * weekHeight + CGFloat(clampedWeekCount - 1) * weekSpacing
    }
}

private struct ScrollViewConfigurationView: UIViewRepresentable {
    let configure: (UIScrollView) -> Void

    func makeUIView(context: Context) -> UIView {
        UIView(frame: .zero)
    }

    func updateUIView(_ view: UIView, context: Context) {
        DispatchQueue.main.async {
            let rootView = view.window ?? topmostSuperview(for: view)
            guard let rootView else {
                return
            }

            var configuredScrollViews = Set<ObjectIdentifier>()
            configureScrollViews(in: rootView, configuredScrollViews: &configuredScrollViews)
        }
    }

    private func configureScrollViews(
        in rootView: UIView,
        configuredScrollViews: inout Set<ObjectIdentifier>
    ) {
        if let scrollView = rootView as? UIScrollView {
            let identifier = ObjectIdentifier(scrollView)
            if configuredScrollViews.insert(identifier).inserted {
                configure(scrollView)
            }
        }

        rootView.subviews.forEach { subview in
            configureScrollViews(in: subview, configuredScrollViews: &configuredScrollViews)
        }
    }

    private func topmostSuperview(for view: UIView) -> UIView? {
        var candidate = view.superview
        var topmostSuperview = candidate

        while let superview = candidate?.superview {
            topmostSuperview = superview
            candidate = superview
        }

        return topmostSuperview
    }
}

private extension View {
    func disableScrollsToTop() -> some View {
        background {
            ScrollViewConfigurationView { scrollView in
                scrollView.scrollsToTop = false
            }
            .frame(width: 0, height: 0)
        }
    }
}

private extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        dateInterval(of: .weekOfYear, for: startOfDay(for: date))?.start ?? startOfDay(for: date)
    }

    func startOfMonth(for date: Date) -> Date {
        dateInterval(of: .month, for: startOfDay(for: date))?.start ?? startOfDay(for: date)
    }

    func weekdayOffset(of date: Date) -> Int {
        dateComponents([.day], from: startOfWeek(for: date), to: startOfDay(for: date)).day ?? 0
    }

    func daysInWeek(startingAt weekStart: Date) -> [CalendarDay] {
        (0 ..< 7).compactMap { offset in
            date(byAdding: .day, value: offset, to: weekStart).map { CalendarDay(date: $0) }
        }
    }

    func monthWeeks(containing monthStart: Date) -> [[CalendarDay?]] {
        guard
            let monthInterval = dateInterval(of: .month, for: monthStart),
            let firstWeekInterval = dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let lastWeekDate = date(byAdding: .day, value: -1, to: monthInterval.end),
            let lastWeekInterval = dateInterval(of: .weekOfMonth, for: lastWeekDate)
        else {
            return []
        }

        var days: [CalendarDay?] = []
        var currentDay = firstWeekInterval.start

        while currentDay < lastWeekInterval.end {
            days.append(CalendarDay(date: currentDay))
            guard let nextDay = date(byAdding: .day, value: 1, to: currentDay) else {
                break
            }
            currentDay = nextDay
        }

        return stride(from: 0, to: days.count, by: 7).map { index in
            Array(days[index ..< min(index + 7, days.count)])
        }
    }

    func weeksInMonth(containing monthStart: Date) -> Int {
        monthWeeks(containing: monthStart).count
    }

    func weekIndex(of date: Date, inMonthContaining monthStart: Date) -> Int {
        monthWeeks(containing: monthStart).firstIndex { week in
            week.contains { day in
                guard let day else { return false }
                return isDate(day.date, inSameDayAs: date)
            }
        } ?? 0
    }
}

#Preview {
    HomeScreen()
}
