import SwiftUI

// MARK: - Notifications View

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss

    private let notifications: [(icon: String, title: String, subtitle: String, time: String, color: Color)] = [
        ("cross.vial.fill", "Ваксина Бяс", "Рекс има нужда от ваксина след 6 дни", "днес", OPTheme.danger),
        ("bubble.left.fill", "Ново съобщение", "Петър (Тоби) ти изпрати съобщение", "14:32", OPTheme.mint),
        ("pawprint.fill", "Нов последовател", "Ана (Мила) те последва", "вчера", OPTheme.accent),
        ("calendar.badge.exclamationmark", "Събитие утре", "Среща на лабрадори в Южен парк", "вчера", OPTheme.sky),
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(notifications.enumerated()), id: \.offset) { index, notif in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(notif.color.opacity(0.12))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: notif.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(notif.color)
                            }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(notif.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text(notif.subtitle)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(OPTheme.textSecondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Text(notif.time)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.vertical, 14)

                    if index < notifications.count - 1 {
                        Divider().padding(.leading, 72)
                    }
                }
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .shadow(color: OPTheme.primary.opacity(0.04), radius: 10, y: 4)
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 16)
        }
        .background(OPTheme.bg)
        .navigationTitle("Известия")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Postpone Sheet

struct PostponeSheet: View {
    @Binding var postponeDate: Date
    @Binding var showConfirmation: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundStyle(OPTheme.mint)
                    Text("Отложи напомняне")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Избери дата, на която да ти напомним отново")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                DatePicker("Напомни ми на", selection: $postponeDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(OPTheme.mint)
                    .padding(.horizontal, OPTheme.screenPadding)

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showConfirmation = true
                    }
                } label: {
                    Text("Отложи")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, OPTheme.screenPadding)

                Spacer()
            }
            .background(OPTheme.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @State private var appeared = false
    @State private var showBookConfirmation = false
    @State private var showPostponeSheet = false
    @State private var postponeDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
    @State private var showPostponeConfirmation = false

    // MARK: - Health Summary Animation State
    @State private var animatedWeight: Double = 0.0
    @State private var healthCardAppeared = false
    @State private var pillSlideIn = false
    @State private var vaccineIconAppeared = false
    @State private var groomingIconAppeared = false
    @State private var vetIconAppeared = false
    @State private var vaccinePopScale: CGFloat = 0.0
    @State private var groomingRotation: Double = 0
    @State private var vetPulseScale: CGFloat = 1.0
    @State private var statLabel1Appeared = false
    @State private var statLabel2Appeared = false
    @State private var statLabel3Appeared = false

    // MARK: - Today Stats Animation State
    @State private var todayCardsAppeared = false
    @State private var todayIconBounce: [Bool] = [false, false, false]

    // MARK: - Bell Animation State
    @State private var bellTapped = false

    // MARK: - Story Strip Animation State
    @State private var storyRingRotation: Double = 0

    // MARK: - Home Customization
    @State private var showHomeCustomize = false

    // MARK: - Story Viewer State
    @State private var showStoryViewer = false
    @State private var storyViewerStories: [Story] = []
    @State private var storyViewerStartIndex = 0
    @State private var showAddStory = false

    // MARK: - Dog Status State
    @State private var showStatusPicker = false

    // MARK: - Hero Card Animation State
    @State private var heroBadgeShadowPulse = false

    var body: some View {
        Group {
            if store.dogs.isEmpty {
                homeEmptyState
            } else {
                homeContent
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Empty State

    @State private var showAddDogFromEmpty = false

    private var homeEmptyState: some View {
        VStack(spacing: 0) {
            HStack {
                OPWordmark(size: 15)
                Spacer()
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                        .frame(width: 40, height: 40)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 12)

            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(OPTheme.accentSoft)
                        .frame(width: 160, height: 160)
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(OPTheme.primaryGradient)
                        .symbolEffect(.wiggle.byLayer)
                }

                VStack(spacing: 8) {
                    Text("Добави първото си куче")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Започни да следиш ваксини, тегло и документи.\nЩе те подсещаме навреме.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }

                Button {
                    showAddDogFromEmpty = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Добави ку��е")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(OPTheme.primaryGradient, in: Capsule())
                    .shadow(color: OPTheme.primary.opacity(0.3), radius: 8, y: 4)
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .sheet(isPresented: $showAddDogFromEmpty) {
            AddDogView()
        }
    }

    // MARK: - Home Content

    private var homeContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 14)

                ForEach(store.homeSectionOrder, id: \.self) { section in
                    switch section {
                    case .stories:
                        storyStrip.padding(.bottom, 20)
                    case .upcomingEvents:
                        if let dog = store.dogs.first {
                            upcomingEventsSlider(dog: dog).padding(.bottom, 20)
                        }
                    case .todayStats:
                        todaySnapshot.padding(.bottom, 20)
                    case .social:
                        socialSection.padding(.bottom, 24)
                    case .playdate:
                        playdateSection.padding(.bottom, 24)
                    case .health:
                        healthSummary.padding(.bottom, 40)
                    }
                }
            }
            .padding(.top, 6)
        }
        .alert("Часът е запазен!", isPresented: $showBookConfirmation) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text("Часът е запазен при д-р Иванов за 30 май.")
        }
        .sheet(isPresented: $showPostponeSheet) {
            PostponeSheet(postponeDate: $postponeDate, showConfirmation: $showPostponeConfirmation)
        }
        .alert("Напомнянето е отложено", isPresented: $showPostponeConfirmation) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text("Ще ти напомним на \(postponeDate.shortBG).")
        }
        .sheet(isPresented: $showAddStory) {
            AddStorySheet()
        }
        .sheet(isPresented: $showStatusPicker) {
            DogStatusView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showHomeCustomize) {
            HomeSectionOrderSheet()
        }
        .fullScreenCover(isPresented: $showStoryViewer) {
            StoryViewer(stories: storyViewerStories, startIndex: storyViewerStartIndex)
        }
        .onAppear {
            withAnimation(OPTheme.gentleSpring) {
                appeared = true
            }
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                storyRingRotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                heroBadgeShadowPulse = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                OPWordmark(size: 15)
                Spacer()

                HStack(spacing: 10) {
                    Button { showHomeCustomize = true } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                            .frame(width: 40, height: 40)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    NavigationLink(destination: ChatView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                                .frame(width: 40, height: 40)
                                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                            Circle()
                                .fill(OPTheme.mint)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(OPTheme.bg, lineWidth: 2))
                                .offset(x: 2, y: -2)
                        }
                    }

                    NavigationLink(destination: NotificationsView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                                .symbolEffect(.wiggle, value: bellTapped)
                                .frame(width: 40, height: 40)
                                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                            Circle()
                                .fill(OPTheme.danger)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(OPTheme.bg, lineWidth: 2))
                                .offset(x: 2, y: -2)
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded { bellTapped.toggle() })

                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&h=100&q=85")) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(OPTheme.accentSoft)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(OPTheme.avatarRingGradient, lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                (Text("Здравей, ")
                    .font(.system(size: 26, weight: .regular))
                 + Text(store.ownerName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(OPTheme.primary))
                    .foregroundStyle(OPTheme.text)

                Text("Хубав ден за разходка с \(store.dogs.first?.name ?? "кучето")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)

                // Dog Status Pill
                DogStatusPill(showDogName: true) {
                    showStatusPicker = true
                }
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Story Strip

    private var storyStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // "Your" story circle
                Button {
                    if store.myStories.isEmpty {
                        showAddStory = true
                    } else {
                        storyViewerStories = store.myStories
                        storyViewerStartIndex = 0
                        showStoryViewer = true
                    }
                } label: {
                    VStack(spacing: 6) {
                        AnimatedDogAvatar(
                            url: URL(string: "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=200&h=200&q=85"),
                            size: 60,
                            showRing: !store.myStories.isEmpty,
                            ringRotation: storyRingRotation
                        )
                        .overlay(alignment: .bottomTrailing) {
                            if store.myStories.isEmpty {
                                Circle()
                                    .fill(OPTheme.primaryGradient)
                                    .frame(width: 22, height: 22)
                                    .overlay {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    .overlay(Circle().stroke(OPTheme.bg, lineWidth: 2))
                                    .offset(x: 2, y: 2)
                            }
                        }
                        Text("Твоят")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                    }
                }
                .buttonStyle(.plain)

                // Other stories from store
                ForEach(store.stories) { story in
                    VStack(spacing: 6) {
                        Button {
                            if let idx = store.stories.firstIndex(where: { $0.id == story.id }) {
                                storyViewerStories = store.stories
                                storyViewerStartIndex = idx
                                showStoryViewer = true
                            }
                        } label: {
                            AnimatedDogAvatar(
                                url: story.photoURL,
                                size: 60,
                                showRing: !story.isSeen,
                                ringRotation: storyRingRotation
                            )
                            .overlay {
                                if story.isSeen {
                                    Circle()
                                        .stroke(OPTheme.textTertiary.opacity(0.4), lineWidth: 2)
                                        .frame(width: 66, height: 66)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        if let dogId = story.dogId, let dog = nearbyDogsData.first(where: { $0.id == dogId }) {
                            NavigationLink(destination: PublicDogProfileView(dog: dog)) {
                                Text(story.dogName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(OPTheme.text)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text(story.dogName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                        }
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    // MARK: - Upcoming Events Slider

    private struct UpcomingItem: Identifiable {
        let id: String
        let icon: String
        let label: String
        let title: String
        let badge: String
        let gradient: LinearGradient
        let dogAvatarURL: URL?
    }

    private func upcomingItems(for dog: Dog) -> [UpcomingItem] {
        var items: [UpcomingItem] = []

        for v in store.upcomingVaccines(dogId: dog.id).prefix(3) {
            guard let due = v.nextDueDate else { continue }
            items.append(UpcomingItem(
                id: "v_\(v.id)",
                icon: "cross.vial.fill",
                label: "СЛЕДВАЩА ВАКСИНА",
                title: "\(v.type.label) за \(dog.name)",
                badge: "след \(due.daysFromNow) дни",
                gradient: OPTheme.primaryGradient,
                dogAvatarURL: dog.avatarURL
            ))
        }

        let recentVisits = store.vetVisitsFor(dogId: dog.id).prefix(2)
        for vv in recentVisits {
            let daysAgo = Calendar.current.dateComponents([.day], from: vv.date, to: Date()).day ?? 0
            if daysAgo <= 30 {
                items.append(UpcomingItem(
                    id: "vv_\(vv.id)",
                    icon: "stethoscope",
                    label: "ВЕТЕРИНАРЕН ПРЕГЛЕД",
                    title: vv.reason,
                    badge: vv.date.shortBG,
                    gradient: OPTheme.accentGradient,
                    dogAvatarURL: dog.avatarURL
                ))
            }
        }

        for med in store.medicationsFor(dogId: dog.id).filter(\.isActive).prefix(2) {
            items.append(UpcomingItem(
                id: "med_\(med.id)",
                icon: "pills.fill",
                label: "АКТИВНО ЛЕКАРСТВО",
                title: "\(med.name) — \(med.dose)",
                badge: med.frequency.label,
                gradient: OPTheme.mintGradient,
                dogAvatarURL: dog.avatarURL
            ))
        }

        let groomLogs = store.groomingFor(dogId: dog.id)
        if let lastGroom = groomLogs.first {
            let daysSince = Calendar.current.dateComponents([.day], from: lastGroom.date, to: Date()).day ?? 0
            if daysSince <= 30 {
                items.append(UpcomingItem(
                    id: "g_\(lastGroom.id)",
                    icon: "scissors",
                    label: "ПОСЛЕДЕН ГРИМИНГ",
                    title: "\(lastGroom.type.label) — \(dog.name)",
                    badge: "преди \(daysSince) дни",
                    gradient: LinearGradient(colors: [Color(hex: "457B9D"), Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    dogAvatarURL: dog.avatarURL
                ))
            }
        }

        return items.isEmpty ? [UpcomingItem(
            id: "empty",
            icon: "checkmark.circle.fill",
            label: "ВСИЧКО Е НАРЕД",
            title: "\(dog.name) е в отлична форма!",
            badge: "Здравен скор: \(store.healthScore(for: dog.id))",
            gradient: OPTheme.mintGradient,
            dogAvatarURL: dog.avatarURL
        )] : items
    }

    @State private var currentSliderPage = 0

    private func upcomingEventsSlider(dog: Dog) -> some View {
        let items = upcomingItems(for: dog)
        return VStack(spacing: 8) {
            TabView(selection: $currentSliderPage) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    eventSlideCard(item: item, dog: dog)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 260)

            if items.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<items.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentSliderPage ? OPTheme.primary : OPTheme.textTertiary.opacity(0.4))
                            .frame(width: i == currentSliderPage ? 8 : 6, height: i == currentSliderPage ? 8 : 6)
                            .animation(OPTheme.quickSpring, value: currentSliderPage)
                    }
                }
            }
        }
    }

    private func eventSlideCard(item: UpcomingItem, dog: Dog) -> some View {
        NavigationLink(destination: DogProfileView(dog: dog)) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: item.dogAvatarURL) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Rectangle().fill(OPTheme.surfaceSunken)
                        }
                    }
                    .frame(height: 180)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [OPTheme.primary.opacity(0.8), OPTheme.primary.opacity(0.3), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: item.icon)
                                .font(.system(size: 12))
                            Text(item.label)
                                .font(.system(size: 10, weight: .heavy))
                                .tracking(0.8)
                        }
                        .foregroundStyle(.white.opacity(0.85))

                        Text(item.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                    .padding(16)

                    VStack {
                        HStack {
                            Spacer()
                            Text(item.badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(OPTheme.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.white, in: Capsule())
                                .shadow(color: OPTheme.primary.opacity(0.15), radius: 4, y: 2)
                        }
                        Spacer()
                    }
                    .padding(12)
                }

                HStack(spacing: 10) {
                    Button {
                        showBookConfirmation = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 13))
                            Text("Запази час")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(item.gradient, in: Capsule())
                    }

                    Button {
                        showPostponeSheet = true
                    } label: {
                        Text("Отложи")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(OPTheme.surfaceSunken, in: Capsule())
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(OPTheme.surface)
            }
            .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
            .shadow(color: OPTheme.primary.opacity(0.12), radius: 16, y: 6)
        }
        .buttonStyle(PressableCardStyle())
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Today Stats

    private var todaySnapshot: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Днес")

            HStack(spacing: 10) {
                todayCardAnimated(icon: "figure.walk", label: "Разходка", value: "2.4 км", gradient: OPTheme.mintGradient, index: 0)
                todayCardAnimated(icon: "fork.knife", label: "Хранене", value: "2/3", gradient: OPTheme.warmGradient, index: 1)
                todayCardAnimated(icon: "flame.fill", label: "Streak", value: "12", gradient: OPTheme.primaryGradient, index: 2)
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
        .onAppear {
            // Staggered card scale-in
            for i in 0..<3 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(i) * 0.1)) {
                    todayCardsAppeared = true
                }
                // Icon bounce after card appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                        todayIconBounce[i] = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            todayIconBounce[i] = false
                        }
                    }
                }
            }
        }
    }

    private func todayCardAnimated(icon: String, label: String, value: String, gradient: LinearGradient, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(gradient)
                .frame(width: 34, height: 34)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce.up, value: todayIconBounce[index])
                        .offset(y: todayIconBounce[index] ? -4 : 0)
                }
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .scaleEffect(todayCardsAppeared ? 1.0 : 0.8)
        .opacity(todayCardsAppeared ? 1.0 : 0.0)
    }

    // MARK: - Health Summary

    private var healthSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Здравето на \(store.dogs.first?.name ?? "кучето")")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(OPTheme.text)

                let healthScore = store.healthScore(for: store.dogs.first?.id ?? "")
                let scoreColor: Color = healthScore >= 80 ? OPTheme.success : healthScore >= 50 ? OPTheme.warning : OPTheme.danger
                Text("\(healthScore)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(scoreColor, in: Circle())

                Spacer()
            }
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                // Weight display
                NavigationLink(destination: WeightView(dogId: store.dogs.first?.id ?? "")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ТЕГЛО")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(OPTheme.textSecondary)
                                .tracking(0.5)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(String(format: "%.1f", animatedWeight))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(OPTheme.text)
                                    .contentTransition(.numericText(value: animatedWeight))
                                Text("кг")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(OPTheme.textSecondary)
                            }
                        }
                        Spacer()
                        StatPill(label: "+0.4 кг", icon: "arrow.up.right", tone: .mint)
                            .offset(x: pillSlideIn ? 0 : 60)
                            .opacity(pillSlideIn ? 1 : 0)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 16)

                // Health stats row
                HStack(spacing: 0) {
                    // Icon 1: Vaccines — bounce in from below + pop scale
                    healthStatCellAnimated(
                        icon: "cross.vial.fill",
                        label: "5/6",
                        sub: "ваксини",
                        color: OPTheme.success,
                        destination: VaccineListView(dogId: store.dogs.first?.id ?? ""),
                        iconOffset: vaccineIconAppeared ? 0 : 20,
                        iconOpacity: vaccineIconAppeared ? 1 : 0,
                        iconScale: vaccinePopScale,
                        iconRotation: 0,
                        labelAppeared: statLabel1Appeared
                    )
                    dividerV
                    // Icon 2: Grooming scissors — 360 rotation
                    healthStatCellAnimated(
                        icon: "scissors",
                        label: "12d",
                        sub: "гриминг",
                        color: OPTheme.sky,
                        destination: VaccineListView(dogId: store.dogs.first?.id ?? ""),
                        iconOffset: 0,
                        iconOpacity: groomingIconAppeared ? 1 : 0,
                        iconScale: 1.0,
                        iconRotation: groomingRotation,
                        labelAppeared: statLabel2Appeared
                    )
                    dividerV
                    // Icon 3: Vet stethoscope — heartbeat pulse
                    healthStatCellAnimated(
                        icon: "stethoscope",
                        label: "3 м.",
                        sub: "преглед",
                        color: OPTheme.rose,
                        destination: VaccineListView(dogId: store.dogs.first?.id ?? ""),
                        iconOffset: 0,
                        iconOpacity: vetIconAppeared ? 1 : 0,
                        iconScale: vetPulseScale,
                        iconRotation: 0,
                        labelAppeared: statLabel3Appeared
                    )
                }
            }
            .background(OPTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
            .shadow(color: OPTheme.primary.opacity(0.06), radius: 12, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .onAppear {
                triggerHealthAnimations()
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func triggerHealthAnimations() {
        // Animate weight counting up
        withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.2)) {
            animatedWeight = store.dogs.first?.weight ?? 0
        }

        // Pill slides in from right
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.5)) {
            pillSlideIn = true
        }

        // Icon 1 (vaccines): bounce from below at 0.3s, then pop at 0.6s
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.3)) {
            vaccineIconAppeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
                vaccinePopScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    vaccinePopScale = 1.0
                }
            }
        }

        // Icon 2 (grooming): rotate 360 at 0.5s
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.5)) {
            groomingIconAppeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.6)) {
                groomingRotation = 360
            }
        }

        // Icon 3 (vet): heartbeat pulse at 0.7s
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.7)) {
            vetIconAppeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // First beat
            withAnimation(.easeOut(duration: 0.15)) {
                vetPulseScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeIn(duration: 0.1)) {
                    vetPulseScale = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    // Second beat
                    withAnimation(.easeOut(duration: 0.12)) {
                        vetPulseScale = 1.15
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.easeIn(duration: 0.15)) {
                            vetPulseScale = 1.0
                        }
                    }
                }
            }
        }

        // Stat labels fade in after their icons
        withAnimation(.easeOut(duration: 0.3).delay(0.4)) {
            statLabel1Appeared = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.6)) {
            statLabel2Appeared = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.8)) {
            statLabel3Appeared = true
        }
    }

    private func healthStatCellAnimated<D: View>(
        icon: String,
        label: String,
        sub: String,
        color: Color,
        destination: D,
        iconOffset: CGFloat,
        iconOpacity: Double,
        iconScale: CGFloat,
        iconRotation: Double,
        labelAppeared: Bool
    ) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .symbolEffect(.pulse, value: healthCardAppeared)
                    .offset(y: iconOffset)
                    .opacity(iconOpacity)
                    .scaleEffect(iconScale == 0 ? 1.0 : iconScale)
                    .rotationEffect(.degrees(iconRotation))
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                    .opacity(labelAppeared ? 1 : 0)
                    .offset(y: labelAppeared ? 0 : 6)
                Text(sub)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .opacity(labelAppeared ? 1 : 0)
                    .offset(y: labelAppeared ? 0 : 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var dividerV: some View {
        Rectangle().fill(OPTheme.border).frame(width: 1, height: 50)
    }

    // MARK: - Social Section

    private var socialSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Социално")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(socialPreviews, id: \.dogName) { preview in
                        NavigationLink(destination: FeedView()) {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: preview.photoURL) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Rectangle().fill(OPTheme.surfaceSunken)
                                    }
                                }
                                .frame(width: 150, height: 190)
                                .clipped()

                                LinearGradient(
                                    colors: [.black.opacity(0.6), .clear],
                                    startPoint: .bottom,
                                    endPoint: .center
                                )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preview.dogName)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.white)
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 10))
                                        Text("\(preview.likes)")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundStyle(.white.opacity(0.8))
                                }
                                .padding(12)
                            }
                            .frame(width: 150, height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
                            .shadow(color: OPTheme.primary.opacity(0.1), radius: 10, y: 4)
                        }
                        .buttonStyle(PressableCardStyle())
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
            }
        }
    }

    // MARK: - Playdate Section

    private var playdateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OPSectionHeader(title: "Playdate")
                .padding(.horizontal, OPTheme.screenPadding)

            NavigationLink(destination: PlaydateView()) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "52B788").opacity(0.15), Color(hex: "40916C").opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(OPTheme.mintGradient)
                                .frame(width: 52, height: 52)
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .symbolEffect(.breathe)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("4 кучета наблизо")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("Намери приятел за разходка")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(OPTheme.mint)
                            .frame(width: 30, height: 30)
                            .background(OPTheme.mint.opacity(0.12), in: Circle())
                    }
                    .padding(16)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(OPTheme.mint.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(PressableCardStyle())
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    private var socialPreviews: [(dogName: String, photoURL: URL?, likes: Int)] {
        [
            ("Тоби", URL(string: "https://images.unsplash.com/photo-1450778869180-41d0601e046e?auto=format&fit=crop&w=300&h=300&q=85"), 24),
            ("Локи", URL(string: "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=300&h=300&q=85"), 18),
            ("Мила", URL(string: "https://images.unsplash.com/photo-1612536057832-2ff7ead58194?auto=format&fit=crop&w=300&h=300&q=85"), 31),
        ]
    }

}

// MARK: - Home Section Order Sheet

struct HomeSectionOrderSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            List {
                Section {
                    ForEach(store.homeSectionOrder, id: \.self) { section in
                        HStack(spacing: 12) {
                            Image(systemName: section.icon)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(OPTheme.mint)
                                .frame(width: 28)
                            Text(section.label)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(OPTheme.text)
                            Spacer()
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 14))
                                .foregroundStyle(OPTheme.textTertiary)
                        }
                    }
                    .onMove { from, to in
                        store.homeSectionOrder.move(fromOffsets: from, toOffset: to)
                    }
                } header: {
                    Text("Подреди секциите на началния екран")
                } footer: {
                    Text("Дръпни за да пренаредиш. Секциите ще се показват в избрания от теб ред.")
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Начален екран")
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
}

// MARK: - Animated Dog Avatar (Story Strip)

private struct AnimatedDogAvatar: View {
    let url: URL?
    var size: CGFloat = 56
    var showRing: Bool = true
    var ringRotation: Double = 0

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Circle().fill(OPTheme.surfaceSunken)
                    .overlay {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: size * 0.35))
                            .foregroundStyle(OPTheme.mint)
                    }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            if showRing {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [Color(hex: "52B788"), Color(hex: "2D6A4F"), Color(hex: "F4A261"), Color(hex: "E76F51"), Color(hex: "52B788")],
                            center: .center
                        ),
                        lineWidth: size * 0.05
                    )
                    .frame(width: size + size * 0.1, height: size + size * 0.1)
                    .rotationEffect(.degrees(ringRotation))
            }
        }
    }
}
