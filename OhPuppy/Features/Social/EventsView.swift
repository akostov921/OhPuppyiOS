import SwiftUI

struct EventsView: View {
    @Environment(AppStore.self) private var store
    @State private var goingSet: Set<String> = ["e1"]
    @State private var showCreateEvent = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                eventsHeader
                    .padding(.bottom, 16)

                ForEach(allEvents) { event in
                    NavigationLink(destination: EventDetailView(event: event, isGoing: goingSet.contains(event.id), onToggleRSVP: {
                        withAnimation(OPTheme.quickSpring) {
                            if goingSet.contains(event.id) { goingSet.remove(event.id) } else { goingSet.insert(event.id) }
                        }
                    })) {
                        EventCard(event: event, isGoing: goingSet.contains(event.id)) {
                            withAnimation(OPTheme.quickSpring) {
                                if goingSet.contains(event.id) { goingSet.remove(event.id) } else { goingSet.insert(event.id) }
                            }
                        }
                    }
                    .buttonStyle(PressableCardStyle())
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 14)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreateEvent) {
            CreateEventSheet()
        }
    }

    private var allEvents: [DogEvent] {
        mockEvents + store.userEvents
    }

    private var eventsHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Събития")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("Наблизо тази седмица")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }
            Spacer()
            Button { showCreateEvent = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: OPTheme.primary.opacity(0.3), radius: 6, y: 3)
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Mock Data

    private var mockEvents: [DogEvent] {
        [
            DogEvent(
                id: "e1", title: "Среща на лабрадори",
                dayNumber: "25", monthLabel: "май",
                dateTimeText: "Сб 25 май, 10:00", location: "Южен парк",
                attending: 12, capacity: 20,
                description: "Ежемесечна среща за лабрадори и техните стопани. Носете играчки и лакомства! Ще има фотограф и награди за най-послушно куче.",
                photoURL: "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=800&h=400&q=85",
                contactName: "Петър Иванов", contactPhone: "+359 88 123 4567",
                participants: [
                    EventParticipant(id: "ep1", name: "Петър", dogName: "Тоби", avatarURL: "https://images.unsplash.com/photo-1450778869180-41d0601e046e?auto=format&fit=crop&w=100&h=100&q=85"),
                    EventParticipant(id: "ep2", name: "Ана", dogName: "Мила", avatarURL: "https://images.unsplash.com/photo-1612536057832-2ff7ead58194?auto=format&fit=crop&w=100&h=100&q=85"),
                    EventParticipant(id: "ep3", name: "Марко", dogName: "Локи", avatarURL: "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=100&h=100&q=85"),
                    EventParticipant(id: "ep4", name: "Иван", dogName: "Чарли", avatarURL: "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=100&h=100&q=85"),
                ],
                reviews: [
                    EventReview(id: "er1", authorName: "Мария", rating: 5, text: "Страхотна атмосфера! Тоби се забавляваше с другите кучета.", date: "15 апр 2026"),
                    EventReview(id: "er2", authorName: "Георги", rating: 4, text: "Добра организация, ще дойдем пак.", date: "18 мар 2026"),
                ]
            ),
            DogEvent(
                id: "e2", title: "Сутрешна разходка",
                dayNumber: "26", monthLabel: "май",
                dateTimeText: "Нед 26 май, 08:00", location: "Витоша",
                attending: 4, capacity: 10,
                description: "Планинска разходка за активни кучета. Маршрут: Драгалевски манастир → Копитото. Около 2 часа.",
                photoURL: "https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=800&h=400&q=85",
                contactName: "Стефан", contactPhone: nil,
                participants: [
                    EventParticipant(id: "ep5", name: "Стефан", dogName: "Бъди", avatarURL: nil),
                    EventParticipant(id: "ep6", name: "Десислава", dogName: "Рокси", avatarURL: nil),
                ],
                reviews: nil
            ),
            DogEvent(
                id: "e3", title: "Купон за рожден ден",
                dayNumber: "1", monthLabel: "юни",
                dateTimeText: "Сб 1 юни, 14:00", location: "Кафе Тарантула",
                attending: 8, capacity: 15,
                description: "Рокси навършва 3 години! Ще има торта за кучета, подаръци и много забавления.",
                photoURL: "https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?auto=format&fit=crop&w=800&h=400&q=85",
                contactName: "Десислава", contactPhone: "+359 89 987 6543",
                participants: [
                    EventParticipant(id: "ep7", name: "Десислава", dogName: "Рокси", avatarURL: "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=100&h=100&q=85"),
                    EventParticipant(id: "ep8", name: "Петър", dogName: "Тоби", avatarURL: "https://images.unsplash.com/photo-1450778869180-41d0601e046e?auto=format&fit=crop&w=100&h=100&q=85"),
                ],
                reviews: [
                    EventReview(id: "er3", authorName: "Ана", rating: 5, text: "Миналата година беше невероятно! Задължително елате.", date: "2 юни 2025"),
                ]
            ),
        ]
    }
}

// MARK: - Event Model

struct DogEvent: Identifiable, Codable {
    let id: String
    let title: String
    let dayNumber: String
    let monthLabel: String
    let dateTimeText: String
    let location: String
    let attending: Int
    let capacity: Int
    var description: String?
    var photoURL: String?
    var contactName: String?
    var contactPhone: String?
    var participants: [EventParticipant]?
    var reviews: [EventReview]?
}

struct EventParticipant: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let dogName: String
    let avatarURL: String?
}

struct EventReview: Identifiable, Codable {
    let id: String
    let authorName: String
    let rating: Int
    let text: String
    let date: String
}

// MARK: - Event Detail View

struct EventDetailView: View {
    let event: DogEvent
    let isGoing: Bool
    let onToggleRSVP: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                heroSection
                infoSection
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                if let participants = event.participants, !participants.isEmpty {
                    participantsSection(participants)
                        .padding(.bottom, 20)
                }

                if let reviews = event.reviews, !reviews.isEmpty {
                    reviewsSection(reviews)
                        .padding(.bottom, 20)
                }

                if event.contactName != nil || event.contactPhone != nil {
                    contactSection
                        .padding(.horizontal, OPTheme.screenPadding)
                        .padding(.bottom, 20)
                }

                rsvpButton
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            if let urlStr = event.photoURL {
                AsyncImage(url: URL(string: urlStr)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(OPTheme.primaryGradient)
                    }
                }
                .frame(height: 240)
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(colors: [.clear, OPTheme.bg.opacity(0.8), OPTheme.bg], startPoint: .center, endPoint: .bottom)
                        .frame(height: 100)
                }
            } else {
                Rectangle().fill(OPTheme.primaryGradient)
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.3))
                    }
            }

            BackButton()
                .padding(.top, 56)
                .padding(.leading, 16)
        }
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(event.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(OPTheme.text)

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(OPTheme.mint)
                    Text(event.dateTimeText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                }
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14))
                        .foregroundStyle(OPTheme.accent)
                    Text(event.location)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(OPTheme.sky)
                Text("\(event.attending) / \(event.capacity) участници")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            if let desc = event.description {
                Text(desc)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineSpacing(3)
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - Participants

    private func participantsSection(_ participants: [EventParticipant]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Участници (\(participants.count))")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
                .padding(.horizontal, OPTheme.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(participants) { p in
                        VStack(spacing: 6) {
                            AsyncImage(url: URL(string: p.avatarURL ?? "")) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    Circle().fill(OPTheme.surfaceSunken)
                                        .overlay {
                                            Image(systemName: "pawprint.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(OPTheme.mint.opacity(0.5))
                                        }
                                }
                            }
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(OPTheme.mint.opacity(0.3), lineWidth: 2))

                            Text(p.dogName)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text(p.name)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                        .frame(width: 64)
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
            }
        }
    }

    // MARK: - Reviews

    private func reviewsSection(_ reviews: [EventReview]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Отзиви")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
                .padding(.horizontal, OPTheme.screenPadding)

            VStack(spacing: 10) {
                ForEach(reviews) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(review.authorName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(0..<review.rating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(OPTheme.accent)
                                }
                            }
                        }
                        Text(review.text)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(OPTheme.textSecondary)
                            .lineSpacing(2)
                        Text(review.date)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                    .padding(14)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(OPTheme.border, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    // MARK: - Contact

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Контакт")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)

            HStack(spacing: 12) {
                Circle()
                    .fill(OPTheme.mintGradient)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    if let name = event.contactName {
                        Text(name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                    }
                    if let phone = event.contactPhone {
                        Text(phone)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OPTheme.mint)
                    }
                }

                Spacer()

                if event.contactPhone != nil {
                    Button {
                    } label: {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(OPTheme.mintGradient, in: Circle())
                    }
                }
            }
            .padding(14)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
        }
    }

    // MARK: - RSVP

    private var rsvpButton: some View {
        Button {
            onToggleRSVP()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isGoing ? "checkmark.circle.fill" : "calendar.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                Text(isGoing ? "Отивам!" : "Запиши ме")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isGoing ? OPTheme.mintGradient : OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: (isGoing ? OPTheme.mint : OPTheme.primary).opacity(0.3), radius: 10, y: 4)
        }
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: DogEvent
    let isGoing: Bool
    let onToggleRSVP: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(event.dayNumber)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(isGoing ? .white : OPTheme.text)
                Text(event.monthLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isGoing ? .white.opacity(0.85) : OPTheme.textSecondary)
                    .textCase(.uppercase)
            }
            .frame(width: 56, height: 60)
            .background(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous)
                    .fill(isGoing ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken))
            )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Spacer()
                    Button { onToggleRSVP() } label: {
                        Text(isGoing ? "Отивам" : "Запиши ме")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(isGoing ? .white : OPTheme.mint)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(isGoing ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.mintSoft), in: Capsule())
                    }
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(OPTheme.textTertiary)
                        Text(event.dateTimeText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                        .foregroundStyle(OPTheme.textTertiary)
                    Text(event.location)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }

                HStack(spacing: 8) {
                    if let participants = event.participants {
                        HStack(spacing: -8) {
                            ForEach(participants.prefix(3)) { p in
                                AsyncImage(url: URL(string: p.avatarURL ?? "")) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Circle().fill(OPTheme.mint.opacity(0.3))
                                    }
                                }
                                .frame(width: 22, height: 22)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                            }
                            if participants.count > 3 {
                                Text("+\(participants.count - 3)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(OPTheme.textSecondary)
                                    .frame(width: 22, height: 22)
                                    .background(OPTheme.surfaceSunken, in: Circle())
                                    .overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                            }
                        }
                    } else {
                        HStack(spacing: -8) {
                            Circle().fill(OPTheme.mint).frame(width: 22, height: 22).overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                            Circle().fill(OPTheme.accent).frame(width: 22, height: 22).overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                            Circle().fill(OPTheme.sky).frame(width: 22, height: 22).overlay(Circle().stroke(OPTheme.surface, lineWidth: 2))
                        }
                    }

                    Text("\(event.attending) / \(event.capacity) кучета")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }
        }
        .padding(14)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(isGoing ? OPTheme.mint.opacity(0.3) : OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 10, y: 4)
    }
}

// MARK: - Create Event Sheet

struct CreateEventSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var maxAttendees = 10
    @State private var selectedPhotoIndex = 0
    private let eventPhotos = [
        "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=800&h=400&q=85",
        "https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=800&h=400&q=85",
        "https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?auto=format&fit=crop&w=800&h=400&q=85",
        "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=800&h=400&q=85",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Снимка")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(0..<eventPhotos.count, id: \.self) { i in
                                    Button {
                                        withAnimation(OPTheme.quickSpring) { selectedPhotoIndex = i }
                                    } label: {
                                        AsyncImage(url: URL(string: eventPhotos[i])) { phase in
                                            if let image = phase.image {
                                                image.resizable().scaledToFill()
                                            } else {
                                                Rectangle().fill(OPTheme.surfaceSunken)
                                            }
                                        }
                                        .frame(width: 100, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(selectedPhotoIndex == i ? OPTheme.mint : .clear, lineWidth: 3)
                                        )
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Заглавие")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Име на събитието", text: $title)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Какво ще правим?", text: $description, axis: .vertical)
                            .font(.system(size: 16))
                            .lineLimit(3...5)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Дата и час")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Локация")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Къде ще се проведе?", text: $location)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Максимум участници")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        Stepper(value: $maxAttendees, in: 2...50) {
                            HStack {
                                Image(systemName: "person.2.fill").foregroundStyle(OPTheme.mint)
                                Text("\(maxAttendees) кучета")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(OPTheme.text)
                            }
                        }
                        .padding(14)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Ново събитие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Създай") {
                        createEvent()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(title.isEmpty ? OPTheme.textTertiary : OPTheme.primary)
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func createEvent() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "bg_BG")
        formatter.dateFormat = "d"
        let dayNum = formatter.string(from: date)
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "EEE d MMM, HH:mm"
        let dateTimeText = formatter.string(from: date)

        let event = DogEvent(
            id: UUID().uuidString, title: title,
            dayNumber: dayNum, monthLabel: month,
            dateTimeText: dateTimeText,
            location: location.isEmpty ? "Не е посочена" : location,
            attending: 1, capacity: maxAttendees,
            description: description.isEmpty ? nil : description,
            photoURL: eventPhotos[selectedPhotoIndex]
        )
        store.addEvent(event)
    }
}
