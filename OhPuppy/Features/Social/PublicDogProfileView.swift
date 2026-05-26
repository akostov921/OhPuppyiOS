import SwiftUI

// MARK: - NearbyDog Model

struct NearbyDog: Identifiable, Hashable {
    let id: String
    let name: String
    let breed: String
    let age: String
    let ownerName: String
    let ownerUsername: String
    let bio: String
    let photoURL: URL?
    let distance: String
    let followers: Int
    let photos: Int
    let friends: Int
    let tags: [String]
    let isVaccinated: Bool

    var avatarURL: URL? { photoURL }
}

// MARK: - Static Nearby Dogs Data

let nearbyDogsData: [NearbyDog] = [
    NearbyDog(
        id: "nd1",
        name: "Тоби",
        breed: "бордер коли",
        age: "2 години",
        ownerName: "Стефан",
        ownerUsername: "stefan_iv",
        bio: "Обичам тенис топки и плуване \u{1F30A}",
        photoURL: URL(string: "https://images.unsplash.com/photo-1551717743-49959800b1f6?auto=format&fit=crop&w=400&h=400&q=85"),
        distance: "250м",
        followers: 142,
        photos: 38,
        friends: 12,
        tags: ["Приятелски", "Обича вода", "Енергичен"],
        isVaccinated: true
    ),
    NearbyDog(
        id: "nd2",
        name: "Мила",
        breed: "корги",
        age: "3 години",
        ownerName: "Дези",
        ownerUsername: "desi_m",
        bio: "Малка но mighty \u{1F4AA}",
        photoURL: URL(string: "https://images.unsplash.com/photo-1612536057832-2ff7ead58194?auto=format&fit=crop&w=400&h=400&q=85"),
        distance: "400м",
        followers: 89,
        photos: 24,
        friends: 8,
        tags: ["Игрива", "Любопитна", "Обича деца"],
        isVaccinated: true
    ),
    NearbyDog(
        id: "nd3",
        name: "Чарли",
        breed: "хъски",
        age: "4 години",
        ownerName: "Гери",
        ownerUsername: "gery_e",
        bio: "Виждаме се на Витоша!",
        photoURL: URL(string: "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=400&h=400&q=85"),
        distance: "1.2км",
        followers: 215,
        photos: 56,
        friends: 19,
        tags: ["Активен", "Обича сняг", "Независим"],
        isVaccinated: true
    ),
    NearbyDog(
        id: "nd4",
        name: "Кокчо",
        breed: "шпиц",
        age: "1 година",
        ownerName: "Иван",
        ownerUsername: "ivan_k",
        bio: "Шпицът който мисли че е голям \u{1F624}",
        photoURL: URL(string: "https://images.unsplash.com/photo-1568393691080-7d191a564ef8?auto=format&fit=crop&w=400&h=400&q=85"),
        distance: "800м",
        followers: 56,
        photos: 15,
        friends: 5,
        tags: ["Смел", "Лаещ", "Очарователен"],
        isVaccinated: false
    ),
]

// MARK: - Public Dog Profile View

struct PublicDogProfileView: View {
    let dog: NearbyDog
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var isFollowing = false
    @State private var showMessageSent = false
    @State private var showPlaydateConfirm = false
    @State private var showMoreActions = false
    @State private var selectedPhotoId: String = ""
    @State private var showPhotoDetail = false
    @State private var showChatRoom = false
    @State private var showWalkOfferSheet = false

    private let gridPhotos = [
        "1543466835-00a7907e9de1", "1587300003388-59208cc962cb", "1561037404-61cd46aa615b",
        "1583337130417-3346a1be7dee", "1450778869180-41d0601e046e", "1444212477490-ca407925329e",
        "1601758228041-f3b2795255f1", "1568572933382-74d440642117", "1583511655857-d19b40a7a54e"
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                heroSection
                profileInfo
                statsRow
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                actionButtons
                    .padding(.bottom, 24)
                ownerSection
                    .padding(.bottom, 24)
                photoGrid
                    .padding(.bottom, 24)
                infoSection
                    .padding(.bottom, 60)
            }
        }
        .background(OPTheme.bg)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .alert("Playdate", isPresented: $showPlaydateConfirm) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Поканата е изпратена на \(dog.name)! Ще получиш известие когато стопанинът потвърди.")
        }
        .alert("Съобщение", isPresented: $showMessageSent) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Съобщението е изпратено на @\(dog.ownerUsername)")
        }
        .confirmationDialog("Опции", isPresented: $showMoreActions, titleVisibility: .visible) {
            Button("Докладвай профил", role: .destructive) { }
            Button("Блокирай", role: .destructive) { }
            Button("Сподели профил") { }
            Button("Отказ", role: .cancel) { }
        }
        .sheet(isPresented: $showPhotoDetail) {
            PhotoDetailSheet(photoId: selectedPhotoId)
        }
        .sheet(isPresented: $showWalkOfferSheet) {
            WalkOfferSheet(dog: dog)
        }
        .navigationDestination(isPresented: $showChatRoom) {
            ChatRoomView(chat: ChatPreview(
                name: "\(dog.ownerName) (\(dog.name))",
                avatarURL: dog.photoURL?.absoluteString ?? "",
                lastMessage: "",
                time: "сега",
                unread: 0,
                isOnline: true,
                isGroup: false
            ))
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .top) {
            // Cover photo
            AsyncImage(url: dog.photoURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(OPTheme.surfaceSunken)
                }
            }
            .frame(height: 280)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, .clear, OPTheme.bg.opacity(0.6), OPTheme.bg],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 160)
            }

            // Top buttons
            HStack {
                // Back button - glassmorphism
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.2), lineWidth: 1))
                }

                Spacer()

                // More button
                Button { showMoreActions = true } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.top, 56)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Profile Info

    private var profileInfo: some View {
        VStack(spacing: 12) {
            // Avatar with gradient ring, overlapping into hero
            AsyncImage(url: dog.photoURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle().fill(OPTheme.surfaceSunken)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(OPTheme.mint)
                        }
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(OPTheme.avatarRingGradient, lineWidth: 4)
                    .frame(width: 98, height: 98)
            }
            .background(
                Circle()
                    .fill(OPTheme.bg)
                    .frame(width: 104, height: 104)
            )
            .offset(y: -45)

            // Name
            VStack(spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(dog.name)
                        .font(.system(size: 34, weight: .bold))
                        .tracking(-1)
                    Text(".")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(OPTheme.mint)
                }
                .foregroundStyle(OPTheme.text)

                // Breed + Age
                HStack(spacing: 4) {
                    Text(dog.breed)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .italic()
                    Text("\u{00B7}")
                    Text(dog.age)
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(OPTheme.textSecondary)

                // Owner
                Text("@\(dog.ownerUsername) \u{00B7} \(dog.ownerName)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.mint)

                // Bio
                if !dog.bio.isEmpty {
                    Text(dog.bio)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(OPTheme.text)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .offset(y: -35)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, -30)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(dog.followers)", label: "последователи")
            Divider().frame(height: 30)
            statItem(value: "\(dog.photos)", label: "снимки")
            Divider().frame(height: 30)
            statItem(value: "\(dog.friends)", label: "приятели")
        }
        .padding(.vertical, 12)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // Follow button
                Button {
                    withAnimation(OPTheme.quickSpring) { isFollowing.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isFollowing ? "checkmark" : "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text(isFollowing ? "Следваш" : "Следвай")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(isFollowing ? OPTheme.primary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        isFollowing ? AnyShapeStyle(OPTheme.primarySoft) : AnyShapeStyle(OPTheme.primaryGradient),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                }
                .sensoryFeedback(.impact, trigger: isFollowing)

                // Message button
                Button {
                    showChatRoom = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Съобщение")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(OPTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(OPTheme.border, lineWidth: 1)
                    )
                }
            }

            // Playdate button
            Button {
                showPlaydateConfirm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Покани за Playdate")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(OPTheme.mint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(OPTheme.mint.opacity(0.5), lineWidth: 1.5)
                )
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Owner Section

    @ViewBuilder
    private var ownerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            OPSectionHeader(title: "Стопанин")
                .padding(.horizontal, OPTheme.screenPadding)

            HStack(spacing: 14) {
                Circle()
                    .fill(OPTheme.mintGradient)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Text(String(dog.ownerName.prefix(1)))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(dog.ownerName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("@\(dog.ownerUsername)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }

                Spacer()
            }
            .padding(14)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .padding(.horizontal, OPTheme.screenPadding)

            if store.activeRole == .walker {
                Button {
                    showWalkOfferSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Предложи разходка")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .shadow(color: OPTheme.sky.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, OPTheme.screenPadding)
            }
        }
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            OPSectionHeader(title: "Снимки")
                .padding(.horizontal, OPTheme.screenPadding)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 4),
                GridItem(.flexible(), spacing: 4),
                GridItem(.flexible(), spacing: 4)
            ], spacing: 4) {
                ForEach(gridPhotos, id: \.self) { photoId in
                    Button {
                        selectedPhotoId = photoId
                        showPhotoDetail = true
                    } label: {
                        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-\(photoId)?auto=format&fit=crop&w=300&h=300&q=85")) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Rectangle().fill(OPTheme.surfaceSunken)
                                    .overlay { ProgressView().tint(OPTheme.mint) }
                            }
                        }
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            OPSectionHeader(title: "За \(dog.name)")
                .padding(.horizontal, OPTheme.screenPadding)

            VStack(spacing: 12) {
                infoRow(icon: "pawprint.fill", label: "Порода", value: dog.breed)
                infoRow(icon: "calendar", label: "Възраст", value: dog.age)
                infoRow(icon: "location.fill", label: "Локация", value: "София \u{00B7} \(dog.distance) от теб")
                infoRow(icon: "cross.vial.fill", label: "Ваксини", value: dog.isVaccinated ? "актуални \u{2705}" : "неизвестно")
            }
            .padding(16)
            .background(OPTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .padding(.horizontal, OPTheme.screenPadding)

            // Tags
            FlowLayout(spacing: 8) {
                ForEach(dog.tags, id: \.self) { tag in
                    tagPill(tag)
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(OPTheme.mint)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(OPTheme.text)
        }
    }

    private func tagPill(_ text: String) -> some View {
        let colors: [Color] = [OPTheme.mint, OPTheme.accent, OPTheme.sky, OPTheme.rose, OPTheme.success]
        let color = colors[abs(text.hashValue) % colors.count]
        return Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Walk Offer Sheet

struct WalkOfferSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let dog: NearbyDog
    @State private var duration = 60
    @State private var price = "25"
    @State private var note = ""
    @State private var showSuccess = false

    private let durations = [30, 45, 60, 90]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Dog + owner info
                    HStack(spacing: 12) {
                        DogAvatar(url: dog.photoURL, size: 52, showRing: true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(dog.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(OPTheme.text)
                            Text("Стопанин: \(dog.ownerName)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OPTheme.border, lineWidth: 1))

                    // Duration picker
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
                                        .background(
                                            duration == d ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        )
                                }
                            }
                        }
                    }

                    // Price
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Цена (лв)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        TextField("25", text: $price)
                            .font(.system(size: 16, weight: .medium))
                            .keyboardType(.decimalPad)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Бележка (по желание)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                        TextField("Имам опит с тази порода...", text: $note, axis: .vertical)
                            .font(.system(size: 14))
                            .lineLimit(2...4)
                            .padding(12)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    // Submit
                    Button {
                        let priceVal = Double(price) ?? 25.0
                        let req = WalkRequest(
                            id: store.newId(),
                            walkerId: "self",
                            walkerName: store.ownerName,
                            walkerPhotoURL: nil,
                            walkerBadge: store.currentWalkerBadge,
                            dogId: dog.id,
                            dogName: dog.name,
                            date: Date().addingTimeInterval(3600),
                            duration: duration,
                            note: note,
                            price: priceVal,
                            status: .pending,
                            createdAt: Date()
                        )
                        store.submitWalkOffer(req)
                        showSuccess = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Изпрати предложение")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .shadow(color: OPTheme.sky.opacity(0.3), radius: 8, y: 4)
                    }
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Предложи разходка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
            .alert("Предложението е изпратено!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Стопанинът на \(dog.name) ще получи известие. Очаквай отговор скоро!")
            }
        }
    }
}

// MARK: - Photo Detail Sheet

struct PhotoDetailSheet: View {
    let photoId: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-\(photoId)?auto=format&fit=crop&w=800&h=800&q=85")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        ProgressView().tint(.white)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Затвори") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
