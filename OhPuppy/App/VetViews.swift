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

    private var uniquePatientCount: Int {
        Set(store.vetAppointments.map { $0.dogName }).count
    }

    /// Computed vet rating based on completed appointments count.
    /// No review system exists yet, so we derive a score from activity.
    private var vetRating: String {
        let completed = store.vetAppointments.filter { $0.status == .completed }.count
        let rating = min(5.0, 4.0 + Double(completed) * 0.1)
        return String(format: "%.1f", rating)
    }

    private var todayAppointments: [VetAppointment] {
        let cal = Calendar.current
        return store.vetAppointments.filter { cal.isDateInToday($0.date) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                DashboardRoleSwitcher()

                // Header card
                headerCard

                // Stats row
                statsRow

                // Today's appointments
                todaySection

                // Quick actions
                quickActions
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddService) { AddVetServiceSheet() }
        .sheet(isPresented: $showAddAppointment) { VetNewAppointmentSheet() }
        .alert("Верификация на ваксини", isPresented: $showVerifyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Функцията ще бъде налична скоро.")
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(OPTheme.mintGradient)
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text("Д-р \(store.ownerName)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 6) {
                    Circle().fill(OPTheme.success).frame(width: 8, height: 8)
                    Text("Активна клиника")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(OPTheme.success)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.mint.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 10) {
            vetStatBox(value: "\(store.vetServices.count)", label: "Услуги", color: OPTheme.mint)
            vetStatBox(value: "\(uniquePatientCount)", label: "Пациенти", color: OPTheme.sky)
            vetStatBox(value: vetRating, label: "Рейтинг", color: OPTheme.accent)
        }
    }

    private func vetStatBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
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
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text(appt.date.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.mint)
                        }
                        .frame(width: 52)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(appt.serviceName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("\(appt.dogName)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("\(Int(appt.price)) лв")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.mint)

                            appointmentStatusBadge(appt.status)
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

            HStack(spacing: 12) {
                Button {
                    showAddAppointment = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Нов час")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                Button {
                    showAddService = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Добави услуга")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(OPTheme.mint)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.mint.opacity(0.4), lineWidth: 1.5))
                }
            }

            Button {
                showVerifyAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Верифицирай ваксини")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(OPTheme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.accent.opacity(0.4), lineWidth: 1.5))
            }
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
                        withAnimation(OPTheme.quickSpring) {
                            if let i = store.vetAppointments.firstIndex(where: { $0.id == appt.id }) {
                                store.vetAppointments[i].status = .completed
                                store.save()
                            }
                        }
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

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Profile header
                profileHeader

                // Clinic info
                clinicInfoCard

                // Working hours
                workingHoursCard

                // Role switcher
                roleSwitchSection

                // Preferences
                preferencesSection

                // Logout
                logoutButton
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Профил")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(OPTheme.mintGradient)
                    .frame(width: 80, height: 80)
                Image(systemName: "stethoscope")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 4) {
                Text("Д-р \(store.ownerName)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("Ветеринарна клиника Лапа")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            HStack(spacing: 6) {
                Circle().fill(OPTheme.success).frame(width: 8, height: 8)
                Text("Активен профил")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(OPTheme.success)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(OPTheme.successSoft, in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.mint.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Clinic Info

    private var clinicInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.mint)
                Text("Информация за клиниката")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }

            VStack(spacing: 8) {
                infoRow(icon: "mappin.circle.fill", label: "Адрес", value: "ул. Цар Борис III 120, София")
                infoRow(icon: "phone.fill", label: "Телефон", value: "+359 88 123 4567")
                infoRow(icon: "envelope.fill", label: "Имейл", value: store.ownerEmail.isEmpty ? "clinic@ohpuppy.bg" : store.ownerEmail)
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(OPTheme.textTertiary)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(OPTheme.text)
                .lineLimit(1)
        }
    }

    // MARK: - Working Hours

    private var workingHoursCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.accent)
                Text("Работно време")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }

            VStack(spacing: 8) {
                workingHoursRow(days: "Понеделник - Петък", hours: "09:00 - 18:00", isActive: true)
                workingHoursRow(days: "Събота", hours: "10:00 - 14:00", isActive: true)
                workingHoursRow(days: "Неделя", hours: "Почивен ден", isActive: false)
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private func workingHoursRow(days: String, hours: String, isActive: Bool) -> some View {
        HStack {
            Text(days)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.text)
            Spacer()
            Text(hours)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isActive ? OPTheme.mint : OPTheme.textTertiary)
        }
    }

    // MARK: - Role Switcher

    private var roleSwitchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.sky)
                Text("Смяна на роля")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }

            let availableRoles: [UserRole] = [.owner] + store.registeredRoles.sorted(by: { $0.rawValue < $1.rawValue })

            Menu {
                ForEach(availableRoles, id: \.self) { role in
                    Button {
                        withAnimation(OPTheme.quickSpring) { store.activeRole = role }
                    } label: {
                        Label(role.label, systemImage: role.icon)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: store.activeRole.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(OPTheme.primary)
                    Text(store.activeRole.label)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textTertiary)
                }
                .padding(14)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        @Bindable var store = store
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.textSecondary)
                Text("Настройки")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
            }

            Toggle(isOn: $store.isDarkMode) {
                HStack(spacing: 10) {
                    Image(systemName: store.isDarkMode ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(store.isDarkMode ? OPTheme.accent : OPTheme.warning)
                        .frame(width: 20)
                    Text("Тъмен режим")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(OPTheme.text)
                }
            }
            .tint(OPTheme.mint)
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            store.signOut()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                Text("Изход")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(OPTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(OPTheme.dangerSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.danger.opacity(0.2), lineWidth: 1))
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
