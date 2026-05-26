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
                HStack(spacing: 6) {
                    Text(vaccine.type.label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(OPTheme.text)
                    if vaccine.isVerified {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 11))
                            Text("Верифицирана")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(OPTheme.success)
                    }
                }
                if isUpcoming, let due = vaccine.nextDueDate {
                    let days = due.daysFromNow
                    Text(days < 0 ? "Просрочена с \(abs(days)) дни" :
                         days <= 7 ? "След \(days) дни \u{00B7} \(due.shortBG)" :
                         "След \(days / 30) мес. \u{00B7} \(due.shortBG)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isOverdue ? OPTheme.danger : OPTheme.textSecondary)
                } else {
                    HStack(spacing: 4) {
                        Text(vaccine.dateAdministered.shortBG)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                        if let vetName = vaccine.verifiedByVet {
                            Text("· \(vetName)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(OPTheme.mint)
                        }
                    }
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
    @State private var verificationCode = ""
    @State private var showVetInvite = false
    @State private var showClinicSuggestions = false

    private let knownClinics = [
        "Ветеринарна клиника Лапа — ул. Витоша 45, София",
        "VetCare София — бул. България 102",
        "Зоо Вита — ул. Граф Игнатиев 12, София",
        "Четири лапи — ул. Цар Борис III 78, Пловдив",
        "Happy Paws Clinic — ул. Шипка 22, Варна",
        "Д-р Петров Вет — ул. Раковски 66, София",
    ]

    private var filteredClinics: [String] {
        guard !clinic.isEmpty else { return [] }
        return knownClinics.filter { $0.localizedCaseInsensitiveContains(clinic) }
    }

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

                    VStack(alignment: .leading, spacing: 6) {
                        Text("КЛИНИКА")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        TextField("Търси клиника...", text: $clinic)
                            .font(.system(size: 16, weight: .medium))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .onChange(of: clinic) { _, newValue in
                                showClinicSuggestions = !newValue.isEmpty && !filteredClinics.isEmpty
                            }

                        if showClinicSuggestions {
                            VStack(spacing: 0) {
                                ForEach(filteredClinics.prefix(3), id: \.self) { suggestion in
                                    Button {
                                        let parts = suggestion.components(separatedBy: " — ")
                                        clinic = parts.first ?? suggestion
                                        showClinicSuggestions = false
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "mappin.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(OPTheme.mint)
                                            Text(suggestion)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundStyle(OPTheme.text)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    }
                                    Divider().padding(.leading, 34)
                                }
                            }
                            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(OPTheme.mint.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: OPTheme.primary.opacity(0.06), radius: 8, y: 3)
                        }

                        Text("Не намираш клиниката? Напиши я ръчно.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)
                    }

                    // Verification section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(OPTheme.success)
                            Text("ВЕРИФИКАЦИЯ")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(OPTheme.textSecondary)
                                .tracking(0.5)
                        }

                        TextField("Код от ветеринаря (по избор)", text: $verificationCode)
                            .font(.system(size: 16, weight: .medium))
                            .padding(14)
                            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(verificationCode.isEmpty ? .clear : OPTheme.success.opacity(0.5), lineWidth: 1)
                            )

                        Text("Попитайте ветеринаря за код за верификация. Верифицираните ваксини имат специален знак.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(OPTheme.textTertiary)

                        Button { showVetInvite = true } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Покани ветеринар в OhPuppy")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundStyle(OPTheme.mint)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(OPTheme.mintSoft, in: Capsule())
                        }
                    }
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .background(OPTheme.bg)
            .sheet(isPresented: $showVetInvite) {
                ShareSheet(activityItems: ["Здравейте! Моля, регистрирайте се в OhPuppy като ветеринар, за да можете да верифицирате ваксините на пациентите си.\n\nРегистрация: https://ohpuppy.bg/vet-register\n\nБлагодаря!"])
            }
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
                        let code = verificationCode.trimmingCharacters(in: .whitespaces)
                        store.addVaccine(Vaccine(
                            id: store.newId(),
                            dogId: dogId,
                            type: type,
                            dateAdministered: date,
                            nextDueDate: nextDue,
                            vet: vet.isEmpty ? nil : vet,
                            clinic: clinic.isEmpty ? nil : clinic,
                            verificationCode: code.isEmpty ? nil : code,
                            verifiedByVet: code.isEmpty ? nil : (vet.isEmpty ? "Ветеринар" : vet)
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
