import SwiftUI

// MARK: - Playdate Dog Model

struct PlaydateDog: Identifiable {
    let id: String
    let name: String
    let breed: String
    let age: String
    let distance: String
    let compatibility: Int
    let photoURL: String
    let tags: [String]
}

// MARK: - Playdate View

struct PlaydateView: View {
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showInviteSent = false
    @State private var cardRotation: Double = 0
    @State private var inviteParticles: [ConfettiParticle] = []
    @State private var showFilterSheet = false

    private let dogs: [PlaydateDog] = [
        PlaydateDog(id: "pd1", name: "Тоби", breed: "Бордер коли", age: "2г", distance: "250м", compatibility: 92, photoURL: "https://images.unsplash.com/photo-1551717743-49959800b1f6?auto=format&fit=crop&w=600&h=800&q=85", tags: ["Същия размер", "Сходна енергия", "Приятелски"]),
        PlaydateDog(id: "pd2", name: "Мила", breed: "Корги", age: "3г", distance: "400м", compatibility: 85, photoURL: "https://images.unsplash.com/photo-1612536057832-2ff7ead58194?auto=format&fit=crop&w=600&h=800&q=85", tags: ["Сходна енергия", "Приятелски"]),
        PlaydateDog(id: "pd3", name: "Чарли", breed: "Хъски", age: "4г", distance: "1.2км", compatibility: 78, photoURL: "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=600&h=800&q=85", tags: ["Същия размер", "Активен"]),
        PlaydateDog(id: "pd4", name: "Бела", breed: "Лабрадор", age: "1г", distance: "800м", compatibility: 95, photoURL: "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=600&h=800&q=85", tags: ["Същия размер", "Сходна енергия", "Приятелски"]),
    ]

    var body: some View {
        ZStack {
            OPTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                if currentIndex < dogs.count {
                    // Card stack
                    ZStack {
                        // Next card preview (behind)
                        if currentIndex + 1 < dogs.count {
                            dogCard(dogs[currentIndex + 1])
                                .scaleEffect(0.92)
                                .offset(y: 12)
                                .opacity(0.5)
                        }

                        // Current card
                        dogCard(dogs[currentIndex])
                            .offset(dragOffset)
                            .rotationEffect(.degrees(cardRotation))
                            .gesture(dragGesture)
                            .animation(OPTheme.springAnimation, value: dragOffset)
                    }
                    .padding(.horizontal, OPTheme.screenPadding)

                    Spacer()

                    // Action buttons
                    actionButtons
                        .padding(.bottom, 30)
                } else {
                    // All cards viewed
                    allViewedState
                }
            }

            // Invite sent overlay
            if showInviteSent {
                inviteSentOverlay
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFilterSheet) {
            PlaydateFilterSheet()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Playdate")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(OPTheme.rose)
                        .symbolEffect(.pulse)
                }
                Text("\(dogs.count) кучета търсят приятел")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }
            Spacer()
            Button { showFilterSheet = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(OPTheme.rose)
                    .frame(width: 40, height: 40)
                    .background(OPTheme.roseSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    // MARK: - Dog Card

    private func dogCard(_ dog: PlaydateDog) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: dog.photoURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(OPTheme.surfaceSunken)
                    }
                }
                .frame(height: 360)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [.clear, .clear, OPTheme.text.opacity(0.6), OPTheme.text.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

                // Info overlay on photo
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dog.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            Text("\(dog.breed) \u{00B7} \(dog.age) \u{00B7} \(dog.distance)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        Spacer()
                        VStack(spacing: 4) {
                            ZStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(
                                        LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .shadow(color: OPTheme.rose.opacity(0.4), radius: 8, y: 2)
                                Text("\(dog.compatibility)")
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundStyle(.white)
                                    .offset(y: -1)
                            }
                            Text("match")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white.opacity(0.8))
                                .textCase(.uppercase)
                                .tracking(1)
                        }
                    }
                }
                .padding(16)
            }

            // Tags area
            VStack(alignment: .leading, spacing: 10) {
                FlowLayout(spacing: 8) {
                    ForEach(dog.tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11))
                            Text(tag)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(OPTheme.mint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(OPTheme.mintSoft, in: Capsule())
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(OPTheme.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
        .shadow(color: OPTheme.primary.opacity(0.12), radius: 16, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 24) {
            Button { skipDog() } label: {
                VStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .frame(width: 60, height: 60)
                        .background(OPTheme.surfaceSunken, in: Circle())
                        .overlay(Circle().stroke(OPTheme.border, lineWidth: 1))
                    Text("Друг път")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }
            }

            Button { inviteDog() } label: {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 72, height: 72)
                            .shadow(color: OPTheme.rose.opacity(0.4), radius: 12, y: 4)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, value: showInviteSent)
                    }
                    Text("Покани")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(OPTheme.rose)
                }
            }

            Button { inviteDog() } label: {
                VStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(OPTheme.accent)
                        .frame(width: 60, height: 60)
                        .background(OPTheme.accentSoft, in: Circle())
                        .overlay(Circle().stroke(OPTheme.accent.opacity(0.3), lineWidth: 1))
                    Text("Супер")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.accent)
                }
            }
        }
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                cardRotation = Double(value.translation.width / 20)
            }
            .onEnded { value in
                if value.translation.width < -120 {
                    skipDog()
                } else if value.translation.width > 120 {
                    inviteDog()
                } else {
                    withAnimation(OPTheme.springAnimation) {
                        dragOffset = .zero
                        cardRotation = 0
                    }
                }
            }
    }

    // MARK: - Actions

    private func skipDog() {
        withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset = CGSize(width: -400, height: 0)
            cardRotation = -15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dragOffset = .zero
            cardRotation = 0
            if currentIndex < dogs.count {
                currentIndex += 1
            }
        }
    }

    private func inviteDog() {
        withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset = CGSize(width: 400, height: 0)
            cardRotation = 15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dragOffset = .zero
            cardRotation = 0
            if currentIndex < dogs.count {
                currentIndex += 1
            }
            withAnimation(OPTheme.springAnimation) {
                showInviteSent = true
            }
            generateConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation {
                    showInviteSent = false
                    inviteParticles = []
                }
            }
        }
    }

    // MARK: - Invite Sent Overlay

    private var inviteSentOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showInviteSent = false }
                }

            VStack(spacing: 16) {
                // Confetti particles
                ZStack {
                    ForEach(inviteParticles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .offset(x: particle.x, y: particle.y)
                            .opacity(particle.opacity)
                    }
                }
                .frame(width: 200, height: 200)

                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(OPTheme.mintGradient)

                Text("Поканата е изпратена!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text("Ще получиш известие, когато бъде приета")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - All Viewed State

    private var allViewedState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "pawprint.fill")
                .font(.system(size: 60))
                .foregroundStyle(OPTheme.mintGradient)
            Text("Няма повече кучета наблизо")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text("Разшири радиуса си или опитай пак по-късно")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
                .multilineTextAlignment(.center)
            Button {
                withAnimation { currentIndex = 0 }
            } label: {
                Text("Покажи отново")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(OPTheme.mintGradient, in: Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Confetti

    private func generateConfetti() {
        var particles: [ConfettiParticle] = []
        let colors: [Color] = [OPTheme.mint, OPTheme.accent, OPTheme.primaryLight, OPTheme.rose, OPTheme.sky]
        for i in 0..<20 {
            let angle = Double.random(in: 0...(2 * .pi))
            let radius = Double.random(in: 30...100)
            particles.append(ConfettiParticle(
                id: "p\(i)",
                x: CGFloat(cos(angle) * radius),
                y: CGFloat(sin(angle) * radius),
                size: CGFloat.random(in: 4...10),
                color: colors.randomElement() ?? OPTheme.mint,
                opacity: Double.random(in: 0.6...1.0)
            ))
        }
        withAnimation(.easeOut(duration: 0.6)) {
            inviteParticles = particles
        }
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id: String
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
    let opacity: Double
}

// MARK: - Playdate Filter Sheet

struct PlaydateFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var maxDistance: Double = 2.0
    @State private var sizeFilter = "Всички"

    private let sizes = ["Всички", "Малки", "Средни", "Големи"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Максимално разстояние")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack {
                        Slider(value: $maxDistance, in: 0.5...10, step: 0.5)
                            .tint(OPTheme.mint)
                        Text("\(String(format: "%.1f", maxDistance)) км")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(OPTheme.mint)
                            .frame(width: 60)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Размер на кучето")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 8) {
                        ForEach(sizes, id: \.self) { size in
                            Button {
                                sizeFilter = size
                            } label: {
                                Text(size)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(sizeFilter == size ? .white : OPTheme.text)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        sizeFilter == size ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                        in: Capsule()
                                    )
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(OPTheme.screenPadding)
            .padding(.top, 12)
            .background(OPTheme.bg)
            .navigationTitle("Филтри")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.primary)
                }
            }
            .presentationDetents([.medium])
        }
    }
}
