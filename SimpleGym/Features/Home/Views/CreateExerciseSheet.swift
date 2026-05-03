import SwiftUI

struct CreateExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss

    let categoryTitle: String
    let creationKind: WorkoutExerciseKind
    let initialTitle: String
    let onCreate: (String) -> Void

    @State private var exerciseTitle: String
    @State private var doublesWeight = false
    @State private var usesBodyweight = false
    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.displayScale) private var displayScale

    private var separatorHeight: CGFloat {
        1 / max(displayScale, 1)
    }

    init(
        categoryTitle: String,
        creationKind: WorkoutExerciseKind,
        initialTitle: String = "",
        onCreate: @escaping (String) -> Void
    ) {
        self.categoryTitle = categoryTitle
        self.creationKind = creationKind
        self.initialTitle = initialTitle
        self.onCreate = onCreate
        _exerciseTitle = State(initialValue: initialTitle)
    }

    private var trimmedTitle: String {
        exerciseTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canCreate: Bool {
        !trimmedTitle.isEmpty
    }

    private var isEditing: Bool {
        !initialTitle.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            topChrome
            content
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorTokens.backgroundPrimary)
        .task {
            isNameFieldFocused = true
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

    private var topChrome: some View {
        VStack(spacing: 0) {
            grabber
            toolbar
        }
        .topScrollChromeSurface()
    }

    private var toolbar: some View {
        ZStack {
            VStack(spacing: 1) {
                Text(isEditing ? "Изменение упражнения" : "Создание упражнения")
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.23)
                    .foregroundStyle(ColorTokens.labelPrimary)

                Text(categoryTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ColorTokens.labelSecondary)
            }
            .frame(maxWidth: .infinity)

            HStack {
                LiquidGlassSymbolButton(
                    systemImage: "xmark",
                    accessibilityLabel: "Закрыть"
                ) {
                    dismiss()
                }

                Spacer()

                if canCreate {
                    LiquidGlassSymbolButton(
                        systemImage: "checkmark",
                        accessibilityLabel: isEditing ? "Сохранить упражнение" : "Добавить упражнение",
                        variant: .tinted
                    ) {
                        createExercise()
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
        VStack(spacing: 0) {
            titleField

            if creationKind == .strength {
                strengthOptions
            }
        }
    }

    private var titleField: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ColorTokens.separatorVibrant)
                .frame(height: separatorHeight)
                .padding(.horizontal, Spacing.small)

            HStack(spacing: 0) {
                TextField("", text: $exerciseTitle)
                    .textFieldStyle(.plain)
                    .simpleGymTextStyle(.bodyMedium)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit(createExercise)
                    .accessibilityLabel("Название упражнения")
                    .overlay(alignment: .leading) {
                        if exerciseTitle.isEmpty {
                            Text("Название упражнения")
                                .simpleGymTextStyle(.bodyMedium, color: ColorTokens.labelTertiary)
                                .allowsHitTesting(false)
                        }
                    }

                if !exerciseTitle.isEmpty {
                    Button {
                        exerciseTitle = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(ColorTokens.labelTertiary)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Очистить название упражнения")
                }
            }
            .frame(minHeight: 51)
            .padding(.horizontal, Spacing.small)
        }
    }

    private var strengthOptions: some View {
        VStack(spacing: 0) {
            switchRow(
                title: "Удвоить вес",
                isOn: $doublesWeight
            )

            switchRow(
                title: "Собственный вес",
                isOn: $usesBodyweight
            )
        }
    }

    private func switchRow(title: LocalizedStringKey, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Spacing.small) {
            Text(title)
                .simpleGymTextStyle(.bodyRegular)
                .foregroundStyle(ColorTokens.labelPrimary)

            Spacer(minLength: Spacing.small)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(ColorTokens.accentBlue)
        }
        .frame(maxWidth: .infinity, minHeight: 52)
        .padding(.horizontal, Spacing.small)
    }

    private func createExercise() {
        guard canCreate else { return }
        onCreate(trimmedTitle)
        dismiss()
    }
}

#Preview("Cardio") {
    CreateExerciseSheet(
        categoryTitle: "Кардио",
        creationKind: .cardio,
        onCreate: { _ in }
    )
    .presentationDetents([.large])
}

#Preview("Strength") {
    CreateExerciseSheet(
        categoryTitle: "Спина",
        creationKind: .strength,
        onCreate: { _ in }
    )
    .presentationDetents([.large])
}
