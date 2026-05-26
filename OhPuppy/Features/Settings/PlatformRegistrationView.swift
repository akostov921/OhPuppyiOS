import SwiftUI

// MARK: - Platform Hub

struct PlatformRegistrationView: View {
    @Environment(\.dismiss) private var dismiss

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

                roleCard(
                    icon: "stethoscope",
                    title: "Ветеринар",
                    description: "Верифицирай ваксини, обяви услуги и цени, управлявай пациенти",
                    gradient: LinearGradient(colors: [OPTheme.mint, Color(hex: "2D6A4F")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    destination: VetRegistrationView()
                )

                roleCard(
                    icon: "bag.fill",
                    title: "Бранд",
                    description: "Качвай продукти, управлявай каталог, достигни хиляди собственици",
                    gradient: LinearGradient(colors: [OPTheme.accent, OPTheme.rose], startPoint: .topLeading, endPoint: .bottomTrailing),
                    destination: BrandRegistrationView()
                )

                roleCard(
                    icon: "figure.walk",
                    title: "Разходчик",
                    description: "Предлагай разходки, задавай цени, получавай ревюта",
                    gradient: LinearGradient(colors: [OPTheme.sky, Color(hex: "1D3557")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    destination: WalkerRegistrationInfoView()
                )

                roleCard(
                    icon: "building.2.fill",
                    title: "Приют",
                    description: "Регистрирай кучета за осиновяване, получавай дарения",
                    gradient: LinearGradient(colors: [OPTheme.rose, OPTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                    destination: ShelterRegistrationView()
                )
            }
            .padding(.horizontal, OPTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(OPTheme.bg)
        .navigationTitle("Партньорска програма")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func roleCard<D: View>(icon: String, title: String, description: String, gradient: LinearGradient, destination: D) -> some View {
        NavigationLink(destination: destination) {
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
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(OPTheme.text)
                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(OPTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OPTheme.textTertiary)
            }
            .padding(16)
            .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(OPTheme.border, lineWidth: 1)
            )
            .shadow(color: OPTheme.primary.opacity(0.04), radius: 8, y: 3)
        }
        .buttonStyle(PressableCardStyle())
    }
}

// MARK: - Vet Registration

struct VetRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
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

                Button { showSuccess = true } label: {
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
            Text("Ще проверим лиценза и ще ви одобрим до 48 часа. Ще получите известие.")
        }
    }
}

// MARK: - Brand Registration

struct BrandRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
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

                Button { showSuccess = true } label: {
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
            Text("Ще разгледаме бранда ви и ще одобрим до 72 часа.")
        }
    }
}

// MARK: - Walker Registration Info

struct WalkerRegistrationInfoView: View {
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
                    Text("Вече можеш да кандидатстваш от раздел Карта → Разходчици")
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
                }
                .padding(20)
                .background(OPTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(OPTheme.border, lineWidth: 1))

                NavigationLink(destination: DogWalkerView()) {
                    Text("Отиди на Разходчици")
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

                Button { showSuccess = true } label: {
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
        .alert("Заявката е изпратена!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Ще се свържем с вас до 48 часа за потвърждение.")
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
