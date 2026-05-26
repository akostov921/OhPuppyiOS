import SwiftUI

// MARK: - Walker Profile

struct WalkerProfileView: View {
    @Environment(AppStore.self) private var store
    let name: String
    let photoURL: String?
    let rating: Double
    let reviewCount: Int
    let walksCount: Int
    let badge: WalkerBadge
    let pricePerWalk: Int
    let walkerId: String
    @State private var showBooking = false

    private var badgeColor: Color {
        switch badge {
        case .legend: Color(hex: "FFD700")
        case .expert: Color(hex: "8B5CF6")
        case .popular: OPTheme.accent
        case .reliable: OPTheme.sky
        case .newcomer: OPTheme.mint
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                heroSection
                statsRow
                aboutSection
                availabilitySection
                reviewsSection
                bookButton
            }
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBooking) {
            WalkRequestSheet(walkerName: name, walkerPhotoURL: photoURL, walkerBadge: badge, walkerId: walkerId, pricePerWalk: pricePerWalk)
        }
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                if let url = photoURL {
                    AsyncImage(url: URL(string: url)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(OPTheme.surfaceSunken)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(badgeColor, lineWidth: 3))
                } else {
                    Circle().fill(OPTheme.surfaceSunken)
                        .frame(width: 100, height: 100)
                        .overlay {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 36))
                                .foregroundStyle(OPTheme.mint)
                        }
                }
                Image(systemName: badge.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(badgeColor, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .offset(x: 4, y: 4)
            }

            Text(name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(OPTheme.text)

            HStack(spacing: 4) {
                Image(systemName: badge.icon)
                    .font(.system(size: 12, weight: .bold))
                Text(badge.label)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(badgeColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(badgeColor.opacity(0.12), in: Capsule())

            HStack(spacing: 3) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: Double(i) <= rating ? "star.fill" : (Double(i) - 0.5 <= rating ? "star.leadinghalf.filled" : "star"))
                        .font(.system(size: 14))
                        .foregroundStyle(OPTheme.accent)
                }
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("(\(reviewCount) отзива)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }
        }
        .padding(.top, 12)
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statBox(value: "\(walksCount)", label: "Разходки", color: OPTheme.sky)
            statBox(value: "\(reviewCount)", label: "Ревюта", color: OPTheme.accent)
            statBox(value: "\(pricePerWalk) лв", label: "На разходка", color: OPTheme.mint)
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("За мен")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text("Сертифициран разходчик с над 3 години опит и стотици доволни четириноги клиенти. Работя с всякакви породи и размери. По време на всяка разходка изпращам снимки и GPS маршрут. Познавам най-добрите паркове и тихи маршрути в града. Безопасността и доброто настроение на кучето са ми приоритет номер едно.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(OPTheme.textSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Наличност")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
            let days = ["Пон", "Вт", "Ср", "Чет", "Пет", "Съб", "Нед"]
            let available = [true, true, true, true, true, false, true]
            let slots = ["Сутрин", "Обед", "Вечер"]
            let slotAvail = [[true, true, false], [true, false, true], [true, true, false], [false, true, true], [true, true, true], [false, false, false], [true, false, false]]

            LazyVGrid(columns: [GridItem(.fixed(50))] + days.map { _ in GridItem(.flexible()) }, spacing: 6) {
                Text("")
                ForEach(0..<days.count, id: \.self) { i in
                    Text(days[i])
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(available[i] ? OPTheme.text : OPTheme.textTertiary)
                }
                ForEach(0..<slots.count, id: \.self) { s in
                    Text(slots[s])
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                    ForEach(0..<days.count, id: \.self) { d in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(slotAvail[d][s] ? OPTheme.mint.opacity(0.3) : OPTheme.surfaceSunken)
                            .frame(height: 20)
                            .overlay {
                                if slotAvail[d][s] {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(OPTheme.mint)
                                }
                            }
                    }
                }
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Отзиви")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)

            let mockReviews: [(name: String, dog: String, stars: Int, text: String, ago: String)] = [
                ("Мария К.", "Бъди", 5, "Перфектна разходка! Изпращаше снимки.", "1 ден"),
                ("Иван П.", "Лора", 4, "Много внимателен, ще ползваме пак.", "3 дни"),
                ("Десислава М.", "Чарли", 5, "Чарли го обожава!", "5 дни"),
            ]

            ForEach(mockReviews, id: \.name) { r in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(r.name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        Text("с \(r.dog)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                        Spacer()
                        HStack(spacing: 1) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= r.stars ? "star.fill" : "star")
                                    .font(.system(size: 9))
                                    .foregroundStyle(i <= r.stars ? OPTheme.accent : OPTheme.textTertiary)
                            }
                        }
                    }
                    Text(r.text)
                        .font(.system(size: 13))
                        .foregroundStyle(OPTheme.textSecondary)
                    Text("преди \(r.ago)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }
                .padding(12)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private var bookButton: some View {
        Button { showBooking = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 15, weight: .semibold))
                Text("Изпрати заявка за разходка")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: OPTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }
}

// MARK: - Walk Request Sheet

struct WalkRequestSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let walkerName: String
    let walkerPhotoURL: String?
    let walkerBadge: WalkerBadge
    let walkerId: String
    let pricePerWalk: Int
    @State private var selectedDogIndex = 0
    @State private var date = Date().addingTimeInterval(3600)
    @State private var duration = 60
    @State private var note = ""
    @State private var showSuccess = false
    private let durations = [30, 45, 60, 90]

    private var totalPrice: Double {
        Double(pricePerWalk) * (Double(duration) / 60.0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    walkerHeader
                    dogPicker
                    dateSection
                    durationPicker
                    noteSection
                    priceSummary
                    submitButton
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Заявка за разходка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
            .alert("Заявката е изпратена!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("\(walkerName) ще потвърди до 30 минути. Ще получиш известие.")
            }
        }
    }

    private var walkerHeader: some View {
        HStack(spacing: 12) {
            if let url = walkerPhotoURL {
                AsyncImage(url: URL(string: url)) { phase in
                    if let image = phase.image { image.resizable().scaledToFill() }
                    else { Circle().fill(OPTheme.surfaceSunken) }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(walkerName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 4) {
                    Image(systemName: walkerBadge.icon)
                        .font(.system(size: 10))
                    Text(walkerBadge.label)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(OPTheme.accent)
            }
            Spacer()
        }
        .padding(12)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private var dogPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Избери куче")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(OPTheme.text)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(store.dogs.enumerated()), id: \.element.id) { idx, dog in
                        Button {
                            withAnimation(OPTheme.quickSpring) { selectedDogIndex = idx }
                        } label: {
                            VStack(spacing: 6) {
                                DogAvatar(url: dog.avatarURL, size: 52, showRing: selectedDogIndex == idx)
                                Text(dog.name)
                                    .font(.system(size: 12, weight: selectedDogIndex == idx ? .bold : .medium))
                                    .foregroundStyle(selectedDogIndex == idx ? OPTheme.primary : OPTheme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Дата и час")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(OPTheme.text)
            DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .datePickerStyle(.compact)
        }
    }

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Продължителност")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(OPTheme.text)
            HStack(spacing: 8) {
                ForEach(durations, id: \.self) { d in
                    Button {
                        withAnimation(OPTheme.quickSpring) { duration = d }
                    } label: {
                        Text("\(d) мин")
                            .font(.system(size: 14, weight: duration == d ? .bold : .medium))
                            .foregroundStyle(duration == d ? .white : OPTheme.text)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(duration == d ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Бележка (по желание)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(OPTheme.text)
            TextField("Рекс дърпа каишката, внимавай с други кучета...", text: $note, axis: .vertical)
                .font(.system(size: 14))
                .lineLimit(2...4)
                .padding(12)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var priceSummary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Цена")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                Text("\(pricePerWalk) лв/ч x \(duration) мин")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textTertiary)
            }
            Spacer()
            Text(String(format: "%.0f лв", totalPrice))
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(OPTheme.primary)
        }
        .padding(14)
        .background(OPTheme.primarySoft.opacity(0.3), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var submitButton: some View {
        Button {
            let dog = store.dogs[safe: selectedDogIndex] ?? store.dogs.first!
            let req = WalkRequest(id: store.newId(), walkerId: walkerId, walkerName: walkerName, walkerPhotoURL: walkerPhotoURL, walkerBadge: walkerBadge, dogId: dog.id, dogName: dog.name, date: date, duration: duration, note: note, price: totalPrice, status: .pending, createdAt: Date())
            store.submitWalkRequest(req)
            showSuccess = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text("Изпрати заявка")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: OPTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
    }
}

// MARK: - Walk Review Sheet

struct WalkReviewSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let walk: WalkRequest
    @State private var rating = 5
    @State private var comment = ""
    @State private var confirmed = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(OPTheme.mintGradient)
                    Text("Разходката приключи!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("\(walk.walkerName) разходи \(walk.dogName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(.top, 12)

                VStack(spacing: 8) {
                    Text("Как беше разходката?")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { i in
                            Button {
                                withAnimation(OPTheme.quickSpring) { rating = i }
                            } label: {
                                Image(systemName: i <= rating ? "star.fill" : "star")
                                    .font(.system(size: 32))
                                    .foregroundStyle(i <= rating ? OPTheme.accent : OPTheme.textTertiary)
                            }
                        }
                    }
                }

                TextField("Напиши коментар...", text: $comment, axis: .vertical)
                    .font(.system(size: 15))
                    .lineLimit(3...5)
                    .padding(14)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(OPTheme.success)
                    Text("Парите (\(String(format: "%.0f лв", walk.price))) ще бъдат преведени на \(walk.walkerName) след потвърждение.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                Button {
                    store.confirmWalkDone(id: walk.id)
                    if !comment.isEmpty || rating > 0 {
                        store.submitWalkReview(walkId: walk.id, walkerId: walk.walkerId, rating: rating, comment: comment)
                    }
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15))
                        Text("Потвърди и изпрати")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: OPTheme.mint.opacity(0.3), radius: 10, y: 4)
                }
            }
            .padding(OPTheme.screenPadding)
            .background(OPTheme.bg)
            .navigationTitle("Оценка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Затвори") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Safe Array Access

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
