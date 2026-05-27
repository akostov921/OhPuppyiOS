import SwiftUI

// MARK: - Vet Tab Container

struct VetTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                NavigationStack { VetHomeView() }
            } label: {
                Label("Начало", systemImage: selectedTab == 0 ? "stethoscope" : "stethoscope")
            }
            Tab(value: 1) {
                NavigationStack { VetCalendarView() }
            } label: {
                Label("Календар", systemImage: selectedTab == 1 ? "calendar" : "calendar")
            }
            Tab(value: 2) {
                NavigationStack { VetServicesView() }
            } label: {
                Label("Услуги", systemImage: selectedTab == 2 ? "list.bullet.clipboard.fill" : "list.bullet.clipboard")
            }
            Tab(value: 3) {
                NavigationStack { VetSettingsView() }
            } label: {
                Label("Профил", systemImage: selectedTab == 3 ? "person.fill" : "person")
            }
        }
        .tint(OPTheme.primary)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

// MARK: - Vet Home (Dashboard)

struct VetHomeView: View {
    @Environment(AppStore.self) private var store
    @State private var showAddService = false
    @State private var showAddAppointment = false
    @State private var showVerifyAlert = false
    @State private var showCompleteSheet: VetAppointment?
    @State private var heroFloat: CGFloat = 0

    private var uniquePatientCount: Int {
        Set(store.vetAppointments.map { $0.dogName }).count
    }

    private var completedCount: Int {
        store.vetAppointments.filter { $0.status == .completed }.count
    }

    private var todayAppointments: [VetAppointment] {
        let cal = Calendar.current
        return store.vetAppointments.filter { cal.isDateInToday($0.date) }
            .sorted { $0.date < $1.date }
    }

    private var todayUpcomingCount: Int {
        todayAppointments.filter { $0.status == .upcoming }.count
    }

    private var todayCompletedCount: Int {
        todayAppointments.filter { $0.status == .completed }.count
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Добро утро" }
        if hour < 18 { return "Добър ден" }
        return "Добър вечер"
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroSection
                VStack(spacing: 18) {
                    statsHighlight
                    appointmentPipeline
                    todaySection
                    quickActions
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showAddService) { AddVetServiceSheet() }
        .sheet(isPresented: $showAddAppointment) { VetNewAppointmentSheet() }
        .sheet(item: $showCompleteSheet) { appt in
            VetCompleteAppointmentSheet(appointment: appt)
        }
        .alert("Верификация на ваксини", isPresented: $showVerifyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Функцията ще бъде налична скоро.")
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { heroFloat = -8 }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(hex: "52B788"), Color(hex: "40916C"), Color(hex: "2D6A4F")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 220)
            .overlay {
                ZStack {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: ["stethoscope", "cross.fill", "heart.fill", "pill.fill", "pawprint.fill"][i])
                            .font(.system(size: CGFloat([18, 14, 12, 16, 10][i])))
                            .foregroundStyle(.white.opacity(Double([0.08, 0.06, 0.09, 0.05, 0.07][i])))
                            .offset(
                                x: CGFloat([-80, 100, 60, -50, 120][i]),
                                y: CGFloat([-35, 15, -55, 45, -25][i]) + heroFloat * CGFloat([1, -0.6, 0.8, -1, 0.5][i])
                            )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                DashboardRoleSwitcher()
                    .padding(.bottom, 4)

                Text("\(greeting), Д-р \(store.ownerName)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(.white).frame(width: 7, height: 7)
                        Text("Клиниката е активна")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(.white.opacity(0.2), in: Capsule())

                    HStack(spacing: 4) {
                        Image(systemName: "calendar").font(.system(size: 11, weight: .bold))
                        Text("\(todayUpcomingCount) днес")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(.white.opacity(0.2), in: Capsule())

                    if todayCompletedCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                            Text("\(todayCompletedCount) завършени")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(.white.opacity(0.2), in: Capsule())
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Stats Highlight

    private var statsHighlight: some View {
        HStack(spacing: 10) {
            homeStatCard(
                value: "\(store.vetServices.count)",
                label: "Услуги",
                icon: "list.bullet.clipboard.fill",
                color: OPTheme.mint,
                gradient: OPTheme.mintGradient
            )
            homeStatCard(
                value: "\(uniquePatientCount)",
                label: "Пациенти",
                icon: "pawprint.fill",
                color: OPTheme.sky,
                gradient: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }

    private func homeStatCard(value: String, label: String, icon: String, color: Color, gradient: LinearGradient) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(OPTheme.text)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Appointment Pipeline

    private var appointmentPipeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статус на часовете")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(OPTheme.text)

            HStack(spacing: 0) {
                let stages: [(label: String, icon: String, color: Color, count: Int)] = [
                    ("Предстоящи", "clock.fill", OPTheme.sky, store.vetAppointments.filter { $0.status == .upcoming }.count),
                    ("Завършени", "checkmark.circle.fill", OPTheme.success, completedCount),
                    ("Отменени", "xmark.circle.fill", OPTheme.danger, store.vetAppointments.filter { $0.status == .cancelled }.count),
                ]
                ForEach(Array(stages.enumerated()), id: \.offset) { idx, stage in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(stage.count > 0 ? stage.color.opacity(0.15) : OPTheme.surfaceSunken)
                                .frame(width: 44, height: 44)
                            Image(systemName: stage.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(stage.count > 0 ? stage.color : OPTheme.textTertiary)
                        }
                        .overlay(alignment: .topTrailing) {
                            if stage.count > 0 {
                                Text("\(stage.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 18, height: 18)
                                    .background(stage.color, in: Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }

                        Text(stage.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)

                    if idx < stages.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(OPTheme.textTertiary.opacity(0.5))
                            .padding(.bottom, 18)
                    }
                }
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Днешни часове")

            if todayAppointments.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 20))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Няма часове за днес")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                ForEach(todayAppointments) { appt in
                    HStack(spacing: 0) {
                        // Time column
                        VStack(spacing: 2) {
                            Text(appt.date.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.mint)
                        }
                        .frame(width: 56)

                        // Colored left bar
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(appointmentBarColor(appt.status))
                            .frame(width: 3)
                            .padding(.vertical, 4)

                        // Content
                        VStack(alignment: .leading, spacing: 3) {
                            Text(appt.serviceName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            HStack(spacing: 4) {
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(OPTheme.textTertiary)
                                Text(appt.dogName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(OPTheme.textSecondary)
                            }
                        }
                        .padding(.leading, 10)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("\(Int(appt.price)) лв")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.mint)

                            appointmentStatusBadge(appt.status)

                            if appt.status == .upcoming {
                                Button {
                                    showCompleteSheet = appt
                                } label: {
                                    Text("Завърши")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(OPTheme.success, in: Capsule())
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
                }
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Бързи действия")

            HStack(spacing: 10) {
                vetQuickAction(icon: "calendar.badge.plus", label: "Нов час", gradient: OPTheme.mintGradient) {
                    showAddAppointment = true
                }
                vetQuickAction(icon: "plus.circle.fill", label: "Добави услуга", gradient: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing)) {
                    showAddService = true
                }
                vetQuickAction(icon: "checkmark.seal.fill", label: "Ваксини", gradient: LinearGradient(colors: [OPTheme.accent, OPTheme.accentDark], startPoint: .leading, endPoint: .trailing)) {
                    showVerifyAlert = true
                }
            }
        }
    }

    private func vetQuickAction(icon: String, label: String, gradient: LinearGradient, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Helpers

    private func appointmentBarColor(_ status: AppointmentStatus) -> Color {
        switch status {
        case .upcoming: OPTheme.sky
        case .completed: OPTheme.success
        case .cancelled: OPTheme.danger
        }
    }

    private func appointmentStatusBadge(_ status: AppointmentStatus) -> some View {
        let color: Color = switch status {
        case .upcoming: OPTheme.sky
        case .completed: OPTheme.success
        case .cancelled: OPTheme.danger
        }
        return Text(status.label)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Vet Calendar View

struct VetCalendarView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var appointmentToComplete: VetAppointment?

    private let calendar = Calendar.current
    private let weekdaySymbols = ["Пон", "Вт", "Ср", "Чет", "Пет", "Съб", "Нед"]

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "bg_BG")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonth).capitalized
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return [] }

        // weekday offset (Monday = 0)
        var weekday = calendar.component(.weekday, from: firstDay)
        // Convert Sunday=1..Saturday=7 to Monday=0..Sunday=6
        weekday = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        // Pad to fill last row
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }

    private func appointmentsForDate(_ date: Date) -> [VetAppointment] {
        store.vetAppointments.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    private func hasAppointments(on date: Date) -> Bool {
        store.vetAppointments.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                if !store.vetAcceptsOnlineBooking {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(OPTheme.warning)
                        Text("Онлайн записването е изключено. Пациентите ще се свързват по телефон.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(OPTheme.warningSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.warning.opacity(0.3), lineWidth: 1))
                }

                // Month navigation
                monthHeader

                // Weekday headers
                weekdayHeader

                // Day grid
                dayGrid

                // Appointments for selected day
                selectedDayAppointments
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Календар")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $appointmentToComplete) { appt in
            VetCompleteAppointmentSheet(appointment: appt)
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(OPTheme.quickSpring) {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                    .frame(width: 36, height: 36)
                    .background(OPTheme.primarySoft, in: Circle())
            }

            Spacer()

            Text(monthTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(OPTheme.text)

            Spacer()

            Button {
                withAnimation(OPTheme.quickSpring) {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                    .frame(width: 36, height: 36)
                    .background(OPTheme.primarySoft, in: Circle())
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(OPTheme.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Day Grid

    private var dayGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                if let date {
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let hasAppts = hasAppointments(on: date)

                    Button {
                        withAnimation(OPTheme.quickSpring) { selectedDate = date }
                    } label: {
                        VStack(spacing: 3) {
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 15, weight: isSelected || isToday ? .bold : .medium))
                                .foregroundStyle(
                                    isSelected ? .white :
                                    isToday ? OPTheme.mint :
                                    OPTheme.text
                                )

                            Circle()
                                .fill(hasAppts ? OPTheme.success : .clear)
                                .frame(width: 5, height: 5)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            isSelected ? AnyShapeStyle(OPTheme.mintGradient) :
                            isToday ? AnyShapeStyle(OPTheme.mint.opacity(0.1)) :
                            AnyShapeStyle(.clear),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                        )
                    }
                } else {
                    Color.clear.frame(height: 42)
                }
            }
        }
        .padding(12)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Selected Day Appointments

    private var selectedDayAppointments: some View {
        let appts = appointmentsForDate(selectedDate)
        let formatter: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "bg_BG")
            f.dateFormat = "d MMMM, EEEE"
            return f
        }()

        return VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: formatter.string(from: selectedDate).capitalized)

            if appts.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Няма часове за този ден")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                ForEach(appts) { appt in
                    calendarAppointmentRow(appt)
                }
            }
        }
    }

    private func calendarAppointmentRow(_ appt: VetAppointment) -> some View {
        HStack(spacing: 12) {
            // Time column
            VStack(spacing: 2) {
                Text(appt.date.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.mint)
            }
            .frame(width: 52)

            // Colored bar
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(appointmentBarColor(appt.status))
                .frame(width: 3)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(appt.serviceName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text(appt.dogName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("\(Int(appt.price)) лв")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.mint)

                calendarStatusBadge(appt.status)

                if appt.status == .upcoming {
                    Button {
                        appointmentToComplete = appt
                    } label: {
                        Text("Завърши")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(OPTheme.success, in: Capsule())
                    }
                }
            }
        }
        .padding(12)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private func appointmentBarColor(_ status: AppointmentStatus) -> Color {
        switch status {
        case .upcoming: OPTheme.sky
        case .completed: OPTheme.success
        case .cancelled: OPTheme.danger
        }
    }

    private func calendarStatusBadge(_ status: AppointmentStatus) -> some View {
        let color: Color = switch status {
        case .upcoming: OPTheme.sky
        case .completed: OPTheme.success
        case .cancelled: OPTheme.danger
        }
        return Text(status.label)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Vet Services View

struct VetServicesView: View {
    @Environment(AppStore.self) private var store
    @State private var showAddService = false
    @State private var selectedCategory: VetServiceCategory?

    private var filteredServices: [VetService] {
        if let cat = selectedCategory {
            return store.vetServices.filter { $0.category == cat }
        }
        return store.vetServices
    }

    private var completedRevenue: Double {
        store.vetAppointments
            .filter { $0.status == .completed }
            .reduce(0) { $0 + $1.price }
    }

    private var groupedServices: [(category: VetServiceCategory, services: [VetService])] {
        VetServiceCategory.allCases.compactMap { cat in
            let services = filteredServices.filter { $0.category == cat }
            if services.isEmpty { return nil }
            return (category: cat, services: services)
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Revenue summary
                revenueSummary

                // Category filter chips
                categoryChips

                // Services list grouped by category
                servicesListGrouped
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Услуги")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddService = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(OPTheme.mint)
                }
            }
        }
        .sheet(isPresented: $showAddService) { AddVetServiceSheet() }
    }

    // MARK: - Revenue Summary

    private var revenueSummary: some View {
        HStack(spacing: 14) {
            Image(systemName: "banknote.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(OPTheme.success)
                .frame(width: 48, height: 48)
                .background(OPTheme.successSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text("Общи приходи")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                Text("\(Int(completedRevenue)) лв")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(OPTheme.success)
            }
            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("Завършени")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
                Text("\(store.vetAppointments.filter { $0.status == .completed }.count)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.success.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(OPTheme.quickSpring) { selectedCategory = nil }
                } label: {
                    Text("Всички")
                        .font(.system(size: 13, weight: selectedCategory == nil ? .bold : .medium))
                        .foregroundStyle(selectedCategory == nil ? .white : OPTheme.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedCategory == nil ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                            in: Capsule()
                        )
                }

                ForEach(VetServiceCategory.allCases, id: \.self) { cat in
                    Button {
                        withAnimation(OPTheme.quickSpring) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                    } label: {
                        Label(cat.label, systemImage: cat.icon)
                            .font(.system(size: 13, weight: selectedCategory == cat ? .bold : .medium))
                            .foregroundStyle(selectedCategory == cat ? .white : OPTheme.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == cat ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                in: Capsule()
                            )
                    }
                }
            }
        }
    }

    // MARK: - Services List Grouped

    private var servicesListGrouped: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(groupedServices, id: \.category) { group in
                VStack(alignment: .leading, spacing: 8) {
                    // Category header
                    HStack(spacing: 6) {
                        Image(systemName: group.category.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.mint)
                        Text(group.category.label.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                    }
                    .padding(.top, 4)

                    ForEach(group.services) { service in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(service.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(OPTheme.text)
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 10))
                                        .foregroundStyle(OPTheme.textTertiary)
                                    Text(service.duration)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(OPTheme.textTertiary)
                                }
                            }
                            Spacer()
                            Text("\(Int(service.price)) лв")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(OPTheme.mint)
                        }
                        .padding(14)
                        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation(OPTheme.quickSpring) {
                                    store.removeVetService(id: service.id)
                                }
                            } label: {
                                Label("Изтрий", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            if filteredServices.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 28))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Няма услуги в тази категория")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

// MARK: - Vet Settings View

struct VetSettingsView: View {
    @Environment(AppStore.self) private var store
    @State private var showLogoutAlert = false
    @State private var showDarkMode = false
    @State private var showAddService = false
    @State private var showAddAppointment = false
    @State private var heroFloat: CGFloat = 0

    private var completedRevenue: Double {
        store.vetAppointments.filter { $0.status == .completed }.reduce(0) { $0 + $1.price }
    }

    private var completedCount: Int {
        store.vetAppointments.filter { $0.status == .completed }.count
    }

    private var uniquePatientCount: Int {
        Set(store.vetAppointments.map { $0.dogName }).count
    }

    private var vetRating: String {
        let rating = min(5.0, 4.0 + Double(completedCount) * 0.1)
        return String(format: "%.1f", rating)
    }

    private let mockWeekAppts: [Double] = [3, 5, 2, 7, 4, 1, 6]
    private let mockWeekLabels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Нд"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroHeader
                statsGrid
                    .padding(.top, -36)
                    .padding(.horizontal, OPTheme.screenPadding)

                VStack(spacing: 20) {
                    settingsQuickActions
                    weeklyChart
                    clinicInfoSection
                    roleSwitcherSection
                    preferencesSection
                    logoutButton
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .alert("Излизане?", isPresented: $showLogoutAlert) {
            Button("Отказ", role: .cancel) {}
            Button("Излез", role: .destructive) { store.signOut() }
        } message: {
            Text("Сигурни ли сте, че искате да излезете?")
        }
        .sheet(isPresented: $showDarkMode) { DarkModeSheet() }
        .sheet(isPresented: $showAddService) { AddVetServiceSheet() }
        .sheet(isPresented: $showAddAppointment) { VetNewAppointmentSheet() }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { heroFloat = -6 }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "52B788"), Color(hex: "40916C"), Color(hex: "2D6A4F")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 280)
            .overlay {
                ZStack {
                    ForEach(0..<4, id: \.self) { i in
                        Image(systemName: ["cross.fill", "heart.fill", "pill.fill", "stethoscope"][i])
                            .font(.system(size: CGFloat([14, 18, 12, 16][i])))
                            .foregroundStyle(.white.opacity(Double([0.08, 0.06, 0.1, 0.05][i])))
                            .offset(
                                x: CGFloat([-60, 80, 40, -90][i]),
                                y: CGFloat([-40, 20, -70, 50][i]) + heroFloat * CGFloat([1, -0.7, 0.5, -1][i])
                            )
                    }
                }
            }

            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(.white.opacity(0.2)).frame(width: 96, height: 96)
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.white)
                        .frame(width: 80, height: 80)
                        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
                        .overlay {
                            Image(systemName: "stethoscope")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(OPTheme.mintGradient)
                        }
                }

                Text("Д-р \(store.ownerName)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Text("Клиника Лапа")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))

                HStack(spacing: 6) {
                    Circle().fill(.white).frame(width: 7, height: 7)
                    Text("Активен профил").font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(.white.opacity(0.2), in: Capsule())

                HStack(spacing: 16) {
                    vetHeroStat(value: "\(store.vetServices.count)", label: "услуги")
                    Circle().fill(.white.opacity(0.4)).frame(width: 4, height: 4)
                    vetHeroStat(value: "\(uniquePatientCount)", label: "пациенти")
                    Circle().fill(.white.opacity(0.4)).frame(width: 4, height: 4)
                    vetHeroStat(value: vetRating, label: "рейтинг")
                }
                .padding(.top, 4)
            }
            .padding(.bottom, 52)
        }
    }

    private func vetHeroStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 10) {
            settingsStatCard(value: String(format: "%.0f лв", completedRevenue), label: "Приходи", icon: "chart.line.uptrend.xyaxis", color: OPTheme.success)
            settingsStatCard(value: "\(completedCount)", label: "Завършени", icon: "checkmark.circle.fill", color: OPTheme.mint)
            settingsStatCard(value: "\(uniquePatientCount)", label: "Пациенти", icon: "pawprint.fill", color: OPTheme.sky)
        }
    }

    private func settingsStatCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15), in: Circle())
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(OPTheme.text)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(OPTheme.border.opacity(0.5), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    // MARK: - Quick Actions

    private var settingsQuickActions: some View {
        HStack(spacing: 10) {
            settingsQuickAction(icon: "calendar.badge.plus", label: "Нов час", gradient: OPTheme.mintGradient) { showAddAppointment = true }
            settingsQuickAction(icon: "plus.circle.fill", label: "Добави услуга", gradient: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing)) { showAddService = true }
            settingsQuickAction(icon: "calendar", label: "Календар", gradient: LinearGradient(colors: [OPTheme.accent, OPTheme.accentDark], startPoint: .leading, endPoint: .trailing)) {}
        }
    }

    private func settingsQuickAction(icon: String, label: String, gradient: LinearGradient, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Часове тази седмица")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .bold)).foregroundStyle(OPTheme.success)
                        Text("+12% спрямо миналата").font(.system(size: 12, weight: .semibold)).foregroundStyle(OPTheme.success)
                    }
                }
                Spacer()
                Text("\(Int(mockWeekAppts.reduce(0, +)))")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(OPTheme.mint)
            }

            let maxVal = mockWeekAppts.max() ?? 1
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(i == 6
                                ? LinearGradient(colors: [OPTheme.mint, Color(hex: "2D6A4F")], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [OPTheme.mint.opacity(0.3), OPTheme.mint.opacity(0.15)], startPoint: .top, endPoint: .bottom))
                            .frame(height: max(8, CGFloat(mockWeekAppts[i] / maxVal) * 80))
                        Text(mockWeekLabels[i])
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(i == 6 ? OPTheme.mint : OPTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Clinic Info

    private var clinicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация за клиниката").font(.system(size: 15, weight: .bold)).foregroundStyle(OPTheme.text)

            VStack(spacing: 0) {
                clinicDetailRow(icon: "building.2.fill", label: "Клиника", value: "Клиника Лапа", color: OPTheme.mint)
                Divider().padding(.leading, 52)
                clinicDetailRow(icon: "mappin.circle.fill", label: "Адрес", value: "ул. Цар Борис III 120, София", color: OPTheme.sky)
                Divider().padding(.leading, 52)
                clinicDetailRow(icon: "phone.fill", label: "Телефон", value: "+359 88 123 4567", color: OPTheme.accent)
                Divider().padding(.leading, 52)
                clinicDetailRow(icon: "envelope.fill", label: "Имейл", value: store.ownerEmail.isEmpty ? "clinic@ohpuppy.bg" : store.ownerEmail, color: OPTheme.rose)
                Divider().padding(.leading, 52)
                clinicDetailRow(icon: "clock.fill", label: "Работно време", value: "Пон-Пет 09-18", color: OPTheme.success)
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    private func clinicDetailRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(label).font(.system(size: 14, weight: .medium)).foregroundStyle(OPTheme.textSecondary)
            Spacer()
            Text(value).font(.system(size: 14, weight: .semibold)).foregroundStyle(OPTheme.text).lineLimit(1)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
    }

    // MARK: - Role Switcher

    private var roleSwitcherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Превключи роля").font(.system(size: 15, weight: .bold)).foregroundStyle(OPTheme.text)

            let availableRoles: [UserRole] = [.owner] + store.registeredRoles.sorted(by: { $0.rawValue < $1.rawValue })
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(availableRoles, id: \.self) { role in
                        let isActive = store.activeRole == role
                        Button {
                            withAnimation(OPTheme.quickSpring) { store.activeRole = role }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: role.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(isActive ? .white : OPTheme.textSecondary)
                                    .frame(width: 44, height: 44)
                                    .background(isActive ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                Text(role.label)
                                    .font(.system(size: 11, weight: isActive ? .bold : .medium))
                                    .foregroundStyle(isActive ? OPTheme.mint : OPTheme.textSecondary)
                            }
                            .frame(width: 72)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        @Bindable var store = store
        return VStack(alignment: .leading, spacing: 12) {
            Text("Настройки").font(.system(size: 15, weight: .bold)).foregroundStyle(OPTheme.text)

            VStack(alignment: .leading, spacing: 6) {
                Toggle(isOn: $store.vetAcceptsOnlineBooking) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(store.vetAcceptsOnlineBooking ? OPTheme.mint : OPTheme.textTertiary)
                            .frame(width: 20)
                        Text("Приемам онлайн записвания")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(OPTheme.text)
                    }
                }
                .tint(OPTheme.mint)

                if !store.vetAcceptsOnlineBooking {
                    Text("Пациентите ще виждат само телефон за контакт")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                        .padding(.leading, 30)
                }
            }

            Button { showDarkMode = true } label: {
                HStack(spacing: 12) {
                    Image(systemName: "moon.fill").font(.system(size: 14, weight: .semibold)).foregroundStyle(OPTheme.mint)
                        .frame(width: 30, height: 30)
                        .background(OPTheme.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text("Тъмен режим").font(.system(size: 15, weight: .medium)).foregroundStyle(OPTheme.text)
                    Spacer()
                    Text(store.isDarkMode ? "Вкл." : "Изкл.").font(.system(size: 13, weight: .semibold)).foregroundStyle(OPTheme.textSecondary)
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(OPTheme.textTertiary)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }
            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button { showLogoutAlert = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 14))
                Text("Изход").font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(OPTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.dangerSoft.opacity(0.4), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

// MARK: - Vet New Appointment Sheet

struct VetNewAppointmentSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var dogName = ""
    @State private var selectedServiceIndex = 0
    @State private var date = Date().addingTimeInterval(3600)
    @State private var notes = ""

    private var selectedService: VetService? {
        guard !store.vetServices.isEmpty else { return nil }
        return store.vetServices[selectedServiceIndex]
    }

    private var price: Double {
        selectedService?.price ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Dog name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ИМЕ НА КУЧЕТО")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("Напр. Рекс", text: $dogName)
                            .font(.system(size: 16, weight: .medium))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Service picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("УСЛУГА")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)

                        if store.vetServices.isEmpty {
                            Text("Няма добавени услуги. Добави от таб \"Услуги\".")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(OPTheme.textTertiary)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } else {
                            ForEach(Array(store.vetServices.enumerated()), id: \.element.id) { idx, service in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { selectedServiceIndex = idx }
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: selectedServiceIndex == idx ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 18))
                                            .foregroundStyle(selectedServiceIndex == idx ? OPTheme.mint : OPTheme.textTertiary)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(service.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(OPTheme.text)
                                            Text("\(service.duration) · \(Int(service.price)) лв")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundStyle(OPTheme.textSecondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(
                                        selectedServiceIndex == idx ? OPTheme.mintSoft : OPTheme.surfaceSunken,
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(selectedServiceIndex == idx ? OPTheme.mint.opacity(0.4) : Color.clear, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }

                    // Date / time
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ДАТА И ЧАС")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .tint(OPTheme.mint)
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("БЕЛЕЖКИ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("Допълнителна информация...", text: $notes, axis: .vertical)
                            .font(.system(size: 15))
                            .lineLimit(2...4)
                            .padding(12)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Price display
                    HStack {
                        Text("Цена")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                        Spacer()
                        Text("\(Int(price)) лв")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(OPTheme.mint)
                    }
                    .padding(14)
                    .background(OPTheme.mintSoft.opacity(0.3), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    // Submit
                    Button {
                        guard let service = selectedService else { return }
                        let appointment = VetAppointment(
                            id: store.newId(),
                            vetName: "Д-р \(store.ownerName)",
                            clinicName: "Клиника Лапа",
                            serviceName: service.name,
                            dogId: "",
                            dogName: dogName,
                            date: date,
                            notes: notes,
                            status: .upcoming,
                            price: service.price,
                            createdAt: Date()
                        )
                        store.submitVetAppointment(appointment)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Запази час")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.mint.opacity(0.3), radius: 8, y: 4)
                    }
                    .disabled(dogName.isEmpty || store.vetServices.isEmpty)
                    .opacity(dogName.isEmpty || store.vetServices.isEmpty ? 0.5 : 1)
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Нов час")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Затвори") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Vet Complete Appointment Sheet

struct VetCompleteAppointmentSheet: View {
    let appointment: VetAppointment
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var diagnosis = ""
    @State private var prescription = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Appointment info
                    HStack(spacing: 12) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(appointment.serviceName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text(appointment.dogName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                            Text(appointment.date.formatted(.dateTime.day().month(.abbreviated).hour().minute()))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textTertiary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))

                    // Diagnosis
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Диагноза", systemImage: "list.clipboard.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        TextField("Напр. Лек гастрит, здрав...", text: $diagnosis, axis: .vertical)
                            .font(.system(size: 15))
                            .lineLimit(2...5)
                            .padding(12)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Prescription
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Рецепта", systemImage: "pills.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        TextField("Напр. Carprofen 50mg 2x дневно, 5 дни...", text: $prescription, axis: .vertical)
                            .font(.system(size: 15))
                            .lineLimit(2...5)
                            .padding(12)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Submit
                    Button {
                        store.completeVetAppointment(
                            id: appointment.id,
                            diagnosis: diagnosis.isEmpty ? nil : diagnosis,
                            prescription: prescription.isEmpty ? nil : prescription
                        )
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Завърши и запиши")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.mint.opacity(0.3), radius: 8, y: 4)
                    }
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Завършване на преглед")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
        }
    }
}
