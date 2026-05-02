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

struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: AddWorkoutSheetTab = .exercises
    @State private var showsExerciseTabSwitcher = true

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
                        toolbar
                        Color.clear
                            .frame(height: Metrics.externalSegmentedReservedHeight)
                            .accessibilityHidden(true)
                        programsEmptyState
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
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .programs {
                showsExerciseTabSwitcher = true
            }
        }
    }

    private var shouldShowSegmentedControl: Bool {
        selectedTab == .programs || showsExerciseTabSwitcher
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
