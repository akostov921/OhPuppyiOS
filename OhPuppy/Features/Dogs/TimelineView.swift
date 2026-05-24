import SwiftUI

// MARK: - Timeline Entry

struct TimelineEntry: Identifiable {
    let id: String
    let type: EntryType
    let title: String
    let subtitle: String
    let date: Date
    let photoURL: URL?

    enum EntryType {
        case vaccine, weight, grooming, vet, milestone, diary

        var icon: String {
            switch self {
            case .vaccine: "cross.vial.fill"
            case .weight: "scalemass.fill"
            case .grooming: "scissors"
            case .vet: "stethoscope"
            case .milestone: "star.fill"
            case .diary: "book.fill"
            }
        }

        var color: Color {
            switch self {
            case .vaccine: OPTheme.success
            case .weight: OPTheme.accent
            case .grooming: OPTheme.sky
            case .vet: OPTheme.rose
            case .milestone: Color(hex: "9B5DE5")
            case .diary: OPTheme.mint
            }
        }

        var bgColor: Color {
            switch self {
            case .vaccine: OPTheme.successSoft
            case .weight: OPTheme.accentSoft
            case .grooming: OPTheme.skySoft
            case .vet: OPTheme.roseSoft
            case .milestone: Color(hex: "9B5DE5").opacity(0.12)
            case .diary: OPTheme.mintSoft
            }
        }
    }
}

// MARK: - Timeline View

struct TimelineView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var showAddDiaryEntry = false

    private var dog: Dog? { store.dogs.first { $0.id == dogId } }

    private var allEntries: [TimelineEntry] {
        var entries: [TimelineEntry] = []

        // Vaccines
        for v in store.vaccinesFor(dogId: dogId) {
            entries.append(TimelineEntry(
                id: "v_\(v.id)",
                type: .vaccine,
                title: v.type.label,
                subtitle: v.vet ?? "Ваксинация",
                date: v.dateAdministered,
                photoURL: nil
            ))
        }

        // Weights
        for w in store.weightsFor(dogId: dogId) {
            entries.append(TimelineEntry(
                id: "w_\(w.id)",
                type: .weight,
                title: "\(String(format: "%.1f", w.weight)) кг",
                subtitle: w.notes ?? "Измерване на тегло",
                date: w.date,
                photoURL: nil
            ))
        }

        // Grooming
        for g in store.groomingFor(dogId: dogId) {
            entries.append(TimelineEntry(
                id: "g_\(g.id)",
                type: .grooming,
                title: g.type.label,
                subtitle: g.notes ?? "Гриминг процедура",
                date: g.date,
                photoURL: nil
            ))
        }

        // Vet visits
        for vv in store.vetVisitsFor(dogId: dogId) {
            entries.append(TimelineEntry(
                id: "vv_\(vv.id)",
                type: .vet,
                title: vv.reason,
                subtitle: vv.diagnosis ?? vv.clinic ?? "Посещение при ветеринар",
                date: vv.date,
                photoURL: nil
            ))
        }

        // Milestones
        for m in store.milestonesFor(dogId: dogId) {
            entries.append(TimelineEntry(
                id: "ms_\(m.id)",
                type: .milestone,
                title: "\(m.emoji) \(m.title)",
                subtitle: m.notes ?? "Milestone",
                date: m.date,
                photoURL: nil
            ))
        }

        // Diary entries
        for d in store.diaryEntriesFor(dogId: dogId) {
            entries.append(TimelineEntry(
                id: "d_\(d.id)",
                type: .diary,
                title: "Дневник",
                subtitle: d.text,
                date: d.date,
                photoURL: d.photoURL
            ))
        }

        return entries.sorted { $0.date > $1.date }
    }

    private var groupedByMonth: [(String, [TimelineEntry])] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "bg_BG")
        formatter.dateFormat = "LLLL yyyy"

        let grouped = Dictionary(grouping: allEntries) { entry in
            formatter.string(from: entry.date).capitalized
        }

        return grouped.sorted { pair1, pair2 in
            guard let d1 = pair1.value.first?.date, let d2 = pair2.value.first?.date else { return false }
            return d1 > d2
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(groupedByMonth.enumerated()), id: \.offset) { _, group in
                        sectionHeader(group.0)
                        ForEach(Array(group.1.enumerated()), id: \.element.id) { index, entry in
                            timelineRow(entry: entry, isLast: index == group.1.count - 1)
                        }
                    }
                }
                .padding(.horizontal, OPTheme.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
            .background(OPTheme.bg)

            // FAB
            Button {
                showAddDiaryEntry = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(OPTheme.primaryGradient, in: Circle())
                    .shadow(color: OPTheme.primary.opacity(0.35), radius: 12, y: 6)
            }
            .padding(.trailing, OPTheme.screenPadding)
            .padding(.bottom, 24)
        }
        .navigationTitle("Дневник")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddDiaryEntry) {
            AddDiaryEntryView(dogId: dogId)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(OPTheme.textSecondary)
            .tracking(0.5)
            .textCase(.uppercase)
            .padding(.top, 20)
            .padding(.bottom, 12)
    }

    // MARK: - Timeline Row

    private func timelineRow(entry: TimelineEntry, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline line + dot
            VStack(spacing: 0) {
                Circle()
                    .fill(entry.type.color)
                    .frame(width: 12, height: 12)
                    .padding(.top, 6)
                if !isLast {
                    Rectangle()
                        .fill(OPTheme.border)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            // Card
            HStack(spacing: 12) {
                IconBadge(icon: entry.type.icon, color: entry.type.color, bgColor: entry.type.bgColor, size: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                        .lineLimit(1)
                    Text(entry.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .lineLimit(2)
                    Text(entry.date.shortBG)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(OPTheme.textTertiary)
                }

                Spacer()

                if let url = entry.photoURL {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Rectangle().fill(OPTheme.surfaceSunken)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(12)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusTiny, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Add Diary Entry View

struct AddDiaryEntryView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Photo placeholder
                RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                    .fill(OPTheme.surfaceSunken)
                    .frame(height: 160)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(OPTheme.textTertiary)
                            Text("Добави снимка")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(OPTheme.textTertiary)
                        }
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text("БЕЛЕЖКА")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .tracking(0.5)
                    TextField("Какво се случи днес?", text: $text, axis: .vertical)
                        .font(.system(size: 16))
                        .lineLimit(3...6)
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

                Spacer()
            }
            .padding(OPTheme.screenPadding)
            .background(OPTheme.bg)
            .navigationTitle("Нов запис")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") {
                        withAnimation(OPTheme.springAnimation) {
                            store.addDiaryEntry(DiaryEntry(
                                id: store.newId(),
                                dogId: dogId,
                                text: text,
                                date: date,
                                photoURL: nil
                            ))
                        }
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                    .disabled(text.isEmpty)
                }
            }
        }
        .presentationDetents([.large])
    }
}
