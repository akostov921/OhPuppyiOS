import SwiftUI

struct LostDogView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDogId: String = ""
    @State private var lastSeenTime = Date()
    @State private var lastSeenPlace = ""
    @State private var description = ""
    @State private var contactPhone = ""
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(OPTheme.dangerSoft)
                            .frame(width: 64, height: 64)
                            .overlay {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(OPTheme.danger)
                            }

                        Text("Кучето ми се загуби")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(OPTheme.text)

                        Text("Ще уведомим всички наблизо. Запази спокойствие \u{2014} повечето кучета се намират в първите 24 часа.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(OPTheme.textSecondary)
                            .lineSpacing(2)
                    }

                    // Dog selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("КОЕ КУЧЕ?")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)

                        HStack(spacing: 10) {
                            ForEach(store.dogs) { dog in
                                Button {
                                    withAnimation(OPTheme.quickSpring) { selectedDogId = dog.id }
                                } label: {
                                    VStack(spacing: 6) {
                                        AsyncImage(url: dog.avatarURL) { phase in
                                            if let image = phase.image {
                                                image.resizable().scaledToFill()
                                            } else {
                                                Circle().fill(OPTheme.surfaceSunken)
                                                    .overlay {
                                                        Image(systemName: "pawprint.fill")
                                                            .font(.system(size: 14))
                                                            .foregroundStyle(OPTheme.mint)
                                                    }
                                            }
                                        }
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())

                                        Text(dog.name)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(OPTheme.text)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(selectedDogId == dog.id ? OPTheme.dangerSoft : OPTheme.surfaceSunken)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(selectedDogId == dog.id ? OPTheme.danger : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: OPTheme.cornerRadiusSmall, style: .continuous)
                            .stroke(OPTheme.border, lineWidth: 1)
                    )

                    // When last seen
                    VStack(alignment: .leading, spacing: 6) {
                        Text("КОГА БЕШЕ ПОСЛЕДНО ВИДЯН")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                        DatePicker("", selection: $lastSeenTime, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .tint(OPTheme.primary)
                    }

                    formField("Място", text: $lastSeenPlace, placeholder: "Борисова градина, вход откъм НДК", icon: "mappin.circle.fill", iconColor: OPTheme.danger)
                    formField("Описание", text: $description, placeholder: "С червена каишка, плаши се от деца", icon: nil, iconColor: .clear)
                    formField("Телефон за връзка", text: $contactPhone, placeholder: "+359 888 123 456", icon: "phone.fill", iconColor: OPTheme.mint)

                    // Send alert button
                    Button {
                        submitAlert()
                    } label: {
                        Text("Изпрати сигнал")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                selectedDogId.isEmpty ? AnyShapeStyle(OPTheme.textTertiary) : AnyShapeStyle(LinearGradient(colors: [OPTheme.danger, OPTheme.rose], startPoint: .leading, endPoint: .trailing)),
                                in: Capsule()
                            )
                    }
                    .disabled(selectedDogId.isEmpty)

                    Text("~340 души в радиус 5 км ще получат известие")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .padding(OPTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .background(OPTheme.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OPTheme.text)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("СПЕШНО")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.danger)
                        .tracking(0.8)
                }
            }
            .onAppear {
                if selectedDogId.isEmpty, let first = store.dogs.first {
                    selectedDogId = first.id
                }
            }
            .alert("Сигналът е изпратен!", isPresented: $showConfirmation) {
                Button("ОК") { dismiss() }
            } message: {
                Text("Всички наблизо ще получат известие. Надяваме се скоро да намериш кучето си!")
            }
        }
    }

    private func formField(_ label: String, text: Binding<String>, placeholder: String, icon: String?, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OPTheme.textSecondary)
                .tracking(0.5)
            HStack(spacing: 10) {
                TextField(placeholder, text: text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(OPTheme.text)
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(iconColor)
                }
            }
            .padding(14)
            .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func submitAlert() {
        let alert = LostDogAlert(
            id: store.newId(),
            dogId: selectedDogId,
            lastSeenTime: lastSeenTime,
            lastSeenPlace: lastSeenPlace,
            description: description,
            contactPhone: contactPhone,
            isResolved: false
        )
        store.addLostDogAlert(alert)
        showConfirmation = true
    }
}
