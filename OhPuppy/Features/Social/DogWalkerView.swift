import SwiftUI

// MARK: - Dog Walker Model

struct DogWalker: Identifiable, Hashable {
    let id: String
    let name: String
    let rating: Double
    let reviews: Int
    let pricePerWalk: Int
    let distance: String
    let photoURL: String
    let tags: [String]
    let bio: String
    let services: [WalkerService]
    let reviewsList: [WalkerReview]
}

struct WalkerService: Hashable {
    let name: String
    let duration: String
    let price: Int
}

struct WalkerReview: Identifiable, Hashable {
    let id: String
    let author: String
    let rating: Int
    let text: String
    let date: String
}

// MARK: - Dog Walker View

struct DogWalkerView: View {
    @State private var searchText = ""
    @State private var selectedWalker: DogWalker?

    private let walkers: [DogWalker] = [
        DogWalker(
            id: "w1",
            name: "Иван Петров",
            rating: 4.9,
            reviews: 47,
            pricePerWalk: 15,
            distance: "800 м от теб",
            photoURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&h=200&q=85",
            tags: ["Опит с големи породи", "Сертифициран"],
            bio: "Професионален разходчик с 5 години опит. Обичам всички кучета, но имам специална връзка с по-големите породи. Разходките включват игри и тренировка на базови команди.",
            services: [
                WalkerService(name: "Кратка разходка", duration: "30 мин", price: 15),
                WalkerService(name: "Дълга разходка", duration: "60 мин", price: 25),
                WalkerService(name: "Групова разходка", duration: "45 мин", price: 10),
            ],
            reviewsList: [
                WalkerReview(id: "r1", author: "Мария К.", rating: 5, text: "Иван е невероятен! Рекс винаги е щастлив след разходка с него.", date: "15 май 2026"),
                WalkerReview(id: "r2", author: "Петър Д.", rating: 5, text: "Много отговорен, изпраща снимки по време на разходката.", date: "10 май 2026"),
                WalkerReview(id: "r3", author: "Ана С.", rating: 4, text: "Добър контакт с кучето, препоръчвам!", date: "3 май 2026"),
            ]
        ),
        DogWalker(
            id: "w2",
            name: "Дези Маркова",
            rating: 4.7,
            reviews: 23,
            pricePerWalk: 12,
            distance: "1.2 км от теб",
            photoURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&h=200&q=85",
            tags: ["Ветеринарно образование", "Малки породи"],
            bio: "Студентка по ветеринарна медицина. Разходките с мен са безопасни и забавни. Специализирам се в малки и средни породи. Мога да дам и базови здравни съвети.",
            services: [
                WalkerService(name: "Кратка разходка", duration: "30 мин", price: 12),
                WalkerService(name: "Дълга разходка", duration: "60 мин", price: 20),
                WalkerService(name: "Дневна грижа", duration: "4 часа", price: 40),
            ],
            reviewsList: [
                WalkerReview(id: "r4", author: "Георги М.", rating: 5, text: "Дези забеляза, че кучето ми куца леко и ни посъветва да отидем на ветеринар. Благодаря!", date: "12 май 2026"),
                WalkerReview(id: "r5", author: "Елена Т.", rating: 5, text: "Нежна и внимателна с малкото ми чихуахуа.", date: "8 май 2026"),
                WalkerReview(id: "r6", author: "Димитър К.", rating: 4, text: "Надеждна и точна. Луна обича разходките с нея.", date: "1 май 2026"),
            ]
        ),
        DogWalker(
            id: "w3",
            name: "Стефан Иванов",
            rating: 4.8,
            reviews: 35,
            pricePerWalk: 20,
            distance: "400 м от теб",
            photoURL: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&h=200&q=85",
            tags: ["Тренировка", "Опит с агресивни кучета"],
            bio: "Кинолог с 8 години опит. Всяка разходка включва елементи на обучение. Работя с кучета с поведенчески проблеми. Гарантирам безопасност и прогрес.",
            services: [
                WalkerService(name: "Кратка разходка + тренировка", duration: "45 мин", price: 20),
                WalkerService(name: "Интензивна разходка", duration: "90 мин", price: 35),
                WalkerService(name: "Групова тренировка", duration: "60 мин", price: 15),
            ],
            reviewsList: [
                WalkerReview(id: "r7", author: "Ивайло Р.", rating: 5, text: "Стефан промени поведението на кучето ми за 2 седмици! Невероятен професионалист.", date: "14 май 2026"),
                WalkerReview(id: "r8", author: "Надежда В.", rating: 5, text: "Кучето ми вече не дърпа каишката. Благодаря, Стефан!", date: "9 май 2026"),
                WalkerReview(id: "r9", author: "Калин С.", rating: 4, text: "Малко по-скъпо, но си заслужава заради тренировката.", date: "28 апр 2026"),
                WalkerReview(id: "r10", author: "Силвия Б.", rating: 5, text: "Отлична комуникация и резултати.", date: "20 апр 2026"),
            ]
        ),
    ]

    var filteredWalkers: [DogWalker] {
        if searchText.isEmpty { return walkers }
        return walkers.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Header
                header
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                // Search
                searchBar
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 16)

                // Walker cards
                ForEach(filteredWalkers) { walker in
                    NavigationLink(destination: DogWalkerDetailView(walker: walker)) {
                        walkerCard(walker)
                    }
                    .buttonStyle(PressableCardStyle())
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 12)
                }
            }
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Разходчици")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("\(walkers.count) разходчика наблизо")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }
            Spacer()
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(OPTheme.mint)
                .frame(width: 40, height: 40)
                .background(OPTheme.mintSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(OPTheme.textTertiary)
            TextField("Търси разходчик...", text: $searchText)
                .font(.system(size: 15, weight: .medium))
        }
        .padding(12)
        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Walker Card

    private func walkerCard(_ walker: DogWalker) -> some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: walker.photoURL)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle().fill(OPTheme.surfaceSunken)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(walker.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(OPTheme.accent)
                        Text(String(format: "%.1f", walker.rating))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("(\(walker.reviews))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "banknote")
                            .font(.system(size: 11))
                        Text("\(walker.pricePerWalk) лв / разходка")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(OPTheme.mint)

                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(walker.distance)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(OPTheme.textSecondary)
                }

                // Tags
                HStack(spacing: 6) {
                    ForEach(walker.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(OPTheme.sky)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(OPTheme.skySoft, in: Capsule())
                    }
                }
            }
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
    }
}

// MARK: - Dog Walker Detail View

struct DogWalkerDetailView: View {
    let walker: DogWalker
    @Environment(\.dismiss) private var dismiss
    @State private var showBookingConfirmation = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Hero section
                heroSection
                    .padding(.bottom, 20)

                // Bio
                bioSection
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 24)

                // Services
                servicesSection
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 24)

                // Reviews
                reviewsSection
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 24)

                // Book button
                Button {
                    showBookingConfirmation = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 15))
                        Text("Резервирай")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: OPTheme.mint.opacity(0.3), radius: 10, y: 4)
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .alert("Резервацията е потвърдена!", isPresented: $showBookingConfirmation) {
            Button("Чудесно", role: .cancel) { }
        } message: {
            Text("Ще получиш потвърждение от \(walker.name) в рамките на 1 час.")
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: walker.photoURL)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(OPTheme.surfaceSunken)
                }
            }
            .frame(height: 280)
            .clipped()
            .overlay {
                LinearGradient(
                    colors: [.clear, .clear, OPTheme.bg.opacity(0.5), OPTheme.bg],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            // Back button
            BackButton()
                .padding(.top, 56)
                .padding(.leading, 16)

            // Name overlay at bottom
            VStack(alignment: .leading, spacing: 6) {
                Spacer()
                Text(walker.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(OPTheme.accent)
                        Text(String(format: "%.1f", walker.rating))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("(\(walker.reviews) отзива)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                        Text(walker.distance)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(OPTheme.mint)
                }
            }
            .padding(OPTheme.screenPadding)
        }
    }

    // MARK: - Bio

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("За мен")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text(walker.bio)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(OPTheme.textSecondary)
                .lineSpacing(3)
        }
    }

    // MARK: - Services

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Услуги")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)

            ForEach(walker.services, id: \.name) { service in
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(service.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                        Text(service.duration)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    Spacer()
                    Text("\(service.price) лв")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.mint)
                }
                .padding(14)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(OPTheme.border, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Отзиви")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)

            ForEach(walker.reviewsList) { review in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(review.author)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0..<review.rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(OPTheme.accent)
                            }
                            ForEach(0..<(5 - review.rating), id: \.self) { _ in
                                Image(systemName: "star")
                                    .font(.system(size: 10))
                                    .foregroundStyle(OPTheme.textTertiary)
                            }
                        }
                    }
                    Text(review.text)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(OPTheme.textSecondary)
                    Text(review.date)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }
                .padding(14)
                .background(OPTheme.surfaceSecondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
