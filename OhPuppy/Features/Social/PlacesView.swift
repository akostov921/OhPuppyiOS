import SwiftUI

struct PlacesView: View {
    @State private var selectedCategory = "Всички"
    @State private var selectedPlace: DogPlace?

    private let categories = ["Всички", "Кафенета", "Паркове", "Ветеринари", "Хотели"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Места")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Dog-friendly наблизо")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 14)

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                withAnimation(OPTheme.quickSpring) { selectedCategory = cat }
                            } label: {
                                Text(cat)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(selectedCategory == cat ? .white : OPTheme.text)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == cat ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                        in: Capsule()
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, OPTheme.screenPadding)
                }
                .padding(.bottom, 16)

                // Places list
                VStack(spacing: 12) {
                    ForEach(filteredPlaces) { place in
                        NavigationLink(destination: PlaceDetailView(place: place)) {
                            placeCard(place)
                        }
                        .buttonStyle(PressableCardStyle())
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
    }

    private var filteredPlaces: [DogPlace] {
        if selectedCategory == "Всички" { return mockPlaces }
        return mockPlaces.filter { $0.category == selectedCategory }
    }

    private func placeCard(_ place: DogPlace) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(OPTheme.primarySoft)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: place.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(OPTheme.primary)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("\(place.category) \u{00B7} \(place.distance)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(OPTheme.warning)
                        Text(String(format: "%.1f", place.rating))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                    }
                    StatPill(label: place.isOpen ? "Отворено" : "Затворено", tone: place.isOpen ? .success : .neutral)
                }

                if !place.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(place.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(OPTheme.surfaceSunken, in: Capsule())
                        }
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .padding(14)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
    }

    private var mockPlaces: [DogPlace] {
        [
            DogPlace(id: "p1", name: "Bones & Co", category: "Кафенета", rating: 4.7, distance: "0.4 км", isOpen: true, icon: "cup.and.saucer.fill", tags: ["Куче на масата", "Вода"]),
            DogPlace(id: "p2", name: "Ветеринарна клиника Лапа", category: "Ветеринари", rating: 4.9, distance: "1.2 км", isOpen: true, icon: "cross.case.fill", tags: ["Спешен", "24/7"]),
            DogPlace(id: "p3", name: "Pet Palace Груминг", category: "Кафенета", rating: 4.6, distance: "1.8 км", isOpen: false, icon: "scissors", tags: []),
            DogPlace(id: "p4", name: "Парк Заимов", category: "Паркове", rating: 4.4, distance: "2.1 км", isOpen: true, icon: "tree.fill", tags: ["Без каишка", "Заграждение"]),
            DogPlace(id: "p5", name: "Dog Hotel Sofia", category: "Хотели", rating: 4.3, distance: "3.2 км", isOpen: true, icon: "bed.double.fill", tags: ["Ограден двор"]),
        ]
    }
}

// MARK: - Place Detail View

struct PlaceDetailView: View {
    let place: DogPlace
    @State private var showAddReview = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                // Hero
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(OPTheme.primarySoft)
                        .frame(height: 140)
                        .overlay {
                            Image(systemName: place.icon)
                                .font(.system(size: 48, weight: .semibold))
                                .foregroundStyle(OPTheme.primary)
                        }

                    VStack(spacing: 6) {
                        Text(place.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("\(place.category) \u{00B7} \(place.distance)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                ForEach(0..<5) { i in
                                    Image(systemName: i < Int(place.rating) ? "star.fill" : "star")
                                        .font(.system(size: 14))
                                        .foregroundStyle(OPTheme.warning)
                                }
                                Text(String(format: "%.1f", place.rating))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(OPTheme.text)
                            }
                            StatPill(label: place.isOpen ? "Отворено" : "Затворено", tone: place.isOpen ? .success : .neutral)
                        }
                    }
                }

                // Tags
                if !place.tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(place.tags, id: \.self) { tag in
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(OPTheme.success)
                                Text(tag)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(OPTheme.text)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(OPTheme.successSoft, in: Capsule())
                        }
                    }
                }

                Divider()

                // Reviews section
                HStack {
                    OPSectionHeader(title: "Ревюта")
                    Spacer()
                    Button { showAddReview = true } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text("Добави ревю")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(OPTheme.primaryGradient, in: Capsule())
                    }
                }

                ForEach(mockReviews) { review in
                    reviewRow(review)
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddReview) {
            AddReviewSheet(placeName: place.name)
        }
    }

    private func reviewRow(_ review: PlaceReview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(OPTheme.mintGradient)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Text(String(review.author.prefix(1)))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                VStack(alignment: .leading) {
                    Text(review.author)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < review.rating ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundStyle(OPTheme.warning)
                        }
                    }
                }
                Spacer()
                Text(review.timeAgo)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
            }
            Text(review.text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(OPTheme.text)
                .lineSpacing(2)
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
    }

    private var mockReviews: [PlaceReview] {
        [
            PlaceReview(id: "r1", author: "Мария", rating: 5, text: "Чудесно място! Сервитьорите донесоха купа с вода веднага и подариха лакомство на Рекс.", timeAgo: "преди 2 дни"),
            PlaceReview(id: "r2", author: "Стефан", rating: 4, text: "Уютна тераса с добра сянка. Кучетата са добре дошли навсякъде.", timeAgo: "преди 1 седм."),
            PlaceReview(id: "r3", author: "Ана", rating: 5, text: "Любимото ни кафене! Мила обожава да идва тук.", timeAgo: "преди 2 седм."),
        ]
    }
}

// MARK: - Add Review Sheet

struct AddReviewSheet: View {
    let placeName: String
    @Environment(\.dismiss) private var dismiss
    @State private var rating = 5
    @State private var text = ""
    @State private var selectedTags: Set<String> = []

    private let tags = ["Куче на масата", "Купа с вода", "Лакомства", "Сянка", "Тихо", "Място за тичане"]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Place info
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(OPTheme.primarySoft)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(OPTheme.primary)
                            }
                        VStack(alignment: .leading) {
                            Text(placeName)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    // Stars
                    VStack(spacing: 8) {
                        Text("Как ти беше преживяването?")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { rating = star }
                                } label: {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.system(size: 32))
                                        .foregroundStyle(star <= rating ? OPTheme.warning : OPTheme.surfaceSunken)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("КАКВО БЕШЕ ДОБРО?")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        FlowLayout(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                Button {
                                    withAnimation(OPTheme.quickSpring) {
                                        if selectedTags.contains(tag) {
                                            selectedTags.remove(tag)
                                        } else {
                                            selectedTags.insert(tag)
                                        }
                                    }
                                } label: {
                                    let isSelected = selectedTags.contains(tag)
                                    Text(isSelected ? "\u{2713} \(tag)" : tag)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(isSelected ? OPTheme.success : OPTheme.text)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            isSelected ? OPTheme.successSoft : OPTheme.surfaceSunken,
                                            in: Capsule()
                                        )
                                        .overlay(
                                            Capsule().stroke(isSelected ? OPTheme.success.opacity(0.5) : OPTheme.border, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    // Review text
                    VStack(alignment: .leading, spacing: 6) {
                        Text("КАЖИ ПОВЕЧЕ (ПО ИЗБОР)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("Напиши ревю...", text: $text, axis: .vertical)
                            .font(.system(size: 15, weight: .medium))
                            .lineLimit(4...8)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .background(OPTheme.bg)
            .navigationTitle("Ново ревю")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Публикувай") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                }
            }
        }
    }
}

// MARK: - Models

struct DogPlace: Identifiable {
    let id: String
    let name: String
    let category: String
    let rating: Double
    let distance: String
    let isOpen: Bool
    let icon: String
    let tags: [String]
}

struct PlaceReview: Identifiable {
    let id: String
    let author: String
    let rating: Int
    let text: String
    let timeAgo: String
}
