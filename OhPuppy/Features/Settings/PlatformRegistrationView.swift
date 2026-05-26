import SwiftUI

// MARK: - Platform Hub

struct PlatformRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    OPWordmark(size: 18)
                    Text("Платформа за бизнеси")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 12)

                roleEntry(
                    role: .vet,
                    icon: "stethoscope",
                    title: "Ветеринар",
                    description: "Верифицирай ваксини, обяви услуги и цени, управлявай пациенти",
                    activeDescription: "Управлявай ценоразпис и пациенти",
                    gradient: LinearGradient(colors: [OPTheme.mint, Color(hex: "2D6A4F")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    regDestination: AnyView(VetRegistrationView())
                )

                roleEntry(
                    role: .brand,
                    icon: "bag.fill",
                    title: "Бранд",
                    description: "Качвай продукти, управлявай каталог, достигни хиляди собственици",
                    activeDescription: "Управлявай продукти и каталог",
                    gradient: LinearGradient(colors: [OPTheme.accent, OPTheme.rose], startPoint: .topLeading, endPoint: .bottomTrailing),
                    regDestination: AnyView(BrandRegistrationView())
                )

                roleEntry(
                    role: .walker,
                    icon: "figure.walk",
                    title: "Разходчик",
                    description: "Предлагай разходки, задавай цени, получавай ревюта",
                    activeDescription: "Виж точки, ревюта и статистика",
                    gradient: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    regDestination: AnyView(WalkerRegistrationInfoView())
                )

                roleEntry(
                    role: .shelter,
                    icon: "building.2.fill",
                    title: "Приют",
                    description: "Регистрирай кучета за осиновяване, получавай дарения",
                    activeDescription: "Управлявай кучета и дарения",
                    gradient: LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                    regDestination: AnyView(ShelterRegistrationView())
                )
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Партньорска програма")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func roleEntry(role: UserRole, icon: String, title: String, description: String, activeDescription: String, gradient: LinearGradient, regDestination: AnyView) -> some View {
        let isRegistered = store.registeredRoles.contains(role)

        return Group {
            if isRegistered {
                Button {
                    withAnimation(OPTheme.quickSpring) { store.activeRole = role }
                } label: {
                    roleCardContent(icon: icon, title: title, description: activeDescription, gradient: gradient, isRegistered: true)
                }
                .buttonStyle(PressableCardStyle())
            } else {
                NavigationLink(destination: regDestination) {
                    roleCardContent(icon: icon, title: title, description: description, gradient: gradient, isRegistered: false)
                }
                .buttonStyle(PressableCardStyle())
            }
        }
    }

    private func roleCardContent(icon: String, title: String, description: String, gradient: LinearGradient, isRegistered: Bool) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(gradient)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    if isRegistered {
                        Text("Активен")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(OPTheme.success)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(OPTheme.successSoft, in: Capsule())
                    }
                }
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(OPTheme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: isRegistered ? "arrow.right.arrow.left" : "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(OPTheme.textTertiary)
        }
        .padding(16)
        .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isRegistered ? OPTheme.success.opacity(0.3) : OPTheme.border, lineWidth: 1)
        )
        .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
    }
}

// MARK: - Vet Registration

struct VetRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store
    @State private var name = ""
    @State private var clinic = ""
    @State private var phone = ""
    @State private var licenseNumber = ""
    @State private var showSuccess = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 36))
                        .foregroundStyle(OPTheme.mintGradient)
                    Text("Регистрация като ветеринар")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Верифицирай ваксини и обяви услугите си")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                regField("Име", text: $name, placeholder: "Д-р Иванов", icon: "person.fill")
                regField("Клиника / Кабинет", text: $clinic, placeholder: "Ветеринарна клиника Лапа", icon: "building.2.fill")
                regField("Телефон", text: $phone, placeholder: "+359 88 123 4567", icon: "phone.fill")

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(OPTheme.success)
                        Text("НОМЕР НА ЛИЦЕНЗ (ДДЗ)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OPTheme.textSecondary)
                            .tracking(0.5)
                    }
                    TextField("BG-VET-XXXX", text: $licenseNumber)
                        .font(.system(size: 16, weight: .medium))
                        .padding(14)
                        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(licenseNumber.isEmpty ? .clear : OPTheme.success.opacity(0.5), lineWidth: 1)
                        )
                    Text("Лицензът ще бъде проверен от нашия екип за одобрение.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(OPTheme.textTertiary)
                }

                Button { showSuccess = true; store.registerRole(.vet) } label: {
                    Text("Изпрати заявка")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(OPTheme.mintGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.mint.opacity(0.3), radius: 10, y: 4)
                }
                .disabled(name.isEmpty || clinic.isEmpty)
                .opacity(name.isEmpty || clinic.isEmpty ? 0.5 : 1)
            }
            .padding(OPTheme.screenPadding)
        }
        .background(OPTheme.bg)
        .navigationTitle("Ветеринар")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Заявката е изпратена!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Одобрен! Вече можеш да управляваш услугите си.")
        }
    }
}

// MARK: - Brand Registration

struct BrandRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store
    @State private var brandName = ""
    @State private var website = ""
    @State private var contactEmail = ""
    @State private var category = "Храна"
    @State private var showSuccess = false
    private let categories = ["Храна", "Играчки", "Грижа", "Здраве", "Аксесоари"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(OPTheme.accentGradient)
                    Text("Регистрация на бранд")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Качвай продукти и достигни хиляди собственици")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                regField("Име на бранда", text: $brandName, placeholder: "Royal Canin", icon: "bag.fill")
                regField("Уебсайт", text: $website, placeholder: "https://example.com", icon: "globe")
                regField("Имейл за контакт", text: $contactEmail, placeholder: "info@brand.com", icon: "envelope.fill")

                VStack(alignment: .leading, spacing: 6) {
                    Text("КАТЕГОРИЯ")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OPTheme.textSecondary)
                        .tracking(0.5)
                    FlowLayout(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                withAnimation(OPTheme.quickSpring) { category = cat }
                            } label: {
                                Text(cat)
                                    .font(.system(size: 13, weight: category == cat ? .bold : .medium))
                                    .foregroundStyle(category == cat ? .white : OPTheme.text)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(category == cat ? AnyShapeStyle(OPTheme.accentGradient) : AnyShapeStyle(OPTheme.surfaceSunken), in: Capsule())
                            }
                        }
                    }
                }

                Button { showSuccess = true; store.registerRole(.brand) } label: {
                    Text("Изпрати заявка")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(OPTheme.accentGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: OPTheme.accent.opacity(0.3), radius: 10, y: 4)
                }
                .disabled(brandName.isEmpty)
                .opacity(brandName.isEmpty ? 0.5 : 1)
            }
            .padding(OPTheme.screenPadding)
        }
        .background(OPTheme.bg)
        .navigationTitle("Бранд")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Заявката е изпратена!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Одобрен! Вече можеш да качваш продукти.")
        }
    }
}

// MARK: - Walker Registration Info

struct WalkerRegistrationInfoView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("Стани разходчик")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Разхождай кучета, печели точки и рейтинг")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 12) {
                    benefitRow(icon: "banknote.fill", text: "Задавай собствени цени")
                    benefitRow(icon: "star.fill", text: "Събирай ревюта и рейтинг")
                    benefitRow(icon: "map.fill", text: "Появявай се на картата")
                    benefitRow(icon: "bell.fill", text: "Получавай заявки директно")
                    benefitRow(icon: "trophy.fill", text: "+10 точки за всяка разходка")
                    benefitRow(icon: "crown.fill", text: "5 нива: Начинаещ → Легенда")
                }
                .padding(20)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))

                Button { showSuccess = true; store.registerRole(.walker) } label: {
                    Text("Активирай профил на разходчик")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                }
            }
            .padding(OPTheme.screenPadding)
        }
        .background(OPTheme.bg)
        .navigationTitle("Разходчик")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Профилът е активиран!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Вече си разходчик! Виж панела си за точки и ревюта.")
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(OPTheme.sky)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(OPTheme.text)
        }
    }
}

// MARK: - Shelter Registration

struct ShelterRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var store
    @State private var shelterName = ""
    @State private var location = ""
    @State private var phone = ""
    @State private var showSuccess = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("Регистрация на приют")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text("Регистрирай кучета за осиновяване и получавай дарения")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                regField("Име на приюта", text: $shelterName, placeholder: "Приют Надежда", icon: "building.2.fill")
                regField("Град / Адрес", text: $location, placeholder: "София, ул. Примерна 1", icon: "mappin.and.ellipse")
                regField("Телефон", text: $phone, placeholder: "+359 88 123 4567", icon: "phone.fill")

                Button { showSuccess = true; store.registerRole(.shelter) } label: {
                    Text("Изпрати заявка")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .shadow(color: OPTheme.rose.opacity(0.3), radius: 10, y: 4)
                }
                .disabled(shelterName.isEmpty)
                .opacity(shelterName.isEmpty ? 0.5 : 1)
            }
            .padding(OPTheme.screenPadding)
        }
        .background(OPTheme.bg)
        .navigationTitle("Приют")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Приютът е регистриран!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Одобрен! Вече можеш да качваш кучета за осиновяване.")
        }
    }
}

// MARK: - Shared Form Field

private func regField(_ label: String, text: Binding<String>, placeholder: String, icon: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(label.uppercased())
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(OPTheme.textSecondary)
            .tracking(0.5)
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(OPTheme.mint)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(14)
        .background(OPTheme.surfaceSunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
