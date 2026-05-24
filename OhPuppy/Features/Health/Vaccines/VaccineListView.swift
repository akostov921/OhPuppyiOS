import SwiftUI

struct VaccineListView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var showAddVaccine = false

    private var dog: Dog? { store.dogs.first { $0.id == dogId } }
    private var upcoming: [Vaccine] { store.upcomingVaccines(dogId: dogId) }
    private var past: [Vaccine] { store.pastVaccines(dogId: dogId) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if !upcoming.isEmpty {
                    vaccineSection(title: "Предстоящи", vaccines: upcoming, isUpcoming: true)
                }
                if !past.isEmpty {
                    vaccineSection(title: "История", vaccines: past, isUpcoming: false)
                }

                // Spacer at bottom for scroll
                Color.clear.frame(height: 40)
            }
            .padding(.top, 8)
        }
        .background(OPTheme.bg)
        .navigationTitle("Ваксини")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(OPTheme.springAnimation) {
                        showAddVaccine = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: showAddVaccine)
                        .frame(width: 34, height: 34)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .sheet(isPresented: $showAddVaccine) {
            AddVaccineView(dogId: dogId)
        }
    }

    private func vaccineSection(title: String, vaccines: [Vaccine], isUpcoming: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(OPTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, OPTheme.screenPadding)

            VStack(spacing: 0) {
                ForEach(Array(vaccines.enumerated()), id: \.element.id) { index, vaccine in
                    vaccineRow(vaccine, isUpcoming: isUpcoming)
                    if index < vaccines.count - 1 {
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

    private func vaccineRow(_ vaccine: Vaccine, isUpcoming: Bool) -> some View {
        HStack(spacing: 12) {
            let daysUntil = vaccine.nextDueDate?.daysFromNow ?? 0
            let isOverdue = isUpcoming && daysUntil < 0
            let isSoon = isUpcoming && daysUntil <= 7 && daysUntil >= 0

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isOverdue ? OPTheme.dangerSoft : isSoon ? OPTheme.warningSoft : isUpcoming ? OPTheme.successSoft : OPTheme.surfaceSunken)
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: isUpcoming ? "cross.vial.fill" : "checkmark.circle.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isOverdue ? OPTheme.danger : isSoon ? OPTheme.warning : isUpcoming ? OPTheme.success : OPTheme.textSecondary)
                        .symbolEffect(.pulse)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(vaccine.type.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                if isUpcoming, let due = vaccine.nextDueDate {
                    let days = due.daysFromNow
                    Text(days < 0 ? "Просрочена с \(abs(days)) дни" :
                         days <= 7 ? "След \(days) дни \u{00B7} \(due.shortBG)" :
                         "След \(days / 30) мес. \u{00B7} \(due.shortBG)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isOverdue ? OPTheme.danger : OPTheme.textSecondary)
                } else {
                    Text(vaccine.dateAdministered.shortBG)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
            }

            Spacer()

            if isUpcoming {
                let daysUntil2 = vaccine.nextDueDate?.daysFromNow ?? 0
                StatPill(
                    label: daysUntil2 < 0 ? "Просрочена" : daysUntil2 <= 7 ? "Скоро" : "В ред",
                    tone: daysUntil2 < 0 ? .danger : daysUntil2 <= 7 ? .warning : .success
                )
            }
        }
        .padding(14)
    }
}

// MARK: - Add Vaccine

struct AddVaccineView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var type: VaccineType = .rabies
    @State private var date = Date()
    @State private var vet = ""
    @State private var clinic = ""

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Type picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ТИП ВАКСИНА")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)

                        FlowLayout(spacing: 8) {
                            ForEach(VaccineType.allCases) { t in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { type = t }
                                } label: {
                                    Text(t.label)
                                        .font(.system(size: 13, weight: .semibold))
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

                    // Next due info card
                    let nextDue = Calendar.current.date(byAdding: .month, value: type.defaultIntervalMonths, to: date)!
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 18))
                            .foregroundStyle(OPTheme.mint)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Следваща: \(nextDue.shortBG)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(OPTheme.text)
                            Text("\(type.label) е валидна \(type.defaultIntervalMonths) мес.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(OPTheme.textSecondary)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(OPTheme.mintSoft.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ДАТА НА ПОСТАВЯНЕ")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .tint(OPTheme.primary)
                    }

                    formField("Ветеринар", text: $vet, placeholder: "Д-р Илиян Иванов")
                    formField("Клиника", text: $clinic, placeholder: "Ветеринарна клиника Лапа")
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .background(OPTheme.bg)
            .navigationTitle("Нова ваксина")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") {
                        let nextDue = Calendar.current.date(byAdding: .month, value: type.defaultIntervalMonths, to: date)!
                        store.addVaccine(Vaccine(
                            id: store.newId(),
                            dogId: dogId,
                            type: type,
                            dateAdministered: date,
                            nextDueDate: nextDue,
                            vet: vet.isEmpty ? nil : vet,
                            clinic: clinic.isEmpty ? nil : clinic
                        ))
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OPTheme.primary)
                }
            }
        }
    }

    private func formField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .medium))
                .padding(14)
                .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
