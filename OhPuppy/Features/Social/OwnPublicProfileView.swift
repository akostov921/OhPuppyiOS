import SwiftUI

struct OwnPublicProfileView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showWeight = true
    @State private var showAge = true
    @State private var showVaccines = true
    @State private var showBio = true
    @State private var showShareSheet = false

    private var dog: Dog? { store.dogs.first }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                heroSection
                profileInfo
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 20)

                statsRow
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 24)

                visibilityControls
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 24)

                previewSection
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 24)

                shareButton
                    .padding(.horizontal, OPTheme.screenPadding)
                    .padding(.bottom, 40)
            }
        }
        .background(OPTheme.bg)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showShareSheet) {
            if let d = dog {
                ShareSheet(activityItems: ["\(d.name) — \(d.breed) \u{2022} \(d.age)\n\nСподелено чрез OhPuppy"])
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: dog?.avatarURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(OPTheme.primaryGradient)
                }
            }
            .frame(height: 300)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, .clear, OPTheme.bg.opacity(0.5), OPTheme.bg],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 160)
            }

            HStack {
                BackButton()
                Spacer()
                Text("Публичен профил")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.top, 56)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Profile Info

    private var profileInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let d = dog {
                HStack(alignment: .firstTextBaseline) {
                    Text(d.name)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text(".")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(OPTheme.mint)
                }

                Text("\(d.breed) \u{2022} \(d.age)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                    Text(store.ownerName)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(OPTheme.textTertiary)
                .padding(.top, 2)

                if showBio, let bio = d.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(OPTheme.textSecondary)
                        .padding(.top, 4)
                }
            }
        }
        .offset(y: -30)
        .padding(.bottom, -10)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(store.vaccines.count)", label: "Ваксини")
            Divider().frame(height: 30)
            statItem(value: "\(store.dogs.count)", label: "Кучета")
            Divider().frame(height: 30)
            statItem(value: "0", label: "Последователи")
        }
        .padding(.vertical, 14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Visibility Controls

    private var visibilityControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Какво да виждат другите")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)

            VStack(spacing: 0) {
                visibilityToggle(icon: "scalemass.fill", label: "Тегло", isOn: $showWeight, color: OPTheme.mint)
                Divider().padding(.leading, 50)
                visibilityToggle(icon: "calendar", label: "Възраст", isOn: $showAge, color: OPTheme.sky)
                Divider().padding(.leading, 50)
                visibilityToggle(icon: "cross.vial.fill", label: "Ваксини", isOn: $showVaccines, color: OPTheme.accent)
                Divider().padding(.leading, 50)
                visibilityToggle(icon: "text.quote", label: "Описание", isOn: $showBio, color: OPTheme.primary)
            }
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
        }
    }

    private func visibilityToggle(icon: String, label: String, isOn: Binding<Bool>, color: Color) -> some View {
        Toggle(isOn: isOn) {
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
            }
        }
        .tint(OPTheme.mint)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Преглед")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OPTheme.text)

            if let d = dog {
                VStack(spacing: 0) {
                    infoPreviewRow(icon: "pawprint.fill", label: "Порода", value: d.breed, color: OPTheme.primary, visible: true)
                    Divider().padding(.leading, 50)
                    infoPreviewRow(icon: "scalemass.fill", label: "Тегло", value: "\(String(format: "%.1f", d.weight)) кг", color: OPTheme.mint, visible: showWeight)
                    Divider().padding(.leading, 50)
                    infoPreviewRow(icon: "calendar", label: "Възраст", value: d.age, color: OPTheme.sky, visible: showAge)
                    Divider().padding(.leading, 50)
                    infoPreviewRow(icon: "cross.vial.fill", label: "Ваксини", value: "\(store.vaccinesFor(dogId: d.id).count) регистрирани", color: OPTheme.accent, visible: showVaccines)
                }
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(OPTheme.border, lineWidth: 1))
            }
        }
    }

    private func infoPreviewRow(icon: String, label: String, value: String, color: Color, visible: Bool) -> some View {
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
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
            Spacer()
            if visible {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 11))
                    Text("Скрито")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(OPTheme.textTertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .opacity(visible ? 1 : 0.5)
    }

    // MARK: - Share

    private var shareButton: some View {
        Button { showShareSheet = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                Text("Сподели профил")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: OPTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
    }
}
