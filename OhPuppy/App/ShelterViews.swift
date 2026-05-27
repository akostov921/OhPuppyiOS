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
    @State private var heroFloat: CGFloat = 0

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

    private var approvedRequestsCount: Int {
        store.adoptionRequests.filter { $0.status == .approved }.count
    }

    private var rejectedRequestsCount: Int {
        store.adoptionRequests.filter { $0.status == .rejected }.count
    }

    private var recentDonations: [Donation] {
        Array(store.shelterDonations.sorted { $0.date > $1.date }.prefix(3))
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
                    highlightCards
                    adoptionPipeline
                    donationProgressCard
                    recentDonationsSection
                    addAnimalCTA
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showAddAnimal) { AddShelterAnimalSheet() }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { heroFloat = -8 }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(hex: "E07A5F"), Color(hex: "D56B4A"), Color(hex: "C1440E")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 220)
            .overlay {
                ZStack {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: ["pawprint.fill", "heart.fill", "house.fill", "leaf.fill", "pawprint.fill"][i])
                            .font(.system(size: CGFloat([16, 14, 12, 10, 18][i])))
                            .foregroundStyle(.white.opacity(Double([0.07, 0.05, 0.08, 0.06, 0.04][i])))
                            .offset(
                                x: CGFloat([-70, 90, 50, -40, 110][i]),
                                y: CGFloat([-30, 10, -50, 40, -20][i]) + heroFloat * CGFloat([1, -0.6, 0.8, -1, 0.5][i])
                            )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                DashboardRoleSwitcher()
                    .padding(.bottom, 4)

                Text("\(greeting), \(store.ownerName)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "pawprint.fill").font(.system(size: 11, weight: .bold))
                        Text("\(store.shelterAnimals.count) кучета")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(.white.opacity(0.2), in: Capsule())

                    if pendingRequestsCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.text.square.fill").font(.system(size: 11))
                            Text("\(pendingRequestsCount) нови заявки")
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

    // MARK: - Highlight Cards

    private var highlightCards: some View {
        HStack(spacing: 10) {
            homeHighlightCard(
                value: "\(availableCount)",
                label: "Налични кучета",
                icon: "pawprint.fill",
                color: OPTheme.rose,
                gradient: shelterGradient
            )
            homeHighlightCard(
                value: "\(adoptedCount)",
                label: "Осиновени",
                icon: "heart.fill",
                color: OPTheme.success,
                gradient: OPTheme.mintGradient
            )
        }
    }

    private func homeHighlightCard(value: String, label: String, icon: String, color: Color, gradient: LinearGradient) -> some View {
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

    // MARK: - Adoption Pipeline

    private var adoptionPipeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Заявки за осиновяване")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(OPTheme.text)

            HStack(spacing: 0) {
                let stages: [(label: String, count: Int, icon: String, color: Color)] = [
                    ("Нови", pendingRequestsCount, "sparkle", OPTheme.accent),
                    ("Одобрени", approvedRequestsCount, "checkmark.circle.fill", OPTheme.success),
                    ("Отказани", rejectedRequestsCount, "xmark.circle.fill", OPTheme.danger),
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

    // MARK: - Donation Progress

    private var donationProgressCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Месечна цел за дарения")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 4) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(OPTheme.rose)
                        Text("\(String(format: "%.0f", monthlyDonationSum)) / \(String(format: "%.0f", donationGoal)) лв")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                }
                Spacer()
                let pct = min(monthlyDonationSum / donationGoal, 1.0) * 100
                Text(String(format: "%.0f%%", pct))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(OPTheme.rose)
            }

            GeometryReader { geo in
                let progress = min(monthlyDonationSum / donationGoal, 1.0)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(OPTheme.surfaceSunken)
                        .frame(height: 10)
                    Capsule()
                        .fill(shelterGradient)
                        .frame(width: max(10, geo.size.width * progress), height: 10)
                        .shadow(color: OPTheme.rose.opacity(0.3), radius: 4, y: 2)
                }
            }
            .frame(height: 10)

            if monthlyDonationSum >= donationGoal {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(OPTheme.success)
                    Text("Целта е постигната!")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(OPTheme.success)
                }
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Recent Donations

    private var recentDonationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            OPSectionHeader(title: "Последни дарения")

            if recentDonations.isEmpty {
                VStack(spacing: 12) {
                    PlayfulEmptyIcon(icon: "heart")
                    Text("Все още няма дарения")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 30)
            } else {
                ForEach(recentDonations) { donation in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(donation.isRecurring ? OPTheme.accentSoft : OPTheme.roseSoft)
                                .frame(width: 42, height: 42)
                            Text(String(donation.donorName.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(donation.isRecurring ? OPTheme.accent : OPTheme.rose)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(donation.donorName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            HStack(spacing: 6) {
                                Text(donation.date.formatted(.dateTime.day().month(.abbreviated)))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(OPTheme.textSecondary)
                                if donation.isRecurring {
                                    Text("\u{00B7}")
                                        .foregroundStyle(OPTheme.textTertiary)
                                    HStack(spacing: 3) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 9, weight: .bold))
                                        Text("Месечно")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .foregroundStyle(OPTheme.accent)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(OPTheme.accentSoft, in: Capsule())
                                }
                            }
                        }

                        Spacer()

                        Text("\(String(format: "%.0f", donation.amount)) лв")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(OPTheme.rose)
                    }

                    if donation.id != recentDonations.last?.id {
                        Divider().padding(.leading, 54)
                    }
                }
            }
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    // MARK: - Add Animal CTA

    private var addAnimalCTA: some View {
        Button { showAddAnimal = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Добави куче")
                        .font(.system(size: 16, weight: .bold))
                    Text("Регистрирай ново куче в приюта")
                        .font(.system(size: 12, weight: .medium))
                        .opacity(0.8)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(shelterGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: OPTheme.rose.opacity(0.3), radius: 10, y: 4)
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
    @State private var showLogoutAlert = false
    @State private var showDarkMode = false
    @State private var showAddAnimal = false
    @State private var heroFloat: CGFloat = 0

    private let shelterGradient = LinearGradient(
        colors: [OPTheme.rose, OPTheme.accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

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

    private let mockDonationsWeek: [Double] = [80, 45, 120, 30, 95, 60, 150]
    private let mockWeekLabels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Нд"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroHeader
                statsGrid
                    .padding(.top, -36)
                    .padding(.horizontal, OPTheme.screenPadding)

                VStack(spacing: 20) {
                    quickActions
                    donationChart
                    shelterInfo
                    roleSwitcherSection
                    settingsRow
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
        .sheet(isPresented: $showAddAnimal) { AddShelterAnimalSheet() }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { heroFloat = -6 }
        }
    }

    // MARK: - Hero

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "E07A5F"), Color(hex: "D56B4A"), Color(hex: "C1440E")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 280)
            .overlay {
                ZStack {
                    ForEach(0..<4, id: \.self) { i in
                        Image(systemName: "pawprint.fill")
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
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(shelterGradient)
                        }
                }

                Text("Приют \(store.ownerName)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill").font(.system(size: 13))
                    Text("София, България").font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(.white.opacity(0.2), in: Capsule())

                HStack(spacing: 16) {
                    shelterHeroStat(value: "\(store.shelterAnimals.count)", label: "кучета")
                    Circle().fill(.white.opacity(0.4)).frame(width: 4, height: 4)
                    shelterHeroStat(value: "\(adoptedCount)", label: "осиновени")
                    Circle().fill(.white.opacity(0.4)).frame(width: 4, height: 4)
                    shelterHeroStat(value: "\(donorCount)", label: "дарители")
                }
                .padding(.top, 4)
            }
            .padding(.bottom, 52)
        }
    }

    private func shelterHeroStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 10) {
            shelterStatCard(value: String(format: "%.0f лв", monthlyDonationSum), label: "Дарения", icon: "heart.circle.fill", color: OPTheme.rose)
            shelterStatCard(value: "\(adoptedCount)", label: "Осиновени", icon: "checkmark.circle.fill", color: OPTheme.success)
            shelterStatCard(value: "\(donorCount)", label: "Дарители", icon: "person.2.fill", color: OPTheme.accent)
        }
    }

    private func shelterStatCard(value: String, label: String, icon: String, color: Color) -> some View {
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

    private var quickActions: some View {
        HStack(spacing: 10) {
            shelterQuickAction(icon: "plus.circle.fill", label: "Добави куче", gradient: LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing)) { showAddAnimal = true }
            shelterQuickAction(icon: "heart.text.square.fill", label: "Заявки", gradient: LinearGradient(colors: [OPTheme.accent, Color(hex: "E76F51")], startPoint: .leading, endPoint: .trailing)) {}
            shelterQuickAction(icon: "banknote.fill", label: "Дарения", gradient: OPTheme.mintGradient) {}
        }
    }

    private func shelterQuickAction(icon: String, label: String, gradient: LinearGradient, action: @escaping () -> Void) -> some View {
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

    // MARK: - Donation Chart

    private var donationChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Дарения тази седмица")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .bold)).foregroundStyle(OPTheme.success)
                        Text("+18% спрямо миналата").font(.system(size: 12, weight: .semibold)).foregroundStyle(OPTheme.success)
                    }
                }
                Spacer()
                Text(String(format: "%.0f лв", mockDonationsWeek.reduce(0, +)))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(OPTheme.rose)
            }

            let maxVal = mockDonationsWeek.max() ?? 1
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(i == 6
                                ? LinearGradient(colors: [OPTheme.rose, Color(hex: "C1440E")], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [OPTheme.rose.opacity(0.3), OPTheme.rose.opacity(0.15)], startPoint: .top, endPoint: .bottom))
                            .frame(height: max(8, CGFloat(mockDonationsWeek[i] / maxVal) * 80))
                        Text(mockWeekLabels[i])
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(i == 6 ? OPTheme.rose : OPTheme.textTertiary)
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

    // MARK: - Shelter Info

    private var shelterInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация за приюта").font(.system(size: 15, weight: .bold)).foregroundStyle(OPTheme.text)

            VStack(spacing: 0) {
                shelterDetailRow(icon: "building.2.fill", label: "Име", value: "Приют \(store.ownerName)", color: OPTheme.rose)
                Divider().padding(.leading, 52)
                shelterDetailRow(icon: "mappin.circle.fill", label: "Локация", value: "София, България", color: OPTheme.accent)
                Divider().padding(.leading, 52)
                shelterDetailRow(icon: "pawprint.fill", label: "Кучета", value: "\(store.shelterAnimals.count) регистрирани", color: OPTheme.mint)
                Divider().padding(.leading, 52)
                shelterDetailRow(icon: "clock.fill", label: "Член от", value: "Май 2026", color: OPTheme.sky)
                Divider().padding(.leading, 52)
                shelterDetailRow(icon: "envelope.fill", label: "Имейл", value: store.ownerEmail.isEmpty ? "—" : store.ownerEmail, color: OPTheme.success)
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    private func shelterDetailRow(icon: String, label: String, value: String, color: Color) -> some View {
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
                                    .background(isActive ? AnyShapeStyle(LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(OPTheme.surfaceSunken), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                Text(role.label)
                                    .font(.system(size: 11, weight: isActive ? .bold : .medium))
                                    .foregroundStyle(isActive ? OPTheme.rose : OPTheme.textSecondary)
                            }
                            .frame(width: 72)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Settings

    private var settingsRow: some View {
        Button { showDarkMode = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "moon.fill").font(.system(size: 14, weight: .semibold)).foregroundStyle(OPTheme.rose)
                    .frame(width: 30, height: 30)
                    .background(OPTheme.rose.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text("Тъмен режим").font(.system(size: 15, weight: .medium)).foregroundStyle(OPTheme.text)
                Spacer()
                Text(store.isDarkMode ? "Вкл." : "Изкл.").font(.system(size: 13, weight: .semibold)).foregroundStyle(OPTheme.textSecondary)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(OPTheme.textTertiary)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
        }
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
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
