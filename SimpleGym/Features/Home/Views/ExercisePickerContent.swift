import SwiftUI
import UIKit

private enum ExercisePickerNavigationDirection {
    case forward
    case backward
}

enum ExercisePickerSelectionMode {
    case multiple
    case single
}

private struct ExercisePickerExercise: Identifiable {
    let title: String

    var id: String { title }
}

private struct ExerciseCreationContext: Identifiable {
    let categoryID: String
    let categoryTitle: String
    let creationKind: WorkoutExerciseKind

    var id: String { categoryID }
}

struct ExercisePickerContent: View {
    @Environment(\.dismiss) private var dismiss

    let sheetTitle: String
    @Binding var showsTopAccessory: Bool
    let reservedTopAccessoryHeight: CGFloat
    let selectionMode: ExercisePickerSelectionMode
    let onSave: ([HomeWorkoutExercise]) -> Void

    @State private var categories: [ExercisePickerCategory]
    @State private var selectedCategoryID: String?
    @State private var selectedExercisesByCategoryID: [String: Set<String>]
    @State private var navigationDirection: ExercisePickerNavigationDirection = .forward
    @State private var creationContext: ExerciseCreationContext?

    init(
        sheetTitle: String,
        initialExercises: [HomeWorkoutExercise] = [],
        initialCategoryID: String? = nil,
        showsTopAccessory: Binding<Bool> = .constant(true),
        reservedTopAccessoryHeight: CGFloat = 0,
        selectionMode: ExercisePickerSelectionMode = .multiple,
        onSave: @escaping ([HomeWorkoutExercise]) -> Void = { _ in }
    ) {
        self.sheetTitle = sheetTitle
        self._showsTopAccessory = showsTopAccessory
        self.reservedTopAccessoryHeight = reservedTopAccessoryHeight
        self.selectionMode = selectionMode
        self.onSave = onSave
        _categories = State(initialValue: ExerciseCatalog.categories(merging: initialExercises))
        _selectedCategoryID = State(initialValue: initialCategoryID)
        _selectedExercisesByCategoryID = State(
            initialValue: ExerciseCatalog.initialSelections(from: initialExercises)
        )
    }

    private var selectedCategory: ExercisePickerCategory? {
        categories.first { $0.id == selectedCategoryID }
    }

    private var hasSelections: Bool {
        selectedExercisesByCategoryID.values.contains { !$0.isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            toolbar

            ZStack {
                if let selectedCategory {
                    detailPane(for: selectedCategory)
                        .transition(paneTransition)
                } else {
                    categoryPane
                        .transition(paneTransition)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorTokens.backgroundPrimary)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let selectedCategory {
                detailBottomBar(for: selectedCategory)
            }
        }
        .sheet(item: $creationContext) { context in
            CreateExerciseSheet(
                categoryTitle: context.categoryTitle,
                creationKind: context.creationKind,
                onCreate: { title in
                    addCreatedExercise(title, toCategoryID: context.categoryID)
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(38)
            .presentationBackground(ColorTokens.backgroundPrimary)
        }
    }

    private var paneTransition: AnyTransition {
        switch navigationDirection {
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
            toolbarTitle

            HStack {
                leadingToolbarButton
                Spacer()
                trailingToolbarButton
            }
        }
        .padding(.horizontal, Spacing.small)
        .frame(height: 54)
        .padding(.bottom, Spacing.xxSmall)
    }

    @ViewBuilder
    private var toolbarTitle: some View {
        if let selectedCategory {
            VStack(spacing: 1) {
                Text(selectedCategory.title)
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.23)
                    .foregroundStyle(ColorTokens.labelPrimary)

                Text(sheetTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ColorTokens.labelSecondary)
            }
            .frame(maxWidth: .infinity)
        } else {
            Text(sheetTitle)
                .simpleGymTextStyle(.bodyEmphasized)
                .frame(maxWidth: .infinity)
        }
    }

    private var leadingToolbarButton: some View {
        Group {
            if let selectedCategory {
                LiquidGlassSymbolButton(
                    systemImage: "arrow.left",
                    accessibilityLabel: "Назад",
                    variant: selectionCount(for: selectedCategory) == 0 ? .clear : .tinted
                ) {
                    navigationDirection = .backward
                    withAnimation(.easeInOut(duration: 0.28)) {
                        showsTopAccessory = true
                        selectedCategoryID = nil
                    }
                }
            } else {
                LiquidGlassSymbolButton(
                    systemImage: "xmark",
                    accessibilityLabel: "Закрыть"
                ) {
                    dismiss()
                }
            }
        }
    }

    private var trailingToolbarButton: some View {
        Group {
            if selectedCategory == nil, hasSelections {
                LiquidGlassSymbolButton(
                    systemImage: "checkmark",
                    accessibilityLabel: "Готово",
                    variant: .tinted
                ) {
                    saveSelections()
                }
            } else {
                Color.clear
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)
            }
        }
    }

    private var categoryPane: some View {
        VStack(spacing: 0) {
            if showsTopAccessory, reservedTopAccessoryHeight > 0 {
                Color.clear
                    .frame(height: reservedTopAccessoryHeight)
                    .accessibilityHidden(true)
            }

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(categories) { category in
                        Button {
                            navigationDirection = .forward
                            withAnimation(.easeInOut(duration: 0.28)) {
                                showsTopAccessory = false
                                selectedCategoryID = category.id
                            }
                        } label: {
                            SimpleGymRow(
                                title: category.title,
                                detail: selectionDetail(for: category),
                                imageName: category.imageName
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, Spacing.xxLarge)
        }
    }

    @ViewBuilder
    private func detailPane(for category: ExercisePickerCategory) -> some View {
        if category.exercises.isEmpty {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                EmptyStateView(
                    iconSystemName: "dumbbell.fill",
                    title: "Нет упражнений",
                    message: "Добавьте первое упражнение."
                )

                Spacer(minLength: 0)
            }
            .padding(.bottom, 108)
        } else {
            ExercisePickerExerciseList(
                exercises: category.exercises.map(ExercisePickerExercise.init(title:)),
                selectedExerciseTitles: selectedExercisesByCategoryID[category.id] ?? [],
                swipeActions: detailSwipeActions,
                onSelect: { selectedTitle in
                    withAnimation(.easeInOut(duration: 0.18)) {
                        switch selectionMode {
                        case .multiple:
                            var selections = selectedExercisesByCategoryID[category.id] ?? []

                            if selections.contains(selectedTitle) {
                                selections.remove(selectedTitle)
                            } else {
                                selections.insert(selectedTitle)
                            }

                            if selections.isEmpty {
                                selectedExercisesByCategoryID.removeValue(forKey: category.id)
                            } else {
                                selectedExercisesByCategoryID[category.id] = selections
                            }
                        case .single:
                            if selectedExercisesByCategoryID[category.id] == [selectedTitle] {
                                selectedExercisesByCategoryID = [:]
                            } else {
                                selectedExercisesByCategoryID = [category.id: [selectedTitle]]
                            }
                        }
                    }
                }
            )
        }
    }

    private func detailBottomBar(for category: ExercisePickerCategory) -> some View {
        VStack(spacing: 0) {
            LiquidGlassButton(
                title: "Создать упражнение",
                systemImage: "plus",
                variant: category.exercises.isEmpty ? .tinted : .clear
            ) {
                creationContext = ExerciseCreationContext(
                    categoryID: category.id,
                    categoryTitle: category.title,
                    creationKind: category.creationKind
                )
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

    private var detailSwipeActions: [SimpleGymRowSwipeAction] {
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
            ) {},
            SimpleGymRowSwipeAction(
                title: "Удалить",
                systemImage: "trash",
                tint: ColorTokens.accentRed,
                role: .destructive,
                symbolPointSize: 18
            ) {}
        ]
    }

    private func selectionCount(for category: ExercisePickerCategory) -> Int {
        selectedExercisesByCategoryID[category.id]?.count ?? 0
    }

    private func selectionDetail(for category: ExercisePickerCategory) -> String? {
        let count = selectionCount(for: category)
        guard count > 0 else { return nil }
        return "Выбрано: \(count)"
    }

    private func saveSelections() {
        onSave(flattenSelectedExercises())
        dismiss()
    }

    private func addCreatedExercise(_ title: String, toCategoryID categoryID: String) {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else { return }

        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) {
            if !categories[categoryIndex].exercises.contains(normalizedTitle) {
                categories[categoryIndex].exercises.append(normalizedTitle)
            }
        }

        var selections = selectedExercisesByCategoryID[categoryID] ?? []
        selections.insert(normalizedTitle)
        selectedExercisesByCategoryID[categoryID] = selections
    }

    private func flattenSelectedExercises() -> [HomeWorkoutExercise] {
        categories.reduce(into: [HomeWorkoutExercise]()) { result, category in
            let selections = selectedExercisesByCategoryID[category.id] ?? []
            guard !selections.isEmpty else { return }

            let orderedTitles = category.exercises.filter(selections.contains)
            let customTitles = selections.subtracting(orderedTitles).sorted()

            let exercises = (orderedTitles + customTitles).map { title in
                ExerciseCatalog.makeExercise(
                    title: title,
                    imageName: category.imageName,
                    kind: category.creationKind
                )
            }

            result.append(contentsOf: exercises)
        }
    }
}

private struct ExercisePickerExerciseList: UIViewRepresentable {
    let exercises: [ExercisePickerExercise]
    let selectedExerciseTitles: Set<String>
    let swipeActions: [SimpleGymRowSwipeAction]
    let onSelect: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(ExercisePickerExerciseCell.self, forCellReuseIdentifier: Coordinator.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
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

extension ExercisePickerExerciseList {
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        static let reuseIdentifier = "ExercisePickerExerciseCell"

        var parent: ExercisePickerExerciseList

        init(parent: ExercisePickerExerciseList) {
            self.parent = parent
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            parent.exercises.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Self.reuseIdentifier,
                for: indexPath
            ) as? ExercisePickerExerciseCell else {
                return UITableViewCell()
            }

            let exercise = parent.exercises[indexPath.row]
            cell.configure(
                with: exercise,
                isSelected: parent.selectedExerciseTitles.contains(exercise.title)
            )
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let exercise = parent.exercises[indexPath.row]
            parent.onSelect(exercise.title)
            tableView.deselectRow(at: indexPath, animated: true)
        }

        func tableView(
            _ tableView: UITableView,
            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
        ) -> UISwipeActionsConfiguration? {
            let actions = parent.swipeActions.map { swipeAction in
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

private final class ExercisePickerExerciseCell: UITableViewCell {
    private var exercise: ExercisePickerExercise?
    private var isExerciseSelected = false

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

    func configure(with exercise: ExercisePickerExercise, isSelected: Bool) {
        self.exercise = exercise
        isExerciseSelected = isSelected
        applyContentConfiguration()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        exercise = nil
        isExerciseSelected = false
        contentConfiguration = nil
    }

    private func applyContentConfiguration() {
        guard let exercise else { return }

        contentConfiguration = UIHostingConfiguration {
            SimpleGymRow(
                title: exercise.title,
                showsDisclosureIndicator: false,
                showsCheckmark: isExerciseSelected
            )
        }
        .margins(.all, 0)
    }
}
