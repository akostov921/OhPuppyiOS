import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    @State private var showLogoutAlert = false
    @State private var showEditProfile = false
    @State private var showNotifications = false
    @State private var showPrivacy = false
    @State private var showLanguage = false
    @State private var showDarkMode = false
    @State private var showHelp = false
    @State private var showInviteShare = false
    @State private var showAbout = false
    @State private var headerScale: CGFloat = 1.0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                profileHero
                    .padding(.bottom, 20)

                statsRow
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 28)

                settingsSection(title: "АКАУНТ", items: [
                    SettingsItem(icon: "person.fill", label: "Редактирай профил", color: OPTheme.primary) { showEditProfile = true },
                    SettingsItem(icon: "bell.fill", label: "Известия", color: OPTheme.accent) { showNotifications = true },
                    SettingsItem(icon: "shield.fill", label: "Поверителност", color: OPTheme.sky) { showPrivacy = true },
                ])
                .padding(.bottom, 20)

                // Public profile preview
                NavigationLink(destination: OwnPublicProfileView()) {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(OPTheme.mintGradient)
                            .frame(width: 36, height: 36)
                            .overlay {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Виж публичния си профил")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                            Text("Как те виждат другите")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                    .padding(14)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(OPTheme.mint.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: OPTheme.mint.opacity(0.06), radius: 8, y: 3)
                }
                .buttonStyle(PressableCardStyle())
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.bottom, 20)

                servicesSection
                    .padding(.bottom, 20)

                settingsSection(title: "ПРИЛОЖЕНИЕ", items: [
                    SettingsItem(icon: "globe", label: "Език", color: OPTheme.mint) { showLanguage = true },
                    SettingsItem(icon: "moon.fill", label: "Тъмен режим", color: OPTheme.primary) { showDarkMode = true },
                    SettingsItem(icon: "questionmark.circle.fill", label: "Помощ", color: OPTheme.info) { showHelp = true },
                    SettingsItem(icon: "info.circle.fill", label: "За OhPuppy", color: OPTheme.textSecondary) { showAbout = true },
                ])
                .padding(.bottom, 20)

                logoutButton
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .navigationBarHidden(true)
        .alert("Излизане?", isPresented: $showLogoutAlert) {
            Button("Отказ", role: .cancel) { }
            Button("Излез", role: .destructive) { store.signOut() }
        } message: {
            Text("Сигурна ли си, че искаш да излезеш?")
        }
        .sheet(isPresented: $showEditProfile) { EditProfileSheet() }
        .sheet(isPresented: $showNotifications) { NotificationsSettingsSheet() }
        .sheet(isPresented: $showPrivacy) { PrivacySettingsSheet() }
        .sheet(isPresented: $showLanguage) { LanguageSheet() }
        .sheet(isPresented: $showDarkMode) { DarkModeSheet() }
        .sheet(isPresented: $showHelp) { HelpSheet() }
        .sheet(isPresented: $showAbout) { AboutSheet() }
        .sheet(isPresented: $showInviteShare) {
            ShareSheet(activityItems: ["Хей! Свали OhPuppy и нека се разхождаме заедно с кучетата! \u{1F43E}\nhttps://ohpuppy.bg/download"])
        }
    }

    // MARK: - Profile Hero

    private var profileHero: some View {
        ZStack(alignment: .bottom) {
            // Gradient banner
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F"), Color(hex: "40916C")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Subtle pattern overlay
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 200, height: 200)
                    .offset(x: -80, y: -60)
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 160, height: 160)
                    .offset(x: 100, y: 20)
            }
            .frame(height: 180)
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 32,
                    bottomTrailingRadius: 32
                )
            )

            // Avatar + name overlay
            VStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&h=200&q=85")) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(OPTheme.surfaceSunken)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(OPTheme.bg, lineWidth: 4)
                    )
                    .shadow(color: OPTheme.primary.opacity(0.3), radius: 12, y: 4)

                    Circle()
                        .fill(OPTheme.primaryGradient)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .overlay(Circle().stroke(OPTheme.bg, lineWidth: 3))
                        .offset(x: 4, y: 4)
                }
                .onTapGesture { showEditProfile = true }

                VStack(spacing: 4) {
                    Text(store.ownerName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 11, weight: .semibold))
                        Text("София, България")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(OPTheme.textSecondary)
                }
            }
            .offset(y: 50)
        }
        .padding(.bottom, 50)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            profileStatChip(value: "\(store.dogs.count)", label: "Кучета", icon: "pawprint.fill", gradient: OPTheme.primaryGradient)
            profileStatChip(value: "\(store.vaccines.count)", label: "Ваксини", icon: "cross.vial.fill", gradient: OPTheme.mintGradient)
            profileStatChip(value: "\(store.vetVisits.count)", label: "Прегледи", icon: "stethoscope", gradient: OPTheme.warmGradient)
        }
    }

    private func profileStatChip(value: String, label: String, icon: String, gradient: LinearGradient) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(gradient)
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
    }

    // MARK: - Settings Section

    private struct SettingsItem {
        let icon: String
        let label: String
        let color: Color
        let action: () -> Void
    }

    private func settingsSection(title: String, items: [SettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)
                .padding(.horizontal, OPTheme.screenPadding)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    settingsButton(icon: item.icon, label: item.label, color: item.color, action: item.action)
                    if index < items.count - 1 {
                        Divider().padding(.leading, 58)
                    }
                }
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    // MARK: - Services Section

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("УСЛУГИ")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)
                .padding(.horizontal, OPTheme.screenPadding)

            VStack(spacing: 0) {
                NavigationLink(destination: DogWalkerView()) {
                    settingsRow(icon: "figure.walk", label: "Разходчици", color: OPTheme.mint)
                }
                .buttonStyle(.plain)
                Divider().padding(.leading, 58)
                NavigationLink(destination: PlaydateView()) {
                    settingsRow(icon: "heart.fill", label: "Playdate", color: OPTheme.rose)
                }
                .buttonStyle(.plain)
                Divider().padding(.leading, 58)
                settingsButton(icon: "person.2.fill", label: "Покани приятел", color: OPTheme.accent) {
                    showInviteShare = true
                }
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
            .padding(.horizontal, OPTheme.screenPadding)
        }
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            showLogoutAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15))
                Text("Изход")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(OPTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.dangerSoft.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Helpers

    private func settingsButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingsRow(icon: icon, label: label, color: color)
        }
    }

    private func settingsRow(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.text)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var bio = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Име")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Въведи името си", text: $name)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Имейл")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Въведи имейл", text: $email)
                            .font(.system(size: 16))
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Био")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                        TextField("Разкажи нещо за себе си...", text: $bio, axis: .vertical)
                            .font(.system(size: 16))
                            .lineLimit(3...6)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Редактирай профил")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") {
                        store.ownerName = name
                        store.ownerEmail = email
                        store.ownerBio = bio
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                }
            }
        }
        .onAppear {
            name = store.ownerName
            email = store.ownerEmail
            bio = store.ownerBio
        }
    }
}

// MARK: - Notifications Settings Sheet

struct NotificationsSettingsSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $store.notificationSettings.vaccineReminders) {
                        Label("Напомняне за ваксини", systemImage: "cross.vial.fill")
                    }
                    Toggle(isOn: $store.notificationSettings.chatNotifications) {
                        Label("Съобщения в чата", systemImage: "bubble.left.fill")
                    }
                    Toggle(isOn: $store.notificationSettings.lostDogAlerts) {
                        Label("Изгубени кучета наблизо", systemImage: "exclamationmark.triangle.fill")
                    }
                } header: {
                    Text("Известия")
                }
            }
            .navigationTitle("Известия")
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

// MARK: - Privacy Settings Sheet

struct PrivacySettingsSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            List {
                Section {
                    Picker("Точност на местоположение", selection: $store.locationPrecision) {
                        ForEach(LocationPrecision.allCases, id: \.self) { precision in
                            Text(precision.rawValue).tag(precision)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Местоположение")
                } footer: {
                    Text("Точна: показва реалната ти позиция. Приблизителна: закръгля до квартал. Скрита: не показва позиция.")
                }

                Section {
                    Toggle(isOn: $store.showOnMap) {
                        Label("Покажи ме на картата", systemImage: "map.fill")
                    }
                } footer: {
                    Text("Ако е изключено, другите потребители няма да те виждат на картата.")
                }
            }
            .navigationTitle("Поверителност")
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

// MARK: - Language Sheet

struct LanguageSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            List {
                Section {
                    Picker("Език", selection: $store.language) {
                        Text("Български").tag("bg")
                        Text("English").tag("en")
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Избери език")
                } footer: {
                    Text("Интерфейсът ще се промени при следващо отваряне.")
                }
            }
            .navigationTitle("Език")
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

// MARK: - Dark Mode Sheet

struct DarkModeSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $store.isDarkMode) {
                        Label("Тъмен режим", systemImage: "moon.fill")
                    }
                } footer: {
                    Text("Превключва между светла и тъмна тема на приложението.")
                }
            }
            .navigationTitle("Тъмен режим")
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

// MARK: - Help Sheet

struct HelpSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let faqs: [(question: String, answer: String)] = [
        ("Как добавям ново куче?", "Отиди в раздел 'Кучета' и натисни бутона '+'. Попълни данните за кучето си и запази."),
        ("Как работят напомнянията за ваксини?", "Приложението следи датите на следващите ваксини и ти изпраща известие преди крайния срок."),
        ("Мога ли да споделя профила на кучето си?", "Да! От профила на кучето натисни бутона за споделяне и избери как искаш да споделиш."),
        ("Как се свързвам с други собственици?", "Използвай картата за да намериш кучета наблизо, или се присъедини към група в раздел Чат."),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(faqs.enumerated()), id: \.offset) { _, faq in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(OPTheme.mint)
                                Text(faq.question)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(OPTheme.text)
                            }
                            Text(faq.answer)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(OPTheme.textSecondary)
                                .padding(.leading, 28)
                        }
                        .padding(16)
                        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(OPTheme.border, lineWidth: 1)
                        )
                    }
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Помощ")
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

// MARK: - About Sheet

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                OPWordmark(size: 24)

                VStack(spacing: 8) {
                    Text("Версия 1.0.0")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                    Text("Made with \u{2764}\u{FE0F} in Sofia")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }

                VStack(spacing: 12) {
                    Link(destination: URL(string: "https://ohpuppy.bg")!) {
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                            Text("ohpuppy.bg")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(OPTheme.mint)
                    }

                    Link(destination: URL(string: "https://instagram.com/ohpuppy")!) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                            Text("@ohpuppy")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(OPTheme.mint)
                    }
                }

                Text("OhPuppy помага на собствениците на кучета да следят здравето, разходките и социалния живот на любимците си.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(OPTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(OPTheme.bg)
            .navigationTitle("За OhPuppy")
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
