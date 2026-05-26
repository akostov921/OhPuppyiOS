import SwiftUI
import CoreLocation
import UserNotifications

struct OnboardingView: View {
    @Environment(AppStore.self) private var store
    @State private var currentStep = 0
    @State private var pawFloatOffset: CGFloat = 0
    @State private var pawRotation: Double = 0
    @State private var selectedInterests: Set<HomeSection> = Set(HomeSection.allCases)

    private let totalSteps = 4

    var body: some View {
        ZStack {
            OPTheme.bg.ignoresSafeArea()
            floatingPaws

            VStack(spacing: 0) {
                Spacer()

                Group {
                    switch currentStep {
                    case 0: welcomeStep
                    case 1: featuresStep
                    case 2: interestsStep
                    default: permissionsStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()

                progressIndicator
                    .padding(.bottom, 32)

                Button {
                    if currentStep < totalSteps - 1 {
                        withAnimation(OPTheme.springAnimation) {
                            currentStep += 1
                        }
                    } else {
                        finishOnboarding()
                    }
                } label: {
                    Text(buttonTitle)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.primary.opacity(0.3), radius: 10, y: 4)
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pawFloatOffset = -12
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                pawRotation = 360
            }
        }
    }

    private var buttonTitle: String {
        switch currentStep {
        case 0: "Започни"
        case 1: "Продължи"
        case 2: "Продължи"
        default: "Разреши и продължи"
        }
    }

    // MARK: - Floating Background Paws

    private var floatingPaws: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ForEach(0..<6, id: \.self) { i in
                Image(systemName: "pawprint.fill")
                    .font(.system(size: CGFloat([16, 12, 20, 14, 18, 10][i])))
                    .foregroundStyle(OPTheme.mint.opacity(Double([0.06, 0.04, 0.07, 0.05, 0.06, 0.03][i])))
                    .rotationEffect(.degrees(pawRotation + Double(i * 60)))
                    .offset(
                        x: CGFloat([0.1, 0.8, 0.2, 0.7, 0.5, 0.9][i]) * w - w / 2,
                        y: CGFloat([0.15, 0.25, 0.5, 0.6, 0.8, 0.35][i]) * h - h / 2 + pawFloatOffset * CGFloat([1, -0.7, 0.5, -1, 0.8, -0.6][i])
                    )
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? OPTheme.primary : OPTheme.textTertiary.opacity(0.3))
                    .frame(width: index == currentStep ? 24 : 8, height: 8)
                    .animation(OPTheme.springAnimation, value: currentStep)
            }
        }
    }

    private func finishOnboarding() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }

        let orderedSections = HomeSection.allCases.filter { selectedInterests.contains($0) }
        store.homeSectionOrder = orderedSections.isEmpty ? HomeSection.allCases : orderedSections

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            store.completeOnboarding()
        }
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [OPTheme.mint.opacity(0.15), OPTheme.primaryLight.opacity(0.06), .clear],
                            center: .center, startRadius: 30, endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 220)

                ZStack {
                    // Dog scene: house + dog + sun + tree
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(OPTheme.accent.opacity(0.5))
                        .offset(x: 50, y: -60)
                        .offset(y: pawFloatOffset * -0.3)
                        .symbolEffect(.variableColor)

                    Image(systemName: "tree.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(OPTheme.mint.opacity(0.4))
                        .offset(x: -55, y: 10)
                        .offset(y: pawFloatOffset * 0.2)

                    Image(systemName: "house.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(OPTheme.primary.opacity(0.3))
                        .offset(x: 45, y: 15)
                        .offset(y: pawFloatOffset * 0.15)

                    // Main dog
                    Image(systemName: "dog.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(OPTheme.primaryGradient)
                        .symbolEffect(.breathe)
                        .offset(y: pawFloatOffset * 0.4)

                    // Hearts floating up
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(OPTheme.rose.opacity(0.5))
                        .offset(x: 30, y: -40)
                        .offset(y: pawFloatOffset * -0.6)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(OPTheme.rose.opacity(0.3))
                        .offset(x: -25, y: -50)
                        .offset(y: pawFloatOffset * -0.8)

                    // Paw trail
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(OPTheme.mint.opacity(0.3))
                        .offset(x: -35, y: 40)
                        .rotationEffect(.degrees(-30))

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(OPTheme.mint.opacity(0.2))
                        .offset(x: -55, y: 50)
                        .rotationEffect(.degrees(-30))
                }
            }

            VStack(spacing: 12) {
                (Text("Здравей! Аз съм ")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(OPTheme.text)
                 + Text("Бисквит.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(OPTheme.mint))

                Text("Тук следим ваксини, тегло и\nнамираме нови приятели за разходка.")
                    .font(.system(size: 15, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Step 2: Features (Floating Bubbles)

    private var featuresStep: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Text("Какво можеш")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("с OhPuppy")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.mint)
            }

            ZStack {
                featureBubble(icon: "heart.text.clipboard", color: OPTheme.mint, size: 70, x: -60, y: -50, delay: 0)
                featureBubble(icon: "person.2.fill", color: OPTheme.accent, size: 60, x: 55, y: -30, delay: 0.3)
                featureBubble(icon: "map.fill", color: OPTheme.sky, size: 55, x: -40, y: 40, delay: 0.6)
                featureBubble(icon: "storefront.fill", color: OPTheme.rose, size: 50, x: 50, y: 50, delay: 0.9)
                featureBubble(icon: "pawprint.fill", color: OPTheme.primary, size: 65, x: 0, y: 0, delay: 0.15)
            }
            .frame(height: 180)

            VStack(spacing: 14) {
                featureLabel(icon: "heart.text.clipboard", text: "Здравен дневник", sub: "Ваксини, тегло, грижа", color: OPTheme.mint)
                featureLabel(icon: "person.2.fill", text: "Социална мрежа", sub: "Приятели за разходка", color: OPTheme.accent)
                featureLabel(icon: "storefront.fill", text: "Магазин", sub: "Продукти и услуги", color: OPTheme.rose)
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private let bubblePhotos = [
        "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=150&h=150&q=85",
        "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=150&h=150&q=85",
        "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=150&h=150&q=85",
        "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=150&h=150&q=85",
        "https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=150&h=150&q=85",
    ]

    private func featureBubble(icon: String, color: Color, size: CGFloat, x: CGFloat, y: CGFloat, delay: Double) -> some View {
        let photoIndex = Int(abs(x + y)) % bubblePhotos.count
        return ZStack {
            AsyncImage(url: URL(string: bubblePhotos[photoIndex])) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle().fill(color.opacity(0.15))
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(color.opacity(0.4), lineWidth: 2))

            Circle()
                .fill(color.opacity(0.3))
                .frame(width: size * 0.4, height: size * 0.4)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.18, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: size * 0.3, y: size * 0.3)
        }
        .offset(x: x, y: y + pawFloatOffset * CGFloat(delay + 0.3))
        .shadow(color: color.opacity(0.2), radius: 10, y: 4)
    }

    private func featureLabel(icon: String, text: String, sub: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(text)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text(sub)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }
            Spacer()
        }
    }

    // MARK: - Step 3: Interests

    private var interestsStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Text("Какво те")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("интересува?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.mint)
            }

            Text("Избери какво искаш да виждаш на началния си екран.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                ForEach(HomeSection.allCases, id: \.self) { section in
                    Button {
                        withAnimation(OPTheme.quickSpring) {
                            if selectedInterests.contains(section) {
                                selectedInterests.remove(section)
                            } else {
                                selectedInterests.insert(section)
                            }
                        }
                    } label: {
                        let isSelected = selectedInterests.contains(section)
                        HStack(spacing: 12) {
                            Image(systemName: section.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(isSelected ? .white : OPTheme.mint)
                                .frame(width: 36, height: 36)
                                .background(isSelected ? AnyShapeStyle(OPTheme.mintGradient) : AnyShapeStyle(OPTheme.mintSoft), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Text(section.label)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(OPTheme.text)

                            Spacer()

                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(isSelected ? OPTheme.mint : OPTheme.textTertiary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            isSelected ? OPTheme.mintSoft.opacity(0.3) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? OPTheme.mint.opacity(0.3) : OPTheme.border, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Step 4: Permissions

    private var permissionsStep: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Text("Нужни")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text("разрешения")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OPTheme.mint)
            }

            VStack(spacing: 14) {
                permissionCard(icon: "location.fill", color: OPTheme.sky, title: "Локация", explanation: "За близки кучета и паркове")
                permissionCard(icon: "camera.fill", color: OPTheme.accent, title: "Камера и снимки", explanation: "За снимки на кучето ти")
                permissionCard(icon: "bell.fill", color: OPTheme.mint, title: "Известия", explanation: "Напомняне за ваксини")
            }

            Text("Можеш да промениш тези настройки по всяко време.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(OPTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func permissionCard(icon: String, color: Color, title: String, explanation: String) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text(explanation)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
    }
}
