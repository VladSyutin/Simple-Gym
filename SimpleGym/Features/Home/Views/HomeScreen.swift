import SwiftUI

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
private let calendarRowCountAnimation = Animation.easeInOut(duration: 0.18)

struct HomeScreen: View {
    @State private var isCalendarExpanded = false
    @State private var userSelectedDate: Date?
    @State private var visibleMonthPageID: Date? = simpleGymCalendar.startOfMonth(for: Date())
    @State private var visibleWeekPageID: Date? = simpleGymCalendar.startOfWeek(for: Date())

    private let trainingDates: Set<Date> = Set(
        [
            simpleGymCalendar.date(from: DateComponents(year: 2026, month: 4, day: 14)),
            simpleGymCalendar.date(from: DateComponents(year: 2026, month: 4, day: 16)),
        ]
        .compactMap { $0 }
        .map { simpleGymCalendar.startOfDay(for: $0) }
    )

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            screenContent(currentDate: simpleGymCalendar.startOfDay(for: context.date))
        }
    }

    @ViewBuilder
    private func screenContent(currentDate: Date) -> some View {
        let selectedDate = selectedDate(for: currentDate)
        let displayedMonthStart = displayedMonthStart(for: selectedDate)

        VStack(spacing: 0) {
            HomeCalendar(
                visibleMonthPageID: $visibleMonthPageID,
                visibleWeekPageID: $visibleWeekPageID,
                currentDate: currentDate,
                selectedDate: selectedDate,
                displayedMonthStart: displayedMonthStart,
                isExpanded: isCalendarExpanded,
                trainingDates: trainingDates,
                onMonthTap: {
                    toggleCalendar(selectedDate: selectedDate)
                },
                onTodayTap: {
                    jumpToToday(currentDate: currentDate)
                },
                onDateTap: { date in
                    setSelectedDate(date, currentDate: currentDate)
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

            Spacer(minLength: Spacing.xxLarge)

            EmptyStateView(
                iconSystemName: "dumbbell.fill",
                title: "Нет тренировок",
                message: "Добавьте упражнение или программу."
            )
            .padding(.horizontal, Spacing.large)

            Spacer()
        }
        .background(ColorTokens.backgroundPrimary.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                LiquidGlassButton(
                    title: "Добавить тренировку",
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

    private func selectedDate(for currentDate: Date) -> Date {
        simpleGymCalendar.startOfDay(for: userSelectedDate ?? currentDate)
    }

    private func displayedMonthStart(for selectedDate: Date) -> Date {
        if isCalendarExpanded {
            return visibleMonthPageID ?? simpleGymCalendar.startOfMonth(for: selectedDate)
        }

        let weekStart = visibleWeekPageID ?? simpleGymCalendar.startOfWeek(for: selectedDate)
        let pivotDate = simpleGymCalendar.date(byAdding: .day, value: 3, to: weekStart) ?? weekStart
        return simpleGymCalendar.startOfMonth(for: pivotDate)
    }

    private func toggleCalendar(selectedDate: Date) {
        visibleMonthPageID = simpleGymCalendar.startOfMonth(for: selectedDate)
        visibleWeekPageID = simpleGymCalendar.startOfWeek(for: selectedDate)

        withAnimation(calendarTransitionAnimation) {
            isCalendarExpanded.toggle()
        }
    }

    private func setSelectedDate(_ date: Date, currentDate: Date) {
        let normalizedDate = simpleGymCalendar.startOfDay(for: date)
        performWithoutAnimation {
            userSelectedDate = simpleGymCalendar.isDate(normalizedDate, inSameDayAs: currentDate) ? nil : normalizedDate
            visibleMonthPageID = simpleGymCalendar.startOfMonth(for: normalizedDate)
            visibleWeekPageID = simpleGymCalendar.startOfWeek(for: normalizedDate)
        }
    }

    private func jumpToToday(currentDate: Date) {
        let today = simpleGymCalendar.startOfDay(for: currentDate)
        let todayMonthStart = simpleGymCalendar.startOfMonth(for: today)
        let todayWeekStart = simpleGymCalendar.startOfWeek(for: today)

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
}

private struct HomeCalendar: View {
    @Binding var visibleMonthPageID: Date?
    @Binding var visibleWeekPageID: Date?

    @State private var monthScrollPageID: Date?

    let currentDate: Date
    let selectedDate: Date
    let displayedMonthStart: Date
    let isExpanded: Bool
    let trainingDates: Set<Date>
    let onMonthTap: () -> Void
    let onTodayTap: () -> Void
    let onDateTap: (Date) -> Void

    private static let weekdaySymbols = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"]

    private var calendar: Calendar {
        simpleGymCalendar
    }

    private var showsTodayButton: Bool {
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
                        .opacity(isExpanded ? 1 : 0)
                        .allowsHitTesting(isExpanded)

                    weekPager(metrics: metrics)
                        .opacity(isExpanded ? 0 : 1)
                        .allowsHitTesting(!isExpanded)
                }
                .frame(height: visibleWeeksHeight, alignment: .top)
                .clipped()

                HomeSectionHeader(title: "Тренировки")
            }
            .scrollChromeSurface()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .animation(calendarTransitionAnimation, value: isExpanded)
            .animation(calendarRowCountAnimation, value: presentedExpandedWeekCount)
        }
        .frame(height: totalHeight)
        .onAppear {
            syncMonthScrollPageIDWithBinding()
        }
        .onChange(of: visibleMonthPageID) { _, _ in
            syncMonthScrollPageIDWithBinding(animated: true)
        }
    }

    private var totalHeight: CGFloat {
        let metrics = CalendarLayoutMetrics(width: 0)
        let weeksHeight = isExpanded
            ? metrics.monthGridHeight(weekCount: presentedExpandedWeekCount)
            : metrics.weekHeight
        return metrics.monthRowHeight + metrics.weekdayRowHeight + weeksHeight + metrics.sectionHeaderHeight
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
                monthWeekRow(days: week, metrics: metrics)
            }
        }
    }

    @ViewBuilder
    private func monthWeekRow(days: [CalendarDay?], metrics: CalendarLayoutMetrics) -> some View {
        HStack(spacing: metrics.daySpacing) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                Group {
                    if let day {
                        HomeCalendarDayCell(
                            day: day,
                            style: dayStyle(for: day),
                            showsTraining: day.containsTraining(in: trainingDates, calendar: calendar),
                            onTap: {
                                onDateTap(day.date)
                            }
                        )
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
    private func weekRow(days: [CalendarDay], metrics: CalendarLayoutMetrics) -> some View {
        HStack(spacing: metrics.daySpacing) {
            ForEach(days) { day in
                HomeCalendarDayCell(
                    day: day,
                    style: dayStyle(for: day),
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

    private func dayStyle(for day: CalendarDay) -> HomeCalendarDayStyle {
        if calendar.isDate(day.date, inSameDayAs: currentDate) && calendar.isDate(day.date, inSameDayAs: selectedDate) {
            return .todaySelected
        }

        if calendar.isDate(day.date, inSameDayAs: selectedDate) {
            return .selected
        }

        if calendar.isDate(day.date, inSameDayAs: currentDate) {
            return .today
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
        let normalizedBindingPageID = normalizedMonthPageID(visibleMonthPageID) ?? displayedMonthStart
        guard monthScrollPageID != normalizedBindingPageID else {
            return
        }

        if animated {
            withAnimation(calendarTransitionAnimation) {
                monthScrollPageID = normalizedBindingPageID
            }
        } else {
            monthScrollPageID = normalizedBindingPageID
        }
    }

    private func normalizedMonthPageID(_ pageID: Date?) -> Date? {
        pageID.map(calendar.startOfMonth(for:))
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
    let title: LocalizedStringKey

    private enum Metrics {
        static let height: CGFloat = 56
    }

    var body: some View {
        HStack(spacing: Spacing.small) {
            Text(title)
                .simpleGymTextStyle(.title2Emphasized)
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Button("Посмотреть статистику", systemImage: "chart.xyaxis.line") {}
                Button("Удалить упражнение", systemImage: "trash", role: .destructive) {}
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
    case today
    case selected
    case todaySelected

    var typography: Typography {
        switch self {
        case .selected, .todaySelected:
            return .selectedDayNumber
        case .current, .today:
            return .dayNumber
        }
    }

    var textColor: Color {
        switch self {
        case .current:
            return ColorTokens.labelPrimary
        case .today, .selected:
            return ColorTokens.accentBlue
        case .todaySelected:
            return ColorTokens.white
        }
    }

    var backgroundColor: Color? {
        switch self {
        case .selected:
            return ColorTokens.accentBlueSoft
        case .todaySelected:
            return ColorTokens.accentBlue
        case .current, .today:
            return nil
        }
    }

    var trainingIndicatorColor: Color {
        switch self {
        case .current:
            return ColorTokens.labelPrimary
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
            if isDate(currentDay, equalTo: monthStart, toGranularity: .month) {
                days.append(CalendarDay(date: currentDay))
            } else {
                days.append(nil)
            }
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
}

#Preview {
    HomeScreen()
}
