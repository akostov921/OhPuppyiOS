import SwiftUI
import CoreLocation
import UserNotifications

struct OnboardingView: View {
    @Environment(AppStore.self) private var store
    @State private var currentStep = 0
    @State private var pawFloatOffset: CGFloat = 0
    @State private var pawRotation: Double = 0

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
                    if currentStep < 2 {
                        withAnimation(OPTheme.springAnimation) {
                            currentStep += 1
                        }
                    } else {
                        requestPermissions()
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
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? OPTheme.primary : OPTheme.textTertiary.opacity(0.3))
                    .frame(width: index == currentStep ? 24 : 8, height: 8)
                    .animation(OPTheme.springAnimation, value: currentStep)
            }
        }
    }

    private func requestPermissions() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
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
                            colors: [OPTheme.mint.opacity(0.2), OPTheme.primaryLight.opacity(0.08), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)

                Image(systemName: "pawprint.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(OPTheme.primaryGradient)
                    .symbolEffect(.breathe)
                    .offset(y: pawFloatOffset * 0.5)
            }

            VStack(spacing: 12) {
                Text("Здравей!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                +
                Text(" Аз съм ")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                +
                Text("Бисквит.")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(OPTheme.mint)

                Text("Тук следим ваксини, тегло и\nнамираме нови приятели за разходка.")
                    .font(.system(size: 15, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Step 2: Features

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

            VStack(spacing: 14) {
                featureCard(
                    icon: "heart.text.clipboard",
                    gradient: OPTheme.mintGradient,
                    title: "Здравен дневник",
                    subtitle: "Ваксини, тегло, грижа — всичко на едно място"
                )
                featureCard(
                    icon: "person.2.fill",
                    gradient: OPTheme.warmGradient,
                    title: "Социална мрежа",
                    subtitle: "Намери приятели за разходка наблизо"
                )
                featureCard(
                    icon: "map.fill",
                    gradient: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    title: "Жива карта",
                    subtitle: "Паркове, ветеринари и сигнали за изгубени"
                )
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func featureCard(icon: String, gradient: LinearGradient, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(gradient)
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text(subtitle)
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

    // MARK: - Step 3: Permissions

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
                permissionCard(
                    icon: "location.fill",
                    color: OPTheme.sky,
                    title: "Локация",
                    explanation: "За близки кучета и паркове"
                )
                permissionCard(
                    icon: "camera.fill",
                    color: OPTheme.accent,
                    title: "Камера и снимки",
                    explanation: "За снимки на кучето ти"
                )
                permissionCard(
                    icon: "bell.fill",
                    color: OPTheme.mint,
                    title: "Известия",
                    explanation: "Напомняне за ваксини"
                )
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
