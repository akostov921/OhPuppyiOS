import SwiftUI

struct MedicationsView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @State private var showAddMedication = false

    private var activeMeds: [Medication] {
        store.medicationsFor(dogId: dogId).filter { $0.isActive }
    }

    private var completedMeds: [Medication] {
        store.medicationsFor(dogId: dogId).filter { !$0.isActive }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // Next dose hero
                if let next = activeMeds.first(where: { $0.frequency != .asNeeded }) {
                    nextDoseCard(next)
                }

                // Active section
                if !activeMeds.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        OPSectionHeader(title: "Активни")
                        VStack(spacing: 0) {
                            ForEach(Array(activeMeds.enumerated()), id: \.element.id) { index, med in
                                medRow(med, isActive: true)
                                if index < activeMeds.count - 1 {
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
                    }
                }

                // Completed section
                if !completedMeds.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        OPSectionHeader(title: "Приключени")
                        VStack(spacing: 0) {
                            ForEach(Array(completedMeds.enumerated()), id: \.element.id) { index, med in
                                medRow(med, isActive: false)
                                if index < completedMeds.count - 1 {
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
                    }
                }

                if activeMeds.isEmpty && completedMeds.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Лекарства")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddMedication = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(OPTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .sheet(isPresented: $showAddMedication) {
            AddMedicationView(dogId: dogId)
        }
    }

    // MARK: - Next Dose Card

    private func nextDoseCard(_ med: Medication) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(OPTheme.warningSoft)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(OPTheme.warning)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("СЛЕДВАЩА ДОЗА")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(OPTheme.warning)
                    .tracking(0.5)
                Text(med.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OPTheme.text)
                Text(med.dose)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()

            Button {
                // Mark as given
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                    Text("Дадох")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(OPTheme.primaryGradient, in: Capsule())
            }
        }
        .padding(14)
        .background(OPTheme.warningSoft.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                .stroke(OPTheme.warning.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Med Row

    private func medRow(_ med: Medication, isActive: Bool) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isActive ? OPTheme.successSoft : OPTheme.surfaceSunken)
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: isActive ? "pills.fill" : "checkmark.circle.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isActive ? OPTheme.success : OPTheme.textSecondary)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(med.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(OPTheme.text)
                Text("\(med.dose) \u{00B7} \(med.frequency.label)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
            }

            Spacer()

            if isActive {
                if let end = med.endDate {
                    let daysLeft = end.daysFromNow
                    StatPill(label: daysLeft > 0 ? "Още \(daysLeft) д." : "Днес", tone: daysLeft <= 3 ? .warning : .success)
                } else {
                    StatPill(label: "Постоянно", tone: .mint)
                }
            } else {
                if let end = med.endDate {
                    Text(end.shortBG)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }
            }
        }
        .padding(14)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "pills.fill")
                .font(.system(size: 40))
                .foregroundStyle(OPTheme.textTertiary)
            Text("Няма записани лекарства")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.textSecondary)
            Text("Натисни + за да добавиш ново лекарство")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

// MARK: - Add Medication

struct AddMedicationView: View {
    let dogId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var dose = ""
    @State private var frequency: MedFrequency = .daily
    @State private var startDate = Date()
    @State private var hasEndDate = true
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    formField("Име на лекарство", text: $name, placeholder: "Carprofen 50mg")
                    formField("Доза", text: $dose, placeholder: "1 таблетка")

                    // Frequency picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ЧЕСТОТА")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        FlowLayout(spacing: 8) {
                            ForEach(MedFrequency.allCases, id: \.self) { freq in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { frequency = freq }
                                } label: {
                                    Text(freq.label)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(frequency == freq ? .white : OPTheme.text)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 9)
                                        .background(
                                            frequency == freq ? AnyShapeStyle(OPTheme.primaryGradient) : AnyShapeStyle(OPTheme.surfaceSunken),
                                            in: Capsule()
                                        )
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("НАЧАЛНА ДАТА")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(OPTheme.primary)
                    }

                    Toggle(isOn: $hasEndDate) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Крайна дата").font(.system(size: 15, weight: .medium)).foregroundStyle(OPTheme.text)
                            Text("Задай продължителност на приема").font(.system(size: 12, weight: .medium)).foregroundStyle(OPTheme.textSecondary)
                        }
                    }
                    .tint(OPTheme.mint)
                    .padding(14)
                    .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))

                    if hasEndDate {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("КРАЙНА ДАТА")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(OPTheme.textSecondary)
                                .tracking(0.5)
                            DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                                .labelsHidden()
                                .tint(OPTheme.primary)
                        }
                    }

                    formField("Бележки", text: $notes, placeholder: "Допълнителни инструкции...")
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .background(OPTheme.bg)
            .navigationTitle("Ново лекарство")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                        .foregroundStyle(OPTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") {
                        let med = Medication(
                            id: store.newId(),
                            dogId: dogId,
                            name: name.isEmpty ? "Лекарство" : name,
                            dose: dose.isEmpty ? "1 доза" : dose,
                            frequency: frequency,
                            startDate: startDate,
                            endDate: hasEndDate ? endDate : nil,
                            notes: notes.isEmpty ? nil : notes
                        )
                        store.addMedication(med)
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
