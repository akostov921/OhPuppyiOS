import SwiftUI

struct VetVisitsView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var showAddVisit = false

    private var visits: [VetVisit] { store.vetVisitsFor(dogId: dogId) }

    private var totalSpent: Double {
        visits.compactMap(\.price).reduce(0, +)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // Summary card
                summaryCard

                // Visit history
                if visits.isEmpty {
                    emptyState
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        OPSectionHeader(title: "История")

                        ForEach(visits) { visit in
                            visitCard(visit)
                        }
                    }
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Ветеринар")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddVisit = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .sheet(isPresented: $showAddVisit) {
            AddVetVisitView(dogId: dogId)
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        HStack(spacing: 0) {
            summaryItem(label: "Посещения", value: "\(visits.count)")
            summaryItem(label: "Похарчено", value: "\(Int(totalSpent)) лв")
            summaryItem(label: "Последно", value: visits.first.map { $0.date.daysFromNow == 0 ? "Днес" : "преди \(abs($0.date.daysFromNow)) д." } ?? "-")
        }
        .padding(16)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadius, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.06), radius: 12, y: 4)
    }

    private func summaryItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(OPTheme.text)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Visit Card

    private func visitCard(_ visit: VetVisit) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(visit.date.shortBG)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Text(visit.reason)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                }
                Spacer()
                if let price = visit.price {
                    StatPill(label: "\(Int(price)) лв", tone: .accent)
                }
            }

            if let diagnosis = visit.diagnosis, !diagnosis.isEmpty {
                Text(diagnosis)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.text)
                    .lineSpacing(2)
            }

            Divider()

            HStack(spacing: 10) {
                IconBadge(icon: "stethoscope", color: OPTheme.rose, bgColor: OPTheme.roseSoft, size: 28)

                VStack(alignment: .leading) {
                    if let vet = visit.vet {
                        Text(vet)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                    }
                    if let clinic = visit.clinic {
                        Text(clinic)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }
                }
                Spacer()
            }
        }
        .padding(14)
        .background(OPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "stethoscope")
                .font(.system(size: 40))
                .foregroundStyle(OPTheme.textTertiary)
            Text("Няма записи за посещения")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
            Text("Натисни + за да добавиш първото посещение")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

// MARK: - Add Vet Visit

struct AddVetVisitView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()
    @State private var reason = ""
    @State private var diagnosis = ""
    @State private var vet = ""
    @State private var clinic = ""
    @State private var price = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ДАТА НА ПОСЕЩЕНИЕ")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .tint(OPTheme.primary)
                    }

                    formField("Причина за посещение", text: $reason, placeholder: "Годишен преглед")
                    formField("Диагноза / Заключение", text: $diagnosis, placeholder: "Здрав, без отклонения")
                    formField("Ветеринар", text: $vet, placeholder: "Д-р Илиян Иванов")
                    formField("Клиника", text: $clinic, placeholder: "Ветеринарна клиника Лапа")
                    formField("Цена (лв)", text: $price, placeholder: "85", keyboard: .decimalPad)
                    formField("Бележки", text: $notes, placeholder: "Допълнителни бележки...")
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .background(OPTheme.bg)
            .navigationTitle("Ново посещение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") {
                        let visit = VetVisit(
                            id: store.newId(),
                            dogId: dogId,
                            date: date,
                            reason: reason.isEmpty ? "Посещение" : reason,
                            diagnosis: diagnosis.isEmpty ? nil : diagnosis,
                            vet: vet.isEmpty ? nil : vet,
                            clinic: clinic.isEmpty ? nil : clinic,
                            price: Double(price),
                            notes: notes.isEmpty ? nil : notes
                        )
                        store.addVetVisit(visit)
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
