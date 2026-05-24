import SwiftUI

struct GroomingView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var showAddGrooming = false

    private var entries: [GroomingLog] { store.groomingFor(dogId: dogId) }

    private var groupedByType: [(GroomingLog.GroomType, [GroomingLog])] {
        let dict = Dictionary(grouping: entries) { $0.type }
        return GroomingLog.GroomType.allCases
            .compactMap { type in
                guard let logs = dict[type], !logs.isEmpty else { return nil }
                return (type, logs)
            }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if entries.isEmpty {
                    emptyState
                } else {
                    ForEach(groupedByType, id: \.0) { type, logs in
                        groomingSection(type: type, logs: logs)
                    }
                }
                Color.clear.frame(height: 40)
            }
            .padding(.top, 8)
        }
        .background(OPTheme.bg)
        .navigationTitle("Гриминг")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(OPTheme.springAnimation) {
                        showAddGrooming = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: showAddGrooming)
                        .frame(width: 34, height: 34)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .sheet(isPresented: $showAddGrooming) {
            AddGroomingView(dogId: dogId)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "scissors")
                .font(.system(size: 40))
                .foregroundStyle(OPTheme.textTertiary)
                .symbolEffect(.wiggle.byLayer)
            Text("Няма записи за гриминг")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
            Text("Натисни + за да добавиш първия запис")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }

    // MARK: - Section

    private func groomingSection(type: GroomingLog.GroomType, logs: [GroomingLog]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(colorFor(type))
                Text(type.label.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OPTheme.textSecondary)
                    .tracking(0.5)
            }
            .padding(.horizontal, OPTheme.screenPadding)

            VStack(spacing: 0) {
                ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
                    groomingRow(log)
                    if index < logs.count - 1 {
                        Divider().padding(.leading, 66)
                    }
                }
            }
            .background(OPTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
            .padding(.horizontal, OPTheme.screenPadding)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Row

    private func groomingRow(_ log: GroomingLog) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(softColorFor(log.type))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: log.type.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(colorFor(log.type))
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(log.type.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                HStack(spacing: 6) {
                    Text(log.date.shortBG)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                    if let groomer = log.groomer, !groomer.isEmpty {
                        Text("\u{00B7} \(groomer)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                }
            }

            Spacer()

            if let price = log.price {
                Text("\(String(format: "%.0f", price)) лв")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(colorFor(log.type))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(softColorFor(log.type), in: Capsule())
            }
        }
        .padding(14)
    }

    // MARK: - Colors

    private func colorFor(_ type: GroomingLog.GroomType) -> Color {
        switch type {
        case .bath: OPTheme.sky
        case .haircut: Color.purple
        case .nails: OPTheme.accent
        case .teeth: OPTheme.mint
        case .ears: OPTheme.rose
        }
    }

    private func softColorFor(_ type: GroomingLog.GroomType) -> Color {
        switch type {
        case .bath: OPTheme.skySoft
        case .haircut: Color.purple.opacity(0.12)
        case .nails: OPTheme.accentSoft
        case .teeth: OPTheme.mintSoft
        case .ears: OPTheme.roseSoft
        }
    }
}

// MARK: - Add Grooming

struct AddGroomingView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var type: GroomingLog.GroomType = .bath
    @State private var date = Date()
    @State private var groomer = ""
    @State private var price = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Type picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ТИП ПРОЦЕДУРА")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)

                        FlowLayout(spacing: 8) {
                            ForEach(GroomingLog.GroomType.allCases, id: \.self) { t in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { type = t }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: t.icon)
                                            .font(.system(size: 12, weight: .semibold))
                                        Text(t.label)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                    .foregroundStyle(type == t ? .white : OPTheme.text)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 9)
                                    .background(
                                        type == t ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                        in: Capsule()
                                    )
                                }
                            }
                        }
                    }

                    // Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ДАТА")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .tint(OPTheme.primary)
                    }

                    formField("Грумър", text: $groomer, placeholder: "Име на грумъра")
                    formField("Цена (лв)", text: $price, placeholder: "35", keyboard: .decimalPad)
                    formField("Бележки", text: $notes, placeholder: "Допълнителни бележки")
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .background(OPTheme.bg)
            .navigationTitle("Добави")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") {
                        store.addGrooming(GroomingLog(
                            id: store.newId(),
                            dogId: dogId,
                            type: type,
                            date: date,
                            groomer: groomer.isEmpty ? nil : groomer,
                            price: Double(price),
                            notes: notes.isEmpty ? nil : notes
                        ))
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                }
            }
        }
    }

    private func formField(_ label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(OPTheme.text)
                .keyboardType(keyboard)
                .padding(14)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
