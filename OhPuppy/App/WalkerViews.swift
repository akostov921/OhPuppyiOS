import SwiftUI

// MARK: - Walker Tab View

struct WalkerTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                NavigationStack { WalkerHomeView() }
            } label: {
                Label("Начало", systemImage: selectedTab == 0 ? "figure.walk.circle.fill" : "figure.walk.circle")
            }
            Tab(value: 1) {
                NavigationStack { MapView() }
            } label: {
                Label("Карта", systemImage: selectedTab == 1 ? "map.fill" : "map")
            }
            Tab(value: 2) {
                NavigationStack { WalkerRequestsView() }
            } label: {
                Label("Заявки", systemImage: selectedTab == 2 ? "tray.fill" : "tray")
            }
            Tab(value: 3) {
                NavigationStack { WalkerEarningsView() }
            } label: {
                Label("Приходи", systemImage: selectedTab == 3 ? "banknote.fill" : "banknote")
            }
            Tab(value: 4) {
                NavigationStack { WalkerSettingsView() }
            } label: {
                Label("Профил", systemImage: selectedTab == 4 ? "person.fill" : "person")
            }
        }
        .tint(OPTheme.primary)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

// MARK: - Walker Home View

struct WalkerHomeView: View {
    @Environment(AppStore.self) private var store

    private var todayWalks: [WalkRequest] {
        let cal = Calendar.current
        return store.walkRequests.filter { req in
            req.status == .accepted && cal.isDateInToday(req.date)
        }
    }

    private var todayEarnings: Double {
        let cal = Calendar.current
        return store.walkerEarnings.filter { cal.isDateInToday($0.date) }.reduce(0) { $0 + $1.amount }
    }

    private var todayWalkCount: Int {
        let cal = Calendar.current
        return store.walkRequests.filter { req in
            (req.status == .completed || req.status == .confirmed) && cal.isDateInToday(req.date)
        }.count
    }

    private var averageRating: Double {
        guard !store.walkerReviews.isEmpty else { return 0 }
        return Double(store.walkerReviews.reduce(0) { $0 + $1.rating }) / Double(store.walkerReviews.count)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                DashboardRoleSwitcher()
                headerCard
                activeWalkCard
                quickStatsRow
                pointsProgressCard
                badgeShelf
                recentReviewsSection
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(store.ownerName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 6) {
                    Image(systemName: store.currentWalkerBadge.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(OPTheme.accent)
                    Text(store.currentWalkerBadge.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(OPTheme.accent)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.sky.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Active Walk

    @ViewBuilder
    private var activeWalkCard: some View {
        if let walk = todayWalks.first {
            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                    Text("АКТИВНА РАЗХОДКА")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(.white)
                        .tracking(0.5)
                    Spacer()
                    Text(walk.date.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                }

                HStack(spacing: 14) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(walk.dogName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        Text("\(walk.duration) мин · \(String(format: "%.0f лв", walk.price))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                }

                if !walk.note.isEmpty {
                    Text(walk.note)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(18)
            .background(
                LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .shadow(color: OPTheme.sky.opacity(0.3), radius: 12, y: 6)
        }
    }

    // MARK: - Quick Stats

    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            walkerStat(value: "\(todayWalkCount)", label: "Разходки днес", color: OPTheme.sky)
            walkerStat(value: String(format: "%.0f лв", todayEarnings), label: "Печалба днес", color: OPTheme.mint)
            walkerStat(value: "\(store.walkerPoints)", label: "Точки", color: OPTheme.accent)
        }
    }

    private func walkerStat(value: String, label: String, color: Color) -> some View {
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

    // MARK: - Points + Badge Progress

    private var pointsProgressCard: some View {
        VStack(spacing: 12) {
            Text("\(store.walkerPoints)")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing)
                )
            Text("точки")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(OPTheme.textSecondary)

            if let next = store.nextWalkerBadge {
                GeometryReader { geo in
                    let currentMin = store.currentWalkerBadge.minPoints
                    let nextMin = next.minPoints
                    let range = max(1, nextMin - currentMin)
                    let progress = Double(store.walkerPoints - currentMin) / Double(range)
                    ZStack(alignment: .leading) {
                        Capsule().fill(OPTheme.surfaceSunken).frame(height: 10)
                        Capsule()
                            .fill(LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(10, geo.size.width * progress), height: 10)
                    }
                }
                .frame(height: 10)

                Text("Още \(next.minPoints - store.walkerPoints) точки до \(next.label)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
            } else {
                Text("Максимално ниво достигнато!")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(OPTheme.accent)
            }
        }
        .padding(20)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Badge Shelf

    private var badgeShelf: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Нива")
            HStack(spacing: 0) {
                ForEach(WalkerBadge.allCases, id: \.self) { badge in
                    let isEarned = store.walkerPoints >= badge.minPoints
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(isEarned ? OPTheme.sky.opacity(0.15) : OPTheme.surfaceSunken)
                                .frame(width: 44, height: 44)
                            Image(systemName: badge.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(isEarned ? OPTheme.sky : OPTheme.textTertiary)
                        }
                        Text(badge.label)
                            .font(.system(size: 9, weight: isEarned ? .bold : .medium))
                            .foregroundStyle(isEarned ? OPTheme.text : OPTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Recent Reviews

    private var recentReviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            OPSectionHeader(title: "Последни ревюта")
            let topReviews = Array(store.walkerReviews.sorted { $0.date > $1.date }.prefix(3))
            if topReviews.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 20))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Все още няма ревюта")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                ForEach(topReviews) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(review.clientName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("за \(review.dogName)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(OPTheme.textTertiary)
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: i <= review.rating ? "star.fill" : "star")
                                        .font(.system(size: 10))
                                        .foregroundStyle(i <= review.rating ? OPTheme.warning : OPTheme.textTertiary)
                                }
                            }
                        }
                        Text(review.comment)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                        Text(review.date.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                    .padding(12)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
                }
            }
        }
    }
}

// MARK: - Walker Requests View

struct WalkerRequestsView: View {
    @Environment(AppStore.self) private var store

    enum RequestSegment: String, CaseIterable {
        case new = "Нови"
        case active = "Активни"
        case history = "История"
    }

    @State private var segment: RequestSegment = .new

    private var newRequests: [WalkRequest] {
        store.walkRequests.filter { $0.status == .pending }
    }

    private var activeRequests: [WalkRequest] {
        store.walkRequests.filter { $0.status == .accepted || $0.status == .inProgress }
    }

    private var historyRequests: [WalkRequest] {
        store.walkRequests
            .filter { $0.status == .completed || $0.status == .confirmed }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Segmented Picker
                Picker("Сегмент", selection: $segment) {
                    ForEach(RequestSegment.allCases, id: \.self) { seg in
                        Text(seg.rawValue).tag(seg)
                    }
                }
                .pickerStyle(.segmented)

                // Content per segment
                switch segment {
                case .new:
                    newRequestsContent
                case .active:
                    activeRequestsContent
                case .history:
                    historyContent
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Заявки")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - New Requests

    @ViewBuilder
    private var newRequestsContent: some View {
        if newRequests.isEmpty {
            walkerEmptyState(icon: "tray", text: "Няма нови заявки")
        } else {
            ForEach(newRequests) { req in
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(OPTheme.sky)
                            .frame(width: 40, height: 40)
                            .background(OPTheme.skySoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(req.dogName)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("\(req.duration) мин · \(req.date.formatted(.dateTime.day().month(.abbreviated).hour().minute()))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }

                        Spacer()

                        Text(String(format: "%.0f лв", req.price))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(OPTheme.mint)
                    }

                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                                .tint(OPTheme.warning)
                            Text("Изчакване...")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(OPTheme.warning)
                        }
                    }
                }
                .padding(14)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
            }
        }
    }

    // MARK: - Active Requests

    @ViewBuilder
    private var activeRequestsContent: some View {
        if activeRequests.isEmpty {
            walkerEmptyState(icon: "figure.walk", text: "Няма активни разходки")
        } else {
            ForEach(activeRequests) { req in
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(OPTheme.mint)
                            .frame(width: 40, height: 40)
                            .background(OPTheme.mintSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(req.dogName)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("\(req.duration) мин · \(req.date.formatted(.dateTime.day().month(.abbreviated).hour().minute()))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }

                        Spacer()

                        Text(String(format: "%.0f лв", req.price))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(OPTheme.mint)
                    }

                    if !req.note.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "note.text")
                                .font(.system(size: 11))
                                .foregroundStyle(OPTheme.textTertiary)
                            Text(req.note)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        withAnimation(OPTheme.quickSpring) {
                            store.completeWalk(id: req.id)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Завърши разходка")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(14)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
            }
        }
    }

    // MARK: - History

    @ViewBuilder
    private var historyContent: some View {
        if historyRequests.isEmpty {
            walkerEmptyState(icon: "clock", text: "Все още няма завършени разходки")
        } else {
            ForEach(historyRequests) { req in
                HStack(spacing: 12) {
                    VStack(spacing: 2) {
                        Text(req.date.formatted(.dateTime.day()))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(req.status == .confirmed ? OPTheme.success : OPTheme.sky)
                        Text(req.date.formatted(.dateTime.month(.abbreviated)))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    .frame(width: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(req.dogName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("\(req.duration) мин · \(req.date.formatted(.dateTime.hour().minute()))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.0f лв", req.price))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        HStack(spacing: 4) {
                            if req.status == .confirmed {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(OPTheme.success)
                            }
                            Text(req.status.label)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(req.status == .confirmed ? OPTheme.success : OPTheme.sky)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            (req.status == .confirmed ? OPTheme.success : OPTheme.sky).opacity(0.12),
                            in: Capsule()
                        )
                    }
                }
                .padding(12)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
            }
        }
    }

    // MARK: - Empty State

    private func walkerEmptyState(icon: String, text: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(OPTheme.textTertiary)
                .symbolEffect(.wiggle.byLayer)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Walker Earnings View

struct WalkerEarningsView: View {
    @Environment(AppStore.self) private var store

    enum EarningsPeriod: String, CaseIterable {
        case today = "Днес"
        case week = "Седмица"
        case month = "Месец"
        case all = "Всичко"
    }

    @State private var period: EarningsPeriod = .all
    @State private var showWithdrawSuccess = false

    private var filteredEarnings: [WalkerEarning] {
        let cal = Calendar.current
        let now = Date()
        return store.walkerEarnings
            .filter { earning in
                switch period {
                case .today:
                    return cal.isDateInToday(earning.date)
                case .week:
                    guard let weekAgo = cal.date(byAdding: .day, value: -7, to: now) else { return true }
                    return earning.date >= weekAgo
                case .month:
                    guard let monthAgo = cal.date(byAdding: .month, value: -1, to: now) else { return true }
                    return earning.date >= monthAgo
                case .all:
                    return true
                }
            }
            .sorted { $0.date > $1.date }
    }

    private var filteredTotal: Double {
        filteredEarnings.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Period Picker
                Picker("Период", selection: $period) {
                    ForEach(EarningsPeriod.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)

                // Big Earnings Display
                bigEarningsCard

                // Stat Boxes
                earningsStatBoxes

                // Withdraw Button
                withdrawButton

                // Transaction History
                transactionHistory
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Приходи")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Парите са преведени!", isPresented: $showWithdrawSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Наличната сума е преведена по картата ви.")
        }
    }

    // MARK: - Big Earnings

    private var bigEarningsCard: some View {
        VStack(spacing: 4) {
            Text("Общо приходи")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
            Text(String(format: "%.2f лв", filteredTotal))
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text(period.rawValue.lowercased())
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .shadow(color: OPTheme.sky.opacity(0.25), radius: 12, y: 6)
    }

    // MARK: - Stat Boxes

    private var earningsStatBoxes: some View {
        HStack(spacing: 10) {
            earningBox(
                value: String(format: "%.0f лв", store.walkerTotalEarned),
                label: "Общо",
                color: OPTheme.success,
                bgColor: OPTheme.successSoft
            )
            earningBox(
                value: String(format: "%.0f лв", store.walkerPendingEarnings),
                label: "Задържани",
                color: OPTheme.warning,
                bgColor: OPTheme.warningSoft
            )
            earningBox(
                value: String(format: "%.0f лв", store.walkerAvailableEarnings),
                label: "Налични",
                color: OPTheme.mint,
                bgColor: OPTheme.mintSoft.opacity(0.5)
            )
        }
    }

    private func earningBox(value: String, label: String, color: Color, bgColor: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(bgColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(color.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Withdraw

    @ViewBuilder
    private var withdrawButton: some View {
        Button {
            store.withdrawEarnings()
            showWithdrawSuccess = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 15))
                Text("Изтегли към картата")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(store.walkerAvailableEarnings <= 0)
        .opacity(store.walkerAvailableEarnings <= 0 ? 0.45 : 1)
    }

    // MARK: - Transaction History

    private var transactionHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            OPSectionHeader(title: "История на транзакции")

            if filteredEarnings.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 20))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Няма транзакции за периода")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                ForEach(filteredEarnings) { earning in
                    HStack(spacing: 12) {
                        earningStatusIcon(earning.status)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(earning.clientName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("\(earning.dogName) · \(earning.date.formatted(.dateTime.day().month(.abbreviated)))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: "%.0f лв", earning.amount))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            earningStatusBadge(earning.status)
                        }
                    }
                    .padding(14)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
                }
            }
        }
    }

    private func earningStatusIcon(_ status: EarningStatus) -> some View {
        let config: (icon: String, color: Color, bg: Color) = switch status {
        case .held: ("clock.fill", OPTheme.warning, OPTheme.warningSoft)
        case .available: ("checkmark.circle.fill", OPTheme.mint, OPTheme.mintSoft)
        case .withdrawn: ("arrow.down.circle.fill", OPTheme.textTertiary, OPTheme.surfaceSunken)
        }
        return Image(systemName: config.icon)
            .font(.system(size: 16))
            .foregroundStyle(config.color)
            .frame(width: 36, height: 36)
            .background(config.bg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func earningStatusBadge(_ status: EarningStatus) -> some View {
        let color: Color = switch status {
        case .held: OPTheme.warning
        case .available: OPTheme.mint
        case .withdrawn: OPTheme.textTertiary
        }
        return Text(status.label)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Walker Settings View

struct WalkerSettingsView: View {
    @Environment(AppStore.self) private var store
    @State private var showLogoutAlert = false

    private var averageRating: Double {
        guard !store.walkerReviews.isEmpty else { return 0 }
        return Double(store.walkerReviews.reduce(0) { $0 + $1.rating }) / Double(store.walkerReviews.count)
    }

    private let days = ["Пон", "Вт", "Ср", "Чет", "Пет", "Съб", "Нед"]
    private let slots = ["Сутрин", "Обяд", "Вечер"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                profileHeader
                availabilityGrid
                servicesSection
                priceSection
                roleSwitcher
                darkModeToggle
                logoutButton
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Профил")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Изход от профила", isPresented: $showLogoutAlert) {
            Button("Отмени", role: .cancel) {}
            Button("Излез", role: .destructive) { store.signOut() }
        } message: {
            Text("Сигурни ли сте, че искате да излезете?")
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                }

            Text(store.ownerName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(OPTheme.text)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: store.currentWalkerBadge.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(OPTheme.accent)
                    Text(store.currentWalkerBadge.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(OPTheme.accent)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(OPTheme.accentSoft, in: Capsule())

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(OPTheme.warning)
                    Text(String(format: "%.1f", averageRating))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(OPTheme.warningSoft, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Availability Grid

    private var availabilityGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            OPSectionHeader(title: "График на наличност")

            VStack(spacing: 6) {
                // Header row
                HStack(spacing: 4) {
                    Text("")
                        .frame(width: 50)
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Slot rows
                ForEach(slots, id: \.self) { slot in
                    HStack(spacing: 4) {
                        Text(slot)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .frame(width: 50, alignment: .leading)
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let isAvailable = mockAvailability(slot: slot, day: dayIndex)
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(isAvailable ? OPTheme.mint.opacity(0.25) : OPTheme.surfaceSunken)
                                .frame(maxWidth: .infinity, minHeight: 28)
                                .overlay {
                                    if isAvailable {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(OPTheme.mint)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private func mockAvailability(slot: String, day: Int) -> Bool {
        // Mock schedule: weekdays mornings/evenings, weekends all day
        if day >= 5 { return true } // weekends
        return slot == "Сутрин" || slot == "Вечер"
    }

    // MARK: - Services

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            OPSectionHeader(title: "Предлагани услуги")

            ForEach(WalkerApplication.ServiceType.allCases, id: \.self) { service in
                let isOffered = store.walkerApplication?.services.contains(service) ?? (service == .walking)
                HStack(spacing: 12) {
                    Image(systemName: service.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isOffered ? OPTheme.mint : OPTheme.textTertiary)
                        .frame(width: 34, height: 34)
                        .background(
                            isOffered ? OPTheme.mintSoft : OPTheme.surfaceSunken,
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                        )

                    Text(service.label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isOffered ? OPTheme.text : OPTheme.textTertiary)

                    Spacer()

                    Image(systemName: isOffered ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundStyle(isOffered ? OPTheme.mint : OPTheme.textTertiary)
                }
                .padding(12)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
            }
        }
    }

    // MARK: - Price

    private var priceSection: some View {
        HStack(spacing: 14) {
            Image(systemName: "banknote.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(OPTheme.mint)
                .frame(width: 40, height: 40)
                .background(OPTheme.mintSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("Цена за разходка")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                Text("30 минути")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()

            Text(String(format: "%.0f лв", store.walkerApplication?.pricePerWalk ?? 25.0))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(OPTheme.mint)
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Role Switcher

    private var roleSwitcher: some View {
        let availableRoles: [UserRole] = [.owner] + store.registeredRoles.sorted(by: { $0.rawValue < $1.rawValue })
        return Menu {
            ForEach(availableRoles, id: \.self) { role in
                Button {
                    withAnimation(OPTheme.quickSpring) { store.activeRole = role }
                } label: {
                    Label(role.label, systemImage: role.icon)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(OPTheme.primary)
                    .frame(width: 36, height: 36)
                    .background(OPTheme.primarySoft, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text("Смени роля")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(OPTheme.text)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: store.activeRole.icon)
                        .font(.system(size: 11, weight: .bold))
                    Text(store.activeRole.label)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(OPTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(OPTheme.primarySoft, in: Capsule())
            }
            .padding(14)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Dark Mode

    private var darkModeToggle: some View {
        @Bindable var store = store
        return HStack(spacing: 12) {
            Image(systemName: store.isDarkMode ? "moon.fill" : "sun.max.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(store.isDarkMode ? OPTheme.sky : OPTheme.accent)
                .frame(width: 36, height: 36)
                .background(
                    (store.isDarkMode ? OPTheme.skySoft : OPTheme.accentSoft),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )

            Text("Тъмен режим")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(OPTheme.text)

            Spacer()

            Toggle("", isOn: $store.isDarkMode)
                .labelsHidden()
                .tint(OPTheme.mint)
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            showLogoutAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                Text("Излез от профила")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(OPTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(OPTheme.dangerSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.danger.opacity(0.2), lineWidth: 1))
        }
    }
}
