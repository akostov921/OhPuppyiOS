import SwiftUI

struct MilestonesView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var showAddMilestone = false

    private var dog: Dog? { store.dogs.first { $0.id == dogId } }

    private var allMilestones: [MilestoneDisplay] {
        var items: [MilestoneDisplay] = []

        // Stored milestones (manual + auto-generated that are saved)
        for m in store.milestonesFor(dogId: dogId) {
            items.append(MilestoneDisplay(
                id: m.id,
                emoji: m.emoji,
                title: m.title,
                date: m.date,
                notes: m.notes,
                isPast: m.date <= Date()
            ))
        }

        // Auto-calculate milestones from birthDate
        if let birthDate = dog?.birthDate {
            let cal = Calendar.current
            let now = Date()

            // Birthdays
            let yearsSinceBirth = cal.dateComponents([.year], from: birthDate, to: now).year ?? 0
            for year in 1...max(yearsSinceBirth + 2, 3) {
                if let bday = cal.date(byAdding: .year, value: year, to: birthDate) {
                    let id = "auto_bday_\(year)"
                    if !items.contains(where: { $0.id == id }) {
                        items.append(MilestoneDisplay(
                            id: id,
                            emoji: "🎂",
                            title: "Рожден ден #\(year)!",
                            date: bday,
                            notes: "\(dog?.name ?? "") навършва \(year) \(year == 1 ? "година" : "години")",
                            isPast: bday <= now
                        ))
                    }
                }
            }

            // 1 month anniversary
            if let oneMonth = cal.date(byAdding: .month, value: 1, to: birthDate) {
                let id = "auto_1month"
                if !items.contains(where: { $0.id == id }) {
                    items.append(MilestoneDisplay(id: id, emoji: "🏠", title: "1 месец с нас", date: oneMonth, notes: nil, isPast: oneMonth <= now))
                }
            }

            // 6 months
            if let sixMonths = cal.date(byAdding: .month, value: 6, to: birthDate) {
                let id = "auto_6months"
                if !items.contains(where: { $0.id == id }) {
                    items.append(MilestoneDisplay(id: id, emoji: "🏠", title: "6 месеца с нас", date: sixMonths, notes: nil, isPast: sixMonths <= now))
                }
            }

            // Teeth change (4-6 months)
            if let teeth = cal.date(byAdding: .month, value: 5, to: birthDate) {
                let id = "auto_teeth"
                if !items.contains(where: { $0.id == id || $0.title.contains("Смяна на зъби") }) {
                    items.append(MilestoneDisplay(id: id, emoji: "🦷", title: "Смяна на зъби", date: teeth, notes: "Около 4-6 месечна възраст", isPast: teeth <= now))
                }
            }

            // Adult (breed-dependent, default 2 years for large breeds)
            let adultMonths = adultAgeMonths(breed: dog?.breed ?? "")
            if let adult = cal.date(byAdding: .month, value: adultMonths, to: birthDate) {
                let id = "auto_adult"
                if !items.contains(where: { $0.id == id || $0.title.contains("Вече е възрастен") }) {
                    items.append(MilestoneDisplay(id: id, emoji: "🐕", title: "Вече е възрастен!", date: adult, notes: "Породата достига зрялост", isPast: adult <= now))
                }
            }

            // Senior (breed-dependent)
            let seniorMonths = seniorAgeMonths(breed: dog?.breed ?? "")
            if let senior = cal.date(byAdding: .month, value: seniorMonths, to: birthDate) {
                let id = "auto_senior"
                if !items.contains(where: { $0.id == id || $0.title.contains("Старша възраст") }) {
                    items.append(MilestoneDisplay(id: id, emoji: "👴", title: "Старша възраст", date: senior, notes: "Време за по-чести ветеринарни прегледи", isPast: senior <= now))
                }
            }
        }

        return items.sorted { $0.date > $1.date }
    }

    private var pastMilestones: [MilestoneDisplay] {
        allMilestones.filter { $0.isPast }
    }

    private var upcomingMilestones: [MilestoneDisplay] {
        allMilestones.filter { !$0.isPast }.reversed()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                if !upcomingMilestones.isEmpty {
                    OPSectionHeader(title: "Предстоящи")
                    ForEach(upcomingMilestones) { milestone in
                        milestoneCard(milestone, isFuture: true)
                    }
                }

                if !pastMilestones.isEmpty {
                    OPSectionHeader(title: "Постигнати")
                        .padding(.top, 8)
                    ForEach(pastMilestones) { milestone in
                        milestoneCard(milestone, isFuture: false)
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Milestones")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddMilestone = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .sheet(isPresented: $showAddMilestone) {
            AddMilestoneView(dogId: dogId)
        }
    }

    // MARK: - Milestone Card

    private func milestoneCard(_ milestone: MilestoneDisplay, isFuture: Bool) -> some View {
        HStack(spacing: 14) {
            // Emoji circle
            ZStack {
                Circle()
                    .fill(isFuture ? OPTheme.surfaceSunken : Color(hex: "9B5DE5").opacity(0.12))
                    .frame(width: 48, height: 48)
                Text(milestone.emoji)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(milestone.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(isFuture ? OPTheme.textSecondary : OPTheme.text)

                    if !isFuture {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(OPTheme.success)
                    }
                }

                if let notes = milestone.notes {
                    Text(notes)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .lineLimit(2)
                }

                if isFuture {
                    let daysUntil = milestone.date.daysFromNow
                    Text(daysUntil > 30 ? "след \(daysUntil / 30) месеца" : "след \(daysUntil) дни")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "9B5DE5"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "9B5DE5").opacity(0.1), in: Capsule())
                } else {
                    Text(milestone.date.shortBG)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(OPTheme.textTertiary)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(isFuture ? OPTheme.border : Color(hex: "9B5DE5").opacity(0.2), lineWidth: 1)
        )
        .opacity(isFuture ? 0.75 : 1.0)
    }

    // MARK: - Helpers

    private func adultAgeMonths(breed: String) -> Int {
        switch breed {
        case "Лабрадор", "Голдън ретривър": return 24
        case "Френски булдог": return 12
        default: return 18
        }
    }

    private func seniorAgeMonths(breed: String) -> Int {
        switch breed {
        case "Лабрадор", "Голдън ретривър": return 84 // 7 years
        case "Френски булдог": return 96 // 8 years
        default: return 84
        }
    }
}

// MARK: - Display Model

struct MilestoneDisplay: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let date: Date
    let notes: String?
    let isPast: Bool
}

// MARK: - Add Milestone View

struct AddMilestoneView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmoji = "🌟"
    @State private var title = ""
    @State private var date = Date()
    @State private var notes = ""

    private let emojiOptions = [
        "🌟", "🎂", "🏠", "🦷", "🐕", "🏊", "❄️", "🎾",
        "🦮", "💊", "🏆", "📸", "🚗", "🌊", "🐾", "❤️",
        "🎓", "👑", "🌳", "☀️", "🦴", "🐶", "🎉", "🏅",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Emoji picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ЕМОДЖИ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button {
                                    selectedEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 24))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            selectedEmoji == emoji ? Color(hex: "9B5DE5").opacity(0.15) : OPTheme.surfaceSunken,
                                            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(selectedEmoji == emoji ? Color(hex: "9B5DE5") : .clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ЗАГЛАВИЕ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("Първо плуване, научи \"седни\"...", text: $title)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ДАТА")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .tint(OPTheme.primary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("БЕЛЕЖКИ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("Подробности (по избор)", text: $notes, axis: .vertical)
                            .font(.system(size: 16))
                            .lineLimit(2...4)
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(OPTheme.screenPadding)
            }
            .background(OPTheme.bg)
            .navigationTitle("Добави milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") {
                        withAnimation(OPTheme.springAnimation) {
                            store.addMilestone(Milestone(
                                id: store.newId(),
                                dogId: dogId,
                                emoji: selectedEmoji,
                                title: title,
                                date: date,
                                notes: notes.isEmpty ? nil : notes,
                                isCustom: true
                            ))
                        }
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                    .disabled(title.isEmpty)
                }
            }
        }
        .presentationDetents([.large])
    }
}
