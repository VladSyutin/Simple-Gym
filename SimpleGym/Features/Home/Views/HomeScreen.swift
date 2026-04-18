import SwiftUI

struct HomeScreen: View {
    @State private var selectedDay = 31

    private let days: [WorkoutDay] = [
        .init(weekday: "ПН", dayNumber: 29),
        .init(weekday: "ВТ", dayNumber: 30),
        .init(weekday: "СР", dayNumber: 31),
        .init(weekday: "ЧТ", dayNumber: 1),
        .init(weekday: "ПТ", dayNumber: 2),
        .init(weekday: "СБ", dayNumber: 3),
        .init(weekday: "ВС", dayNumber: 4),
    ]

    var body: some View {
        VStack(spacing: 0) {
            CalendarHeader(selectedDay: $selectedDay, days: days)

            Spacer(minLength: Spacing.xxLarge)

            EmptyStateView(
                iconSystemName: "dumbbell.fill",
                title: "Нет тренировок",
                message: "Добавьте упражнение\nили программу."
            )
            .padding(.horizontal, Spacing.large)

            Spacer()
        }
        .background(ColorTokens.backgroundPrimary.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                PrimaryLiquidGlassButton(title: "Добавить тренировку") {}
                    .padding(.horizontal, Spacing.xLarge)
                    .padding(.top, Spacing.large)
                    .padding(.bottom, Spacing.xxSmall)
            }
            .background {
                LinearGradient(
                    colors: [
                        ColorTokens.backgroundPrimary.opacity(0),
                        ColorTokens.backgroundPrimary.opacity(0.92),
                        ColorTokens.backgroundPrimary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

private struct CalendarHeader: View {
    @Binding var selectedDay: Int
    let days: [WorkoutDay]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.xxxSmall) {
                Text("Дек. 2025")
                    .simpleGymTextStyle(.bodyEmphasized)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ColorTokens.accentBlue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.small)
            .padding(.top, Spacing.xxSmall)
            .padding(.bottom, Spacing.xxxSmall)

            HStack {
                ForEach(days) { day in
                    Text(day.weekday)
                        .simpleGymTextStyle(.captionSemibold, color: ColorTokens.labelTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.bottom, Spacing.xxxSmall)

            HStack {
                ForEach(days) { day in
                    Button {
                        selectedDay = day.dayNumber
                    } label: {
                        ZStack {
                            if selectedDay == day.dayNumber {
                                Circle()
                                    .fill(ColorTokens.accentBlue)
                            }

                            Text("\(day.dayNumber)")
                                .simpleGymTextStyle(
                                    selectedDay == day.dayNumber ? .selectedDayNumber : .dayNumber,
                                    color: selectedDay == day.dayNumber ? ColorTokens.white : ColorTokens.labelPrimary
                                )
                        }
                        .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Spacing.small)
            .padding(.bottom, Spacing.xxxSmall)
        }
        .scrollChromeSurface()
    }
}

private struct WorkoutDay: Identifiable {
    let weekday: String
    let dayNumber: Int

    var id: Int { dayNumber }
}

#Preview {
    HomeScreen()
}
