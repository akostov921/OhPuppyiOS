import SwiftUI

struct DogProfileView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var activeTab = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var showEditDog = false
    @State private var showShareProfile = false

    private var dog: Dog {
        store.dogs.first { $0.id == dogId } ?? Dog(id: dogId, name: "?", breed: "", birthDate: .now, sex: .male, neutered: false, weight: 0, ownerId: "1")
    }

    init(dog: Dog) {
        self.dogId = dog.id
    }

    private var groomingSub: String {
        let logs = store.groomingFor(dogId: dogId)
        guard let last = logs.first else { return "Няма записи" }
        return "Последно: \(last.date.shortBG)"
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                heroPhoto
                titleBlock
                statChips
                    .padding(.bottom, 20)
                tabSwitcher
                    .padding(.bottom, 16)
                tabContent
                    .padding(.bottom, 60)
            }
        }
        .background(OPTheme.bg)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showEditDog) {
            EditDogView(dog: dog)
        }
        .sheet(isPresented: $showShareProfile) {
            ShareDogProfileSheet(dogId: dogId)
        }
        .onChange(of: store.dogs) { _, newValue in
            if !newValue.contains(where: { $0.id == dogId }) {
                dismiss()
            }
        }
    }

    // MARK: - Hero Photo

    private var heroPhoto: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: dog.avatarURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(OPTheme.surfaceSunken)
                }
            }
            .frame(height: 360)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, .clear, OPTheme.bg.opacity(0.5), OPTheme.bg],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 160)
            }

            HStack {
                BackButton()
                Spacer()
                Button { showShareProfile = true } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.2), lineWidth: 1))
                }
                Button { showEditDog = true } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .symbolEffect(.wiggle, value: showEditDog)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.top, 56)
            .padding(.horizontal, 16)

            // Breed tag
            HStack(spacing: 6) {
                tagPill("\(dog.sex.icon) \(dog.breed)")
            }
            .padding(.top, 110)
            .padding(.leading, 20)
        }
    }

    // MARK: - Title

    private var isBirthdaySoon: Bool {
        let cal = Calendar.current
        let now = Date()
        let birthComps = cal.dateComponents([.month, .day], from: dog.birthDate)
        guard let thisYearBday = cal.date(from: DateComponents(year: cal.component(.year, from: now), month: birthComps.month, day: birthComps.day)) else { return false }
        let diff = cal.dateComponents([.day], from: now, to: thisYearBday).day ?? 999
        return diff >= 0 && diff <= 7
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(dog.name)
                    .font(.system(size: 42, weight: .bold))
                    .tracking(-1.5)
                Text(".")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(OPTheme.mint)
                if isBirthdaySoon {
                    Text(" 🎂")
                        .font(.system(size: 28))
                }
            }
            .foregroundStyle(OPTheme.text)

            Text(dog.ageDescription)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)

            // Dog Status Badge
            DogStatusBadge()
        }
        .padding(.horizontal, OPTheme.screenPadding)
        .offset(y: -30)
        .padding(.bottom, -10)
    }

    // MARK: - Stat Chips

    private var statChips: some View {
        HStack(spacing: 10) {
            statChip(icon: "scalemass.fill", label: "\(String(format: "%.1f", dog.weight)) кг", gradient: OPTheme.warmGradient)
            statChip(icon: "bolt.fill", label: "Активен", gradient: OPTheme.mintGradient)
            statChip(icon: "cpu", label: dog.microchip != nil ? "Чипиран" : "Без чип", gradient: OPTheme.primaryGradient)
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func statChip(icon: String, label: String, gradient: LinearGradient) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(gradient)
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OPTheme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
    }

    // MARK: - Tabs

    private var tabSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(Array(["Здраве", "Снимки", "Дневник", "Документи"].enumerated()), id: \.offset) { i, title in
                Button {
                    withAnimation(OPTheme.quickSpring) { activeTab = i }
                } label: {
                    Text(title)
                        .font(.system(size: 12, weight: activeTab == i ? .bold : .semibold))
                        .foregroundStyle(activeTab == i ? .white : OPTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            activeTab == i ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(Color.clear),
                            in: Capsule()
                        )
                }
            }
        }
        .padding(4)
        .background(OPTheme.surfaceSunken, in: Capsule())
        .padding(.horizontal, OPTheme.screenPadding)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case 0: healthTab
        case 1: photosPlaceholder
        case 2: diaryTab
        case 3: documentsPlaceholder
        default: EmptyView()
        }
    }

    // MARK: - Health Tab

    private var healthScoreColor: Color {
        let s = store.healthScore(for: dogId)
        if s >= 80 { return OPTheme.success }
        if s >= 50 { return OPTheme.warning }
        return OPTheme.danger
    }

    private var healthTab: some View {
        VStack(spacing: 10) {
            // Health Score at the top
            NavigationLink(destination: HealthScoreView(dogId: dogId)) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(OPTheme.surfaceSunken, lineWidth: 3)
                            .frame(width: 44, height: 44)
                        Circle()
                            .trim(from: 0, to: CGFloat(store.healthScore(for: dogId)) / 100.0)
                            .stroke(healthScoreColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))
                        Text("\(store.healthScore(for: dogId))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(healthScoreColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Здравен скор")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                        Text(store.healthScore(for: dogId) >= 80 ? "Отлично" : store.healthScore(for: dogId) >= 50 ? "Добре" : "Нуждае се от внимание")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(OPTheme.textTertiary)
                }
                .padding(14)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                        .stroke(OPTheme.border, lineWidth: 1)
                )
            }
            .buttonStyle(PressableCardStyle())

            healthRow(icon: "cross.vial.fill", title: "Ваксини", sub: "\(store.vaccinesFor(dogId: dogId).count) регистрирани", color: OPTheme.accent, bg: OPTheme.accentSoft, destination: VaccineListView(dogId: dogId))
            healthRow(icon: "scissors", title: "Гримин��", sub: groomingSub, color: OPTheme.sky, bg: OPTheme.skySoft, destination: GroomingView(dogId: dogId))
            healthRow(icon: "scalemass.fill", title: "Тегло", sub: "\(String(format: "%.1f", dog.weight)) кг", color: OPTheme.success, bg: OPTheme.successSoft, destination: WeightView(dogId: dogId))
            healthRow(icon: "pills.fill", title: "Лекарства", sub: "\(store.medicationsFor(dogId: dogId).filter(\.isActive).count) активни", color: OPTheme.info, bg: OPTheme.infoSoft, destination: MedicationsView(dogId: dogId))
            healthRow(icon: "stethoscope", title: "Ветеринар", sub: "\(store.vetVisitsFor(dogId: dogId).count) посещения", color: OPTheme.rose, bg: OPTheme.roseSoft, destination: VetVisitsView(dogId: dogId))
            healthRow(icon: "star.fill", title: "Milestones", sub: "\(store.milestonesFor(dogId: dogId).count) постигнати", color: Color(hex: "9B5DE5"), bg: Color(hex: "9B5DE5").opacity(0.12), destination: MilestonesView(dogId: dogId))
            healthRow(icon: "lightbulb.fill", title: "Препоръки", sub: "Храна, играчки, грижа", color: OPTheme.mint, bg: OPTheme.mintSoft, destination: BreedRecommendationsView(breed: dog.breed))

            // Breed Info
            healthRow(icon: "book.fill", title: "За породата", sub: dog.breed, color: OPTheme.primary, bg: OPTheme.primarySoft, destination: BreedInfoView(breed: dog.breed, dogAvatarURL: dog.avatarURL))

            // Digital Passport
            healthRow(icon: "qrcode", title: "Дигитален паспорт", sub: "QR код с медицински данни", color: OPTheme.sky, bg: OPTheme.skySoft, destination: DigitalPassportView(dogId: dogId))
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Diary Tab

    private var diaryTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Condensed timeline (last 5 entries)
            let entries = recentTimelineEntries
            if entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text("Все още няма записи")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(entries) { entry in
                    diaryEntryRow(entry)
                }

                NavigationLink(destination: TimelineView(dogId: dogId)) {
                    HStack {
                        Spacer()
                        Text("Виж всичко")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.mint)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.mint)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(OPTheme.mintSoft, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous))
                }
                .buttonStyle(PressableCardStyle())
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private var recentTimelineEntries: [TimelineEntry] {
        var entries: [TimelineEntry] = []

        for v in store.vaccinesFor(dogId: dogId) {
            entries.append(TimelineEntry(id: "v_\(v.id)", type: .vaccine, title: v.type.label, subtitle: v.vet ?? "Ваксинация", date: v.dateAdministered, photoURL: nil))
        }
        for w in store.weightsFor(dogId: dogId) {
            entries.append(TimelineEntry(id: "w_\(w.id)", type: .weight, title: "\(String(format: "%.1f", w.weight)) кг", subtitle: w.notes ?? "Измерване", date: w.date, photoURL: nil))
        }
        for g in store.groomingFor(dogId: dogId) {
            entries.append(TimelineEntry(id: "g_\(g.id)", type: .grooming, title: g.type.label, subtitle: g.notes ?? "Гриминг", date: g.date, photoURL: nil))
        }
        for vv in store.vetVisitsFor(dogId: dogId) {
            entries.append(TimelineEntry(id: "vv_\(vv.id)", type: .vet, title: vv.reason, subtitle: vv.diagnosis ?? "", date: vv.date, photoURL: nil))
        }
        for d in store.diaryEntriesFor(dogId: dogId) {
            entries.append(TimelineEntry(id: "d_\(d.id)", type: .diary, title: "Дневник", subtitle: d.text, date: d.date, photoURL: d.photoURL))
        }

        return Array(entries.sorted { $0.date > $1.date }.prefix(5))
    }

    private func diaryEntryRow(_ entry: TimelineEntry) -> some View {
        HStack(spacing: 12) {
            IconBadge(icon: entry.type.icon, color: entry.type.color, bgColor: entry.type.bgColor, size: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                    .lineLimit(1)
                Text(entry.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(entry.date.shortBG)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .padding(12)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
    }

    private func healthRow<D: View>(icon: String, title: String, sub: String, color: Color, bg: Color, destination: D) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 44 * 0.32, style: .continuous)
                    .fill(bg)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 44 * 0.42, weight: .semibold))
                            .foregroundStyle(color)
                            .symbolEffect(.pulse)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(OPTheme.text)
                    Text(sub).font(.system(size: 13, weight: .medium)).foregroundStyle(OPTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.textTertiary)
            }
            .padding(14)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(PressableCardStyle())
    }

    private var photosPlaceholder: some View {
        let photoURLs = [
            "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=300&h=300&q=85",
            "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=300&h=300&q=85",
            "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=300&h=300&q=85",
            "https://images.unsplash.com/photo-1477884213360-7e9d7dcc8f9b?auto=format&fit=crop&w=300&h=300&q=85",
            "https://images.unsplash.com/photo-1558788353-f76d92427f16?auto=format&fit=crop&w=300&h=300&q=85",
            "https://images.unsplash.com/photo-1534361960057-19889db9621e?auto=format&fit=crop&w=300&h=300&q=85",
        ]

        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)], spacing: 4) {
            ForEach(Array(photoURLs.enumerated()), id: \.offset) { _, urlStr in
                AsyncImage(url: URL(string: urlStr)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(OPTheme.surfaceSunken)
                    }
                }
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private var documentsPlaceholder: some View {
        let documents: [(icon: String, name: String, detail: String, tone: StatPill.Tone)] = [
            ("doc.text.fill", "Паспорт", "Изтича: 22.04.2028", .success),
            ("lock.shield.fill", "Застраховка", "Изтича след 22 дни", .warning),
            ("cpu", "Микрочип регистрация", "900164001234567", .success),
            ("doc.richtext", "Родословие", "Постоянен", .neutral),
        ]

        return VStack(spacing: 8) {
            ForEach(Array(documents.enumerated()), id: \.offset) { _, doc in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(doc.tone == .warning ? OPTheme.warningSoft : doc.tone == .success ? OPTheme.successSoft : OPTheme.surfaceSunken)
                        .frame(width: 44, height: 52)
                        .overlay {
                            Image(systemName: doc.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(doc.tone == .warning ? OPTheme.warning : doc.tone == .success ? OPTheme.success : OPTheme.textSecondary)
                        }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(doc.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                        Text(doc.detail)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(OPTheme.textTertiary)
                }
                .padding(14)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                        .stroke(OPTheme.border, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func tagPill(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .heavy))
            .tracking(0.8)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - Share Dog Profile Sheet

struct ShareDogProfileSheet: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private var dog: Dog {
        store.dogs.first { $0.id == dogId } ?? Dog(id: dogId, name: "?", breed: "", birthDate: .now, sex: .male, neutered: false, weight: 0, ownerId: "1")
    }

    private var shareText: String {
        let vaccines = store.vaccinesFor(dogId: dogId)
        let vaccineList = vaccines.map { "\($0.type.label) — \($0.dateAdministered.shortBG)" }.joined(separator: "\n  ")
        let healthScore = store.healthScore(for: dogId)

        return """
        \(dog.name) — \(dog.breed)
        \(dog.sex == .male ? "Мъжки" : "Женски") \u{2022} \(dog.age) \u{2022} \(String(format: "%.1f", dog.weight)) кг
        \(dog.neutered ? "Кастриран" : "Некастриран")
        Микрочип: \(dog.microchip ?? "Няма")
        Здравен скор: \(healthScore)/100

        Ваксини:
          \(vaccineList.isEmpty ? "Няма регистрирани" : vaccineList)

        Споделено чрез OhPuppy
        """
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 14) {
                        AsyncImage(url: dog.avatarURL) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Circle().fill(OPTheme.surfaceSunken)
                            }
                        }
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(OPTheme.avatarRingGradient, lineWidth: 3))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(dog.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("\(dog.breed) \u{2022} \(dog.age)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                        Spacer()
                    }

                    VStack(spacing: 0) {
                        infoRow(icon: "scalemass.fill", label: "Тегло", value: "\(String(format: "%.1f", dog.weight)) кг", color: OPTheme.mint)
                        Divider().padding(.leading, 50)
                        infoRow(icon: dog.sex == .male ? "figure.stand" : "figure.stand.dress", label: "Пол", value: dog.sex == .male ? "Мъжки" : "Женски", color: OPTheme.sky)
                        Divider().padding(.leading, 50)
                        infoRow(icon: "heart.fill", label: "Кастриран", value: dog.neutered ? "Да" : "Не", color: OPTheme.rose)
                        Divider().padding(.leading, 50)
                        infoRow(icon: "cpu", label: "Микрочип", value: dog.microchip ?? "Няма", color: OPTheme.primary)
                        Divider().padding(.leading, 50)
                        infoRow(icon: "cross.vial.fill", label: "Ваксини", value: "\(store.vaccinesFor(dogId: dogId).count) регистрирани", color: OPTheme.accent)
                        Divider().padding(.leading, 50)
                        infoRow(icon: "chart.bar.fill", label: "Здравен скор", value: "\(store.healthScore(for: dogId))/100", color: OPTheme.success)
                    }
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                            .stroke(OPTheme.border, lineWidth: 1)
                    )

                    VStack(spacing: 12) {
                        ShareLink(item: shareText) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Сподели профил")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(OPTheme.primaryGradient, in: Capsule())
                            .shadow(color: OPTheme.primary.opacity(0.3), radius: 8, y: 4)
                        }

                        NavigationLink(destination: DigitalPassportView(dogId: dogId)) {
                            HStack(spacing: 8) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("QR Паспорт")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(OPTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(OPTheme.primarySoft, in: Capsule())
                        }
                    }
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Сподели \(dog.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.primary)
                }
            }
        }
    }

    private func infoRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(OPTheme.text)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
