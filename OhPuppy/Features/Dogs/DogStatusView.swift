import SwiftUI

struct DogStatusView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    private var selectedStatusId: String? {
        store.currentDogStatus?.statusId
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header description
                VStack(spacing: 8) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(OPTheme.primaryGradient)
                    Text("Какво прави \(store.dogs.first?.name ?? "кучето") сега?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Приятелите ти ще виждат статуса")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(.top, 12)

                // Status grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(availableStatuses) { status in
                        statusCard(status)
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)

                // Clear button
                if selectedStatusId != nil {
                    Button {
                        withAnimation(OPTheme.quickSpring) {
                            store.clearDogStatus()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Изчисти статус")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(OPTheme.danger)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(OPTheme.dangerSoft, in: Capsule())
                    }
                    .padding(.top, 8)
                }

                Spacer()
            }
            .background(OPTheme.bg)
            .navigationTitle("Статус")
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

    private func statusCard(_ status: DogStatus) -> some View {
        let isSelected = selectedStatusId == status.id
        return Button {
            withAnimation(OPTheme.quickSpring) {
                if let dogId = store.dogs.first?.id {
                    store.setDogStatus(dogId: dogId, statusId: status.id)
                }
            }
        } label: {
            VStack(spacing: 8) {
                Text(status.emoji)
                    .font(.system(size: 32))
                Text(status.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                isSelected ? status.color.opacity(0.08) : OPTheme.surface,
                in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                    .stroke(isSelected ? status.color : OPTheme.border, lineWidth: isSelected ? 2 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(status.color)
                        .offset(x: -8, y: 8)
                }
            }
        }
        .buttonStyle(PressableCardStyle())
    }
}

// MARK: - Status Pill (reusable inline display)

struct DogStatusPill: View {
    @Environment(AppStore.self) private var store
    let showDogName: Bool
    var onTap: (() -> Void)?

    init(showDogName: Bool = true, onTap: (() -> Void)? = nil) {
        self.showDogName = showDogName
        self.onTap = onTap
    }

    var body: some View {
        if let status = store.currentDogStatus,
           let dogStatusDef = availableStatuses.first(where: { $0.id == status.statusId }) {
            Button {
                onTap?()
            } label: {
                HStack(spacing: 6) {
                    Text(dogStatusDef.emoji)
                        .font(.system(size: 14))
                    if showDogName, let dog = store.dogs.first(where: { $0.id == status.dogId }) {
                        Text("\(dog.name) е \(dogStatusDef.label.lowercased())")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                    } else {
                        Text(dogStatusDef.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(OPTheme.text)
                    }
                    Text("\u{00B7} \(statusTimeAgo(status.setAt))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(dogStatusDef.color.opacity(0.1), in: Capsule())
                .overlay(Capsule().stroke(dogStatusDef.color.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func statusTimeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "сега" }
        let minutes = seconds / 60
        if minutes < 60 { return "преди \(minutes) мин" }
        let hours = minutes / 60
        return "преди \(hours) ч"
    }
}

// MARK: - Status Badge (compact, for profile/map)

struct DogStatusBadge: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        if let status = store.currentDogStatus,
           let dogStatusDef = availableStatuses.first(where: { $0.id == status.statusId }) {
            HStack(spacing: 4) {
                Text(dogStatusDef.emoji)
                    .font(.system(size: 12))
                Text("\(dogStatusDef.label) \u{00B7} сега")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(dogStatusDef.color)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(dogStatusDef.color.opacity(0.1), in: Capsule())
        }
    }
}

// MARK: - Status Emoji (tiny, for map pins / chat)

struct DogStatusEmoji: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        if let status = store.currentDogStatus,
           let dogStatusDef = availableStatuses.first(where: { $0.id == status.statusId }) {
            Text(dogStatusDef.emoji)
                .font(.system(size: 10))
                .frame(width: 20, height: 20)
                .background(.white, in: Circle())
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        }
    }
}
