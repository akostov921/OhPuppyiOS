import SwiftUI

struct OnboardingView: View {
    @Environment(AppStore.self) private var store
    @State private var currentStep = 0

    var body: some View {
        ZStack {
            OPTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Group {
                    switch currentStep {
                    case 0:
                        welcomeStep
                    case 1:
                        featuresStep
                    default:
                        permissionsStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? OPTheme.primary : OPTheme.textTertiary.opacity(0.4))
                            .frame(width: index == currentStep ? 10 : 7, height: index == currentStep ? 10 : 7)
                            .animation(OPTheme.springAnimation, value: currentStep)
                    }
                }
                .padding(.bottom, 32)

                // Action button
                Button {
                    if currentStep < 2 {
                        withAnimation(OPTheme.springAnimation) {
                            currentStep += 1
                        }
                    } else {
                        store.completeOnboarding()
                    }
                } label: {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall))
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
    }

    private var buttonTitle: String {
        switch currentStep {
        case 0: "Започни"
        case 1: "Продължи"
        default: "Готово"
        }
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [OPTheme.mint.opacity(0.3), OPTheme.primaryLight.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "pawprint.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(OPTheme.primaryGradient)
            }
            .padding(.bottom, 12)

            Text("Здравей! Аз съм Бисквит.")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(OPTheme.text)

            Text("Тук следим ваксини, тегло и\nнамираме нови приятели за разходка.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(OPTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    // MARK: - Step 2: Features

    private var featuresStep: some View {
        VStack(spacing: 32) {
            Text("Какво можеш с OhPuppy")
                .font(.title2.bold())
                .foregroundStyle(OPTheme.text)

            VStack(spacing: 20) {
                featureRow(
                    icon: "heart.text.clipboard",
                    color: OPTheme.mint,
                    title: "Здравен дневник",
                    subtitle: "Ваксини, тегло, грижа — всичко на едно място"
                )

                featureRow(
                    icon: "person.2.fill",
                    color: OPTheme.accent,
                    title: "Социална мрежа",
                    subtitle: "Намери приятели за разходка наблизо"
                )

                featureRow(
                    icon: "map.fill",
                    color: OPTheme.sky,
                    title: "Жива карта",
                    subtitle: "Паркове, ветеринари и сигнали за изгубени"
                )
            }
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny)
                    .fill(color.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(OPTheme.text)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(OPTheme.surfaceSecondary, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall))
    }

    // MARK: - Step 3: Permissions

    private var permissionsStep: some View {
        VStack(spacing: 32) {
            Text("Нужни разрешения")
                .font(.title2.bold())
                .foregroundStyle(OPTheme.text)

            VStack(spacing: 20) {
                permissionRow(
                    icon: "location.fill",
                    color: OPTheme.sky,
                    title: "Локация",
                    explanation: "За близки кучета и паркове. Само докато ползваш."
                )

                permissionRow(
                    icon: "camera.fill",
                    color: OPTheme.accent,
                    title: "Камера",
                    explanation: "За снимки на кучето ти. Не снимаме без разрешение."
                )

                permissionRow(
                    icon: "bell.fill",
                    color: OPTheme.mint,
                    title: "Известия",
                    explanation: "Напомняне за ваксини и нови съобщения."
                )
            }

            Text("Можеш да промениш тези настройки по всяко време.")
                .font(.caption)
                .foregroundStyle(OPTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, OPTheme.screenPadding)
    }

    private func permissionRow(icon: String, color: Color, title: String, explanation: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(OPTheme.text)

                Text(explanation)
                    .font(.caption)
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(OPTheme.surfaceSecondary, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall))
    }
}
