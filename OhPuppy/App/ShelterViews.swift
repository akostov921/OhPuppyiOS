import SwiftUI

// MARK: - Shelter Tab View

struct ShelterTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                NavigationStack { ShelterHomeView() }
            } label: {
                Label("Начало", systemImage: selectedTab == 0 ? "building.2.fill" : "building.2")
            }
            Tab(value: 1) {
                NavigationStack { ShelterAnimalsView() }
            } label: {
                Label("Кучета", systemImage: selectedTab == 1 ? "pawprint.fill" : "pawprint")
            }
            Tab(value: 2) {
                NavigationStack { ShelterAdoptionView() }
            } label: {
                Label("Заявки", systemImage: selectedTab == 2 ? "heart.text.square.fill" : "heart.text.square")
            }
            Tab(value: 3) {
                NavigationStack { ShelterSettingsView() }
            } label: {
                Label("Профил", systemImage: selectedTab == 3 ? "person.fill" : "person")
            }
        }
        .tint(OPTheme.rose)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

// MARK: - Shelter Home View (Dashboard)

struct ShelterHomeView: View {
    @Environment(AppStore.self) private var store
    @State private var showAddAnimal = false

    private let shelterGradient = LinearGradient(
        colors: [OPTheme.rose, OPTheme.accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private var availableCount: Int {
        store.shelterAnimals.filter { !$0.isAdopted }.count
    }

    private var adoptedCount: Int {
        store.shelterAnimals.filter { $0.isAdopted }.count
    }

    private var monthlyDonationSum: Double {
        let cal = Calendar.current
        let now = Date()
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
        return store.shelterDonations
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }

    private var donationGoal: Double { 500 }

    private var pendingRequestsCount: Int {
        store.adoptionRequests.filter { $0.status == .pending }.count
    }

    private var recentDonations: [Donation] {
        Array(store.shelterDonations.sorted { $0.date > $1.date }.prefix(3))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                DashboardRoleSwitcher()
                headerCard
                statsRow
                donationProgressCard
                newRequestsBadge
                recentDonationsSection
                quickActions
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddAnimal) { AddShelterAnimalSheet() }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(shelterGradient)
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text("Приют \(store.ownerName)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(OPTheme.rose)
                    Text("\(store.shelterAnimals.count) кучета")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.rose.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 10) {
            shelterStat(value: "\(availableCount)", label: "Налични", color: OPTheme.rose, bg: OPTheme.roseSoft)
            shelterStat(value: "\(adoptedCount)", label: "Осиновени", color: OPTheme.success, bg: OPTheme.successSoft)
            shelterStat(value: String(format: "%.0f лв", monthlyDonationSum), label: "Дарения/мес", color: OPTheme.accent, bg: OPTheme.accentSoft)
        }
    }

    private func shelterStat(value: String, label: String, color: Color, bg: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(bg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Donation Progress

    private var donationProgressCard: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(OPTheme.rose)
                Text("Месечна цел за дарения")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Spacer()
            }
            GeometryReader { geo in
                let progress = min(monthlyDonationSum / donationGoal, 1.0)
                ZStack(alignment: .leading) {
                    Capsule().fill(OPTheme.surfaceSunken).frame(height: 8)
                    Capsule()
                        .fill(shelterGradient)
                        .frame(width: max(8, geo.size.width * progress), height: 8)
                }
            }
            .frame(height: 8)
            Text("\(String(format: "%.0f", monthlyDonationSum)) / \(String(format: "%.0f", donationGoal)) лв")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Pending Requests Badge

    @ViewBuilder
    private var newRequestsBadge: some View {
        if pendingRequestsCount > 0 {
            HStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(OPTheme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(pendingRequestsCount) нови заявки за осиновяване")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Изчакват вашето решение")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                Spacer()
                Text("\(pendingRequestsCount)")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(OPTheme.rose, in: Circle())
            }
            .padding(14)
            .background(OPTheme.accentSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.accent.opacity(0.3), lineWidth: 1))
        }
    }

    // MARK: - Recent Donations

    private var recentDonationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Последни дарения")

            if recentDonations.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Все още няма дарения")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                ForEach(recentDonations) { donation in
                    HStack(spacing: 12) {
                        Image(systemName: donation.isRecurring ? "arrow.triangle.2.circlepath" : "heart.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                donation.isRecurring
                                    ? AnyShapeStyle(OPTheme.accent)
                                    : AnyShapeStyle(OPTheme.rose),
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(donation.donorName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text(donation.date.formatted(.dateTime.day().month(.abbreviated)))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("\(String(format: "%.0f", donation.amount)) лв")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.rose)
                            if donation.isRecurring {
                                Text("Месечно")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(OPTheme.accent)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(OPTheme.accentSoft, in: Capsule())
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
        HStack(spacing: 12) {
            Button {
                showAddAnimal = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Добави куче")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(shelterGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            NavigationLink {
                ShelterAdoptionView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 16))
                    Text("Виж заявки")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(OPTheme.rose)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(OPTheme.roseSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.rose.opacity(0.3), lineWidth: 1))
            }
        }
    }
}

// MARK: - Shelter Animals View

struct ShelterAnimalsView: View {
    @Environment(AppStore.self) private var store
    @State private var showAddAnimal = false
    @State private var selectedFilter: AnimalFilter = .all
    @State private var expandedAnimalId: String?

    private enum AnimalFilter: String, CaseIterable {
        case all = "Всички"
        case available = "Налични"
        case adopted = "Осиновени"
    }

    private var filteredAnimals: [ShelterAnimal] {
        switch selectedFilter {
        case .all: return store.shelterAnimals
        case .available: return store.shelterAnimals.filter { !$0.isAdopted }
        case .adopted: return store.shelterAnimals.filter { $0.isAdopted }
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Filter chips
                filterChips
                    .padding(.horizontal, OPTheme.screenPadding)

                if filteredAnimals.isEmpty {
                    emptyState
                        .padding(.horizontal, OPTheme.screenPadding)
                        .padding(.top, 40)
                } else {
                    // Animal grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(filteredAnimals) { animal in
                            animalCard(animal)
                        }
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                }
            }
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Кучета")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddAnimal = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(OPTheme.rose)
                }
            }
        }
        .sheet(isPresented: $showAddAnimal) { AddShelterAnimalSheet() }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        HStack(spacing: 8) {
            ForEach(AnimalFilter.allCases, id: \.self) { filter in
                let isActive = selectedFilter == filter
                Button {
                    withAnimation(OPTheme.quickSpring) { selectedFilter = filter }
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 13, weight: isActive ? .bold : .medium))
                        .foregroundStyle(isActive ? .white : OPTheme.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            isActive
                                ? AnyShapeStyle(LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing))
                                : AnyShapeStyle(OPTheme.surfaceSunken),
                            in: Capsule()
                        )
                }
            }
            Spacer()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 44))
                .foregroundStyle(OPTheme.textTertiary)
                .symbolEffect(.wiggle.byLayer)
            Text(selectedFilter == .all ? "Няма добавени кучета" : selectedFilter == .available ? "Няма налични кучета" : "Няма осиновени кучета")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text("Добавете ново куче с бутона +")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Animal Card

    private func animalCard(_ animal: ShelterAnimal) -> some View {
        let isExpanded = expandedAnimalId == animal.id

        return VStack(spacing: 0) {
            // Photo
            AsyncImage(url: animal.photoURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default:
                    Rectangle().fill(OPTheme.surfaceSunken)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(OPTheme.rose.opacity(0.4))
                        }
                }
            }
            .frame(height: 120)
            .clipped()

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(animal.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Spacer()
                    if animal.isAdopted {
                        Text("Осиновен")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(OPTheme.success)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(OPTheme.successSoft, in: Capsule())
                    } else {
                        Text("Търси дом")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(OPTheme.rose)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(OPTheme.roseSoft, in: Capsule())
                    }
                }
                Text("\(animal.breed) · \(animal.age)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(animal.sex.icon)
                        .font(.system(size: 11))
                    Text(animal.sex == .male ? "Мъжки" : "Женски")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }

                // Expanded description
                if isExpanded {
                    Text(animal.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(OPTheme.textSecondary)
                        .lineSpacing(2)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(10)
        }
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        .onTapGesture {
            withAnimation(OPTheme.quickSpring) {
                expandedAnimalId = isExpanded ? nil : animal.id
            }
        }
        .contextMenu {
            Button {
                withAnimation(OPTheme.quickSpring) {
                    toggleAdoptionStatus(animal)
                }
            } label: {
                Label(
                    animal.isAdopted ? "Маркирай като наличен" : "Маркирай като осиновен",
                    systemImage: animal.isAdopted ? "arrow.uturn.backward" : "checkmark.circle.fill"
                )
            }
            Button(role: .destructive) {
                withAnimation(OPTheme.quickSpring) {
                    store.removeShelterAnimal(id: animal.id)
                }
            } label: {
                Label("Премахни", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button {
                withAnimation(OPTheme.quickSpring) {
                    toggleAdoptionStatus(animal)
                }
            } label: {
                Label(
                    animal.isAdopted ? "Наличен" : "Осиновен",
                    systemImage: animal.isAdopted ? "arrow.uturn.backward" : "checkmark.circle.fill"
                )
            }
            .tint(animal.isAdopted ? OPTheme.accent : OPTheme.success)
        }
    }

    private func toggleAdoptionStatus(_ animal: ShelterAnimal) {
        if let i = store.shelterAnimals.firstIndex(where: { $0.id == animal.id }) {
            store.shelterAnimals[i].isAdopted.toggle()
            store.save()
        }
    }
}

// MARK: - Shelter Adoption View

struct ShelterAdoptionView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedFilter: RequestFilter = .pending

    private enum RequestFilter: String, CaseIterable {
        case pending = "Нови"
        case approved = "Одобрени"
        case rejected = "Отказани"

        var status: AdoptionRequestStatus {
            switch self {
            case .pending: .pending
            case .approved: .approved
            case .rejected: .rejected
            }
        }
    }

    private var filteredRequests: [AdoptionRequest] {
        store.adoptionRequests
            .filter { $0.status == selectedFilter.status }
            .sorted { $0.submittedAt > $1.submittedAt }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Filter chips
                filterChips
                    .padding(.horizontal, OPTheme.screenPadding)

                if filteredRequests.isEmpty {
                    emptyState
                        .padding(.horizontal, OPTheme.screenPadding)
                        .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRequests) { request in
                            requestCard(request)
                        }
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                }
            }
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Заявки за осиновяване")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        HStack(spacing: 8) {
            ForEach(RequestFilter.allCases, id: \.self) { filter in
                let isActive = selectedFilter == filter
                let count = store.adoptionRequests.filter { $0.status == filter.status }.count
                Button {
                    withAnimation(OPTheme.quickSpring) { selectedFilter = filter }
                } label: {
                    HStack(spacing: 4) {
                        Text(filter.rawValue)
                            .font(.system(size: 13, weight: isActive ? .bold : .medium))
                        if count > 0 {
                            Text("\(count)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(isActive ? .white.opacity(0.8) : OPTheme.textTertiary)
                        }
                    }
                    .foregroundStyle(isActive ? .white : OPTheme.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        isActive
                            ? AnyShapeStyle(LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(OPTheme.surfaceSunken),
                        in: Capsule()
                    )
                }
            }
            Spacer()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: emptyIcon)
                .font(.system(size: 44))
                .foregroundStyle(OPTheme.textTertiary)
                .symbolEffect(.wiggle.byLayer)
            Text(emptyTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text(emptySubtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var emptyIcon: String {
        switch selectedFilter {
        case .pending: "tray"
        case .approved: "checkmark.circle"
        case .rejected: "xmark.circle"
        }
    }

    private var emptyTitle: String {
        switch selectedFilter {
        case .pending: "Няма нови заявки"
        case .approved: "Няма одобрени заявки"
        case .rejected: "Няма отказани заявки"
        }
    }

    private var emptySubtitle: String {
        switch selectedFilter {
        case .pending: "Когато получите заявка за осиновяване, тя ще се появи тук."
        case .approved: "Одобрените заявки ще се покажат тук."
        case .rejected: "Отказаните заявки ще се покажат тук."
        }
    }

    // MARK: - Request Card

    private func requestCard(_ request: AdoptionRequest) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(OPTheme.rose)
                VStack(alignment: .leading, spacing: 2) {
                    Text(request.requesterName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 10))
                        Text(request.requesterPhone)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(OPTheme.textSecondary)
                }
                Spacer()
                statusBadge(request.status)
            }

            // Animal info
            HStack(spacing: 8) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(OPTheme.accent)
                Text("За: \(request.animalName)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                Spacer()
                Text(request.submittedAt.formatted(.dateTime.day().month(.abbreviated).hour().minute()))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
            }

            // Note
            if !request.requesterNote.isEmpty {
                Text(request.requesterNote)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineSpacing(2)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            // Action buttons for pending
            if request.status == .pending {
                HStack(spacing: 10) {
                    Button {
                        withAnimation(OPTheme.quickSpring) {
                            store.approveAdoptionRequest(id: request.id)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Одобри")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(OPTheme.success, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Button {
                        withAnimation(OPTheme.quickSpring) {
                            store.rejectAdoptionRequest(id: request.id)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Откажи")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(OPTheme.danger, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private func statusBadge(_ status: AdoptionRequestStatus) -> some View {
        let color: Color = switch status {
        case .pending: OPTheme.accent
        case .approved: OPTheme.success
        case .rejected: OPTheme.danger
        }
        return Text(status.label)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Shelter Settings View

struct ShelterSettingsView: View {
    @Environment(AppStore.self) private var store

    private var adoptedCount: Int {
        store.shelterAnimals.filter { $0.isAdopted }.count
    }

    private var monthlyDonationSum: Double {
        let cal = Calendar.current
        let now = Date()
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
        return store.shelterDonations
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }

    private var donorCount: Int {
        Set(store.shelterDonations.map { $0.donorName }).count
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Shelter identity
                shelterIdentity

                // Stats
                statsSection

                // Role switcher
                roleSwitcherSection

                // Dark mode
                darkModeToggle

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

    // MARK: - Identity

    private var shelterIdentity: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                }

            Text("Приют \(store.ownerName)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(OPTheme.text)

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(OPTheme.rose)
                Text("София, България")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 12) {
            settingsStatRow(icon: "heart.circle.fill", label: "Помогнати кучета", value: "\(adoptedCount)", color: OPTheme.success)
            settingsStatRow(icon: "banknote.fill", label: "Дарения този месец", value: "\(String(format: "%.0f", monthlyDonationSum)) лв", color: OPTheme.accent)
            settingsStatRow(icon: "person.2.fill", label: "Дарители", value: "\(donorCount)", color: OPTheme.rose)
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private func settingsStatRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.text)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(color)
        }
    }

    // MARK: - Role Switcher

    private var roleSwitcherSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("РОЛЯ В ПЛАТФОРМАТА")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)

            let availableRoles: [UserRole] = [.owner] + store.registeredRoles.sorted(by: { $0.rawValue < $1.rawValue })
            ForEach(availableRoles, id: \.self) { role in
                Button {
                    withAnimation(OPTheme.quickSpring) { store.activeRole = role }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: role.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(store.activeRole == role ? OPTheme.rose : OPTheme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                store.activeRole == role ? OPTheme.roseSoft : OPTheme.surfaceSunken,
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                        Text(role.label)
                            .font(.system(size: 15, weight: store.activeRole == role ? .bold : .medium))
                            .foregroundStyle(OPTheme.text)
                        Spacer()
                        if store.activeRole == role {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(OPTheme.rose)
                        }
                    }
                    .padding(12)
                    .background(
                        store.activeRole == role ? OPTheme.roseSoft.opacity(0.3) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                }
            }
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Dark Mode

    private var darkModeToggle: some View {
        @Bindable var store = store
        return HStack(spacing: 12) {
            Image(systemName: store.isDarkMode ? "moon.fill" : "sun.max.fill")
                .font(.system(size: 16))
                .foregroundStyle(store.isDarkMode ? OPTheme.accent : OPTheme.warning)
                .frame(width: 36, height: 36)
                .background(
                    (store.isDarkMode ? OPTheme.accentSoft : OPTheme.warningSoft),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
            Text("Тъмен режим")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.text)
            Spacer()
            Toggle("", isOn: $store.isDarkMode)
                .tint(OPTheme.rose)
                .labelsHidden()
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            store.signOut()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15))
                Text("Изход")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(OPTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.dangerSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.danger.opacity(0.2), lineWidth: 1))
        }
    }
}
